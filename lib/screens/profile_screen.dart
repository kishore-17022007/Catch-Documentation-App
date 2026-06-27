import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/state_models.dart';
import '../services/localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<AppState>().currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('fisher_profile')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: translate('profile_details')),
            Tab(text: translate('vessel_reg')),
            Tab(text: translate('crew_members')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProfileDetailsTab(),
          _VesselRegistrationTab(),
          _CrewMembersTab(),
        ],
      ),
    );
  }
}

class _ProfileDetailsTab extends StatefulWidget {
  const _ProfileDetailsTab({Key? key}) : super(key: key);

  @override
  State<_ProfileDetailsTab> createState() => _ProfileDetailsTabState();
}

class _ProfileDetailsTabState extends State<_ProfileDetailsTab> {
  final _formKey = GlobalKey<FormState>();
  late FisherProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = context.read<AppState>().profile;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AppState>().updateProfile(_profile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: _profile.fullName,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              onSaved: (val) => _profile.fullName = val ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _profile.fisherId,
              decoration: const InputDecoration(labelText: 'Fisher ID', border: OutlineInputBorder()),
              onSaved: (val) => _profile.fisherId = val ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _profile.aadhaarNumber,
              decoration: const InputDecoration(labelText: 'Aadhaar Number', border: OutlineInputBorder()),
              onSaved: (val) => _profile.aadhaarNumber = val ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _profile.landingCentre,
              decoration: const InputDecoration(labelText: 'Landing Centre / Harbour', border: OutlineInputBorder()),
              onSaved: (val) => _profile.landingCentre = val ?? '',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Profile', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VesselRegistrationTab extends StatelessWidget {
  const _VesselRegistrationTab({Key? key}) : super(key: key);

  void _showAddVesselDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final lengthCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Vessel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Vessel Name')),
            TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Vessel Type')),
            TextField(controller: lengthCtrl, decoration: const InputDecoration(labelText: 'Length')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<AppState>().addVessel(Vessel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  type: typeCtrl.text,
                  length: lengthCtrl.text,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vessels = context.watch<AppState>().vessels;
    return Column(
      children: [
        Expanded(
          child: vessels.isEmpty
              ? const Center(child: Text('No vessels added yet.'))
              : ListView.builder(
                  itemCount: vessels.length,
                  itemBuilder: (ctx, i) {
                    final v = vessels[i];
                    return ListTile(
                      leading: const Icon(Icons.directions_boat),
                      title: Text(v.name),
                      subtitle: Text('${v.type} - Length: ${v.length}'),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showAddVesselDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Vessel', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrewMembersTab extends StatelessWidget {
  const _CrewMembersTab({Key? key}) : super(key: key);

  void _showAddCrewDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Crew Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<AppState>().addCrewMember(CrewMember(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  fullName: nameCtrl.text,
                  age: ageCtrl.text,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crew = context.watch<AppState>().crew;
    return Column(
      children: [
        Expanded(
          child: crew.isEmpty
              ? const Center(child: Text('No crew members added yet.'))
              : ListView.builder(
                  itemCount: crew.length,
                  itemBuilder: (ctx, i) {
                    final c = crew[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(c.fullName),
                      subtitle: Text('Age: ${c.age}'),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showAddCrewDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Crew Member', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}
