import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Map<String, int> districtCases = {};
  Map<String, int> diseaseCounts = {};
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
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final List<dynamic> cases = json.decode(response.body);

        final Map<String, int> districtCounts = {};
        final Map<String, int> diseaseMap = {};

        for (var caseData in cases) {
          final district = caseData['district'] ?? 'Unknown';
          districtCounts[district] = (districtCounts[district] ?? 0) + 1;

          final disease = caseData['disease'] ?? 'Unknown';
          diseaseMap[disease] = (diseaseMap[disease] ?? 0) + 1;
        }

        setState(() {
          districtCases = districtCounts;
          diseaseCounts = diseaseMap;
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
    final sortedDiseases = diseaseCounts.keys.toList();
    final totalCases = diseaseCounts.values.fold<int>(0, (a, b) => a + b);

    // Bar chart groups for district cases
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

    // Pie chart sections for disease distribution
    final pieSections = sortedDiseases.map((disease) {
      final count = diseaseCounts[disease]!.toDouble();
      final percentage = (count / totalCases) * 100;
      final color =
          Colors.primaries[sortedDiseases.indexOf(disease) % Colors.primaries.length];
      return PieChartSectionData(
        value: count,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // District Cases Bar Chart
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Cases by District',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= sortedDistricts.length)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(sortedDistricts[idx],
                                      style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true),
                        alignment: BarChartAlignment.spaceAround,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Disease Distribution Pie Chart
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Disease Distribution',   
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: sortedDiseases.map((disease) {
                      final color = Colors
                          .primaries[sortedDiseases.indexOf(disease) %
                              Colors.primaries.length];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, color: color),
                          const SizedBox(width: 4),
                          Text(disease, style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
