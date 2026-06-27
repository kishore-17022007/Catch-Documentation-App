import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': translate('fisher_profile'),
        'icon': Icons.person,
        'route': '/profile',
        'color': Colors.blue.shade600
      },
      {
        'title': translate('fishing_trip'),
        'icon': Icons.directions_boat,
        'route': '/trip',
        'color': Colors.teal.shade600
      },
      {
        'title': translate('catch_details'),
        'icon': Icons.set_meal,
        'route': '/catch',
        'color': Colors.indigo.shade500
      },
      {
        'title': translate('sales_revenue'),
        'icon': Icons.attach_money,
        'route': '/sales',
        'color': Colors.green.shade600
      },
      {
        'title': translate('analysis'),
        'icon': Icons.bar_chart,
        'route': '/analysis',
        'color': Colors.orange.shade600
      },
      {
        'title': translate('help_support'),
        'icon': Icons.help_outline,
        'route': '/support',
        'color': Colors.purple.shade500
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(translate('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: state.isLoggedIn
                ? () async {
                    await context.read<AppState>().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${translate("welcome")}, ${state.profile.fullName.isNotEmpty ? state.profile.fullName : "Fisher"}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: state.isLoggedIn ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.isLoggedIn ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.isLoggedIn ? Icons.check_circle : Icons.error_outline,
                          color: state.isLoggedIn ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.isLoggedIn
                                ? 'Signed in as ${state.profile.phoneNumber.isNotEmpty ? state.profile.phoneNumber : (state.profile.uid.isNotEmpty ? state.profile.uid : state.fisherId)}'
                                : 'Not signed in. Firestore access will fail until you log in.',
                            style: TextStyle(
                              color: state.isLoggedIn ? Colors.green.shade900 : Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase user: ${FirebaseAuth.instance.currentUser?.uid ?? 'none'}',
                      style: TextStyle(
                        color: state.isLoggedIn ? Colors.green.shade900 : Colors.red.shade900,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Phone: ${FirebaseAuth.instance.currentUser?.phoneNumber ?? 'none'}',
                      style: TextStyle(
                        color: state.isLoggedIn ? Colors.green.shade900 : Colors.red.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, item['route']);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                item['color'].withOpacity(0.8),
                                item['color'],
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item['icon'],
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
