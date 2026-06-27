import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/state_models.dart';
import '../providers/app_state.dart';
import '../services/localization.dart';
import 'live_scanner_screen.dart';

class CatchScreen extends StatefulWidget {
  const CatchScreen({Key? key}) : super(key: key);

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isScanning = false;
  Uint8List? _imageBytes;
  final _speciesController = TextEditingController();
  final _weightController = TextEditingController();

  Future<void> _scanFish() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LiveScannerScreen()),
    );
    
    if (result != null && result is String) {
      setState(() {
        _isScanning = false;
        _speciesController.text = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Species Detection Complete: $result'),
            backgroundColor: const Color(0xFF00796B),
          ),
        );
      }
    }
  }

  void _saveCatch() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final catchItem = CatchItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        species: _speciesController.text,
        weightKg: _weightController.text,
      );
      context.read<AppState>().addCatch(catchItem);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catch Logged!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      appBar: AppBar(title: Text(translate('catch_details'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: _isScanning
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF00796B)),
                            SizedBox(height: 16),
                            Text('Analyzing image with AI...', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : (_imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _scanFish,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('AI Species Scanner'),
                              ),
                            ],
                          )),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'Species Name (Auto-filled or typed)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Please enter species' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Catch Weight (Kg)', border: OutlineInputBorder()),
                controller: _weightController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Please enter weight' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveCatch,
                  child: const Text('Log Catch', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
