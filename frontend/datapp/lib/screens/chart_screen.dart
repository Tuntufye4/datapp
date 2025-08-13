import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';

class ChartScreen extends StatefulWidget {  
  const ChartScreen({super.key});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Map<String, int> districtCases = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCases();
  }

  Future<void> fetchCases() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = auth.token;
      final userRole = auth.role;

      if (token == null || userRole == null) {  
        throw Exception('User not logged in or role undefined');
      }

      String endpoint;
      if (userRole == 'CHW') {
        endpoint = '/api/chw_cases/';
      } else if (userRole == 'HSO') {
        endpoint = '/api/hso_cases/';
      } else if (userRole == 'CO') {
        endpoint = '/api/clinical_cases/';
      } else {
        throw Exception('Unknown user role');
      }

      final url = Uri.parse('${auth.baseUrl}$endpoint');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final List<dynamic> cases = json.decode(response.body);
        final Map<String, int> counts = {};
        for (var caseData in cases) {
          final district = caseData['district'] ?? 'Unknown';
          counts[district] = (counts[district] ?? 0) + 1;
        }

        setState(() {
          districtCases = counts;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cases: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) return Center(child: Text('Error: $errorMessage'));

    if (districtCases.isEmpty) return const Center(child: Text('No cases found'));

    final sortedDistricts = districtCases.keys.toList()..sort();

    // Bar chart groups
    final barGroups = sortedDistricts.asMap().entries.map((entry) {
      final idx = entry.key;
      final district = entry.value;
      final count = districtCases[district]!.toDouble();
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: count,
            color: Colors.blue,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    }).toList();

    // Pie chart sections
    final pieSections = districtCases.entries.map((entry) {
      final count = entry.value.toDouble();
      return PieChartSectionData(
        value: count,
        title: '${entry.key} (${entry.value})',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Cases by District',
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sortedDistricts.length) return const SizedBox.shrink();
                        final label = sortedDistricts[idx];
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
            'Cases by District',
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
       