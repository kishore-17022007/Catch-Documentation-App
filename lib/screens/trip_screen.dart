import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/state_models.dart';
import '../services/localization.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVesselId;
  final List<String> _selectedCrewIds = [];
  String _startGps = '';
  String _endGps = '';
  String _fuelConsumed = '';

  void _saveTrip() {
    if (_formKey.currentState!.validate() && _selectedVesselId != null) {
      _formKey.currentState!.save();
      final trip = TripRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vesselId: _selectedVesselId!,
        crewIds: _selectedCrewIds,
        startGps: _startGps,
        endGps: _endGps,
        fuelConsumed: _fuelConsumed,
      );
      context.read<AppState>().addTrip(trip);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip Saved Successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      appBar: AppBar(title: Text(translate('fishing_trip'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Vessel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedVesselId,
                items: state.vessels.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                onChanged: (val) => setState(() => _selectedVesselId = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (val) => val == null ? 'Please select a vessel' : null,
              ),
              const SizedBox(height: 20),
              
              const Text('Select Crew', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...state.crew.map((c) {
                return CheckboxListTile(
                  title: Text(c.fullName),
                  value: _selectedCrewIds.contains(c.id),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedCrewIds.add(c.id);
                      } else {
                        _selectedCrewIds.remove(c.id);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Start GPS Coordinate', border: OutlineInputBorder()),
                onSaved: (val) => _startGps = val ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'End GPS Coordinate', border: OutlineInputBorder()),
                onSaved: (val) => _endGps = val ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fuel Consumed (L)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _fuelConsumed = val ?? '',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTrip,
                  child: const Text('Save Trip', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
