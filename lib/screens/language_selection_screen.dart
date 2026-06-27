import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _languages = const [
    {'name': 'English', 'native': 'English'},
    {'name': 'Tamil', 'native': 'தமிழ்'},
    {'name': 'Malayalam', 'native': 'മലയാളം'},
    {'name': 'Hindi', 'native': 'हिन्दी'},
    {'name': 'Bengali', 'native': 'বাংলা'},
    {'name': 'Telugu', 'native': 'తెలుగు'},
    {'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'name': 'Marathi', 'native': 'मराठी'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00796B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.directions_boat_filled,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                translate('welcome'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translate('language_selection'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _languages.length,
                          itemBuilder: (context, index) {
                            final lang = _languages[index];
                            final isSelected = lang['name'] == currentLang;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    state.setLanguage(lang['name']!);
                                  },
                                  title: Text(
                                    lang['native']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF004D40) : Colors.black87,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: Color(0xFF00796B))
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.isLoggedIn) {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            } else {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: Text(
                            translate('continue_btn'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
