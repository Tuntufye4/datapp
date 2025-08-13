import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Map<String, int> diseaseCounts = {};
  Map<String, int> monthlyCounts = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final res = await http.get(
      Uri.parse('${auth.baseUrl}/api/chw_cases/'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      // Reset counts
      Map<String, int> diseaseMap = {};
      Map<String, int> monthMap = {};

      for (var c in data) {
        // Disease count
        final disease = (c['disease'] ?? 'Unknown') as String;
        diseaseMap[disease] = (diseaseMap[disease] ?? 0) + 1;

        // Monthly count (parse date, format as "YYYY-MM")
        final createdAt = c['created_at'] ?? c['date'] ?? '';
        if (createdAt.isNotEmpty) {
          try {
            final dt = DateTime.parse(createdAt);
            final key = "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}";
            monthMap[key] = (monthMap[key] ?? 0) + 1;
          } catch (e) {
            // ignore parse errors
          }
        }
      }

      setState(() {
        diseaseCounts = diseaseMap;
        monthlyCounts = monthMap;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      // Optionally handle errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diseaseCounts.isEmpty && monthlyCounts.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Prepare Pie chart sections
    final pieSections = diseaseCounts.entries.map((entry) {
      final percentage = entry.value;
      return PieChartSectionData(
        value: percentage.toDouble(),
        title: '${entry.key} (${percentage.toString()})',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // Sort months chronologically for bar chart
    final sortedMonths = monthlyCounts.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    final barGroups = sortedMonths.asMap().entries.map((entry) {
      final idx = entry.key;
      final month = entry.value;
      final count = monthlyCounts[month] ?? 0;
      return BarChartGroupData(x: idx, barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          color: Colors.blue,  
          width: 18,
          borderRadius: BorderRadius.circular(4),
        )
      ]);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Cases by Month (Bar Chart)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sortedMonths.length) {
                          return const SizedBox.shrink();
                        }
                        final label = sortedMonths[idx];
                        // Format label as 'YYYY-MM'
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(label, style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Cases by Disease (Pie Chart)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: 40,
                sectionsSpace: 4,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
      