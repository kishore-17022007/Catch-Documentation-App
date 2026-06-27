import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    // Mock data for visualization
    final barGroups = [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 120, color: Colors.blue)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 90, color: Colors.teal)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 150, color: Colors.green)]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 70, color: Colors.orange)]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 200, color: Colors.purple)]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(translate('analysis'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Weekly Catch Volume (Kg)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: barGroups,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(days[value.toInt()]),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Insights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.trending_up, color: Colors.green, size: 36),
                  title: const Text('Revenue Up'),
                  subtitle: const Text('Your sales increased by 15% this week.'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_gas_station, color: Colors.orange, size: 36),
                  title: const Text('Fuel Efficiency'),
                  subtitle: const Text('Fuel consumption is stable compared to last month.'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
