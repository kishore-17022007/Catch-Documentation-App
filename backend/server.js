const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');

const app = express();
app.use(cors());
app.use(express.json());

const uri = "mongodb+srv://kishoresresearch_db_user:vHmCrAvGIXZn9mEe@cluster1.aedhw0z.mongodb.net/?retryWrites=true&w=majority&appName=Cluster1";
const client = new MongoClient(uri);

let db;

async function connectDB() {
  try {
    await client.connect();
    db = client.db('fishers_app_db');
    console.log("Connected to MongoDB Atlas successfully");
  } catch (e) {
    console.error("MongoDB Connection Error:", e);
  }
}
connectDB();

// A generic endpoint to execute operations like the Data API used to
app.post('/action/:action', async (req, res) => {
  const { action } = req.params;
  const { collection: colName, document, filter, update, sort, upsert } = req.body;
  
  if (!db) return res.status(500).json({ error: "Database not connected" });
  
  const col = db.collection(colName);
  
  try {
    switch(action) {
      case 'insertOne':
        await col.insertOne(document);
        res.json({ insertedId: document.id });
        break;
      case 'updateOne':
        await col.updateOne(filter, update, { upsert: upsert || false });
        res.json({ modifiedCount: 1 });
        break;
      case 'findOne':
        const doc = await col.findOne(filter);
        res.json({ document: doc });
        break;
      case 'find':
        let query = col.find(filter);
        if (sort) query = query.sort(sort);
        const docs = await query.toArray();
        res.json({ documents: docs });
        break;
      case 'deleteOne':
        await col.deleteOne(filter);
        res.json({ deletedCount: 1 });
        break;
      default:
        res.status(400).json({ error: "Unknown action" });
    }
  } catch (e) {
    console.error(`Error executing ${action}:`, e);
    res.status(500).json({ error: e.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Backend server listening on port ${PORT}`));
