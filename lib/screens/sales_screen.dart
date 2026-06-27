import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/state_models.dart';
import '../services/localization.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  String _species = '';
  String _quantity = '';
  String _price = '';
  String _buyer = '';

  void _saveSales() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final sale = SalesRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        species: _species,
        quantity: _quantity,
        pricePerKg: _price,
        buyerDetails: _buyer,
        date: DateTime.now().toIso8601String().split('T')[0],
      );
      context.read<AppState>().addSales(sale);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sales Recorded Successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      appBar: AppBar(title: Text(translate('sales_revenue'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Species', border: OutlineInputBorder()),
                onSaved: (val) => _species = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity (Kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _quantity = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price Per Kg (Rs)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _price = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Buyer Details', border: OutlineInputBorder()),
                onSaved: (val) => _buyer = val ?? '',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveSales,
                  child: const Text('Save Record', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
