import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      appBar: AppBar(title: Text(translate('help_support'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.help_center, size: 80, color: Color(0xFF00796B)),
            const SizedBox(height: 24),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 16),
            const ExpansionTile(
              title: Text('How do I log a new fishing trip?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Go to the Dashboard and click on "Fishing Trip". Make sure you have added at least one vessel and crew member in your profile first.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('How do I change the language?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Click the globe icon in the top right corner of the Dashboard to return to the Language Selection screen.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('Is my data backed up?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Currently, all data is securely saved on your local device.'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF00796B)),
                title: const Text('Toll Free Number'),
                subtitle: const Text('1800-123-4567'),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Support...')));
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF00796B)),
                title: const Text('Email Support'),
                subtitle: const Text('support@catchdoc.org'),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Mail...')));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
