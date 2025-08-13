import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<dynamic> rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadCases();
  }

  Future<void> loadCases() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final res = await http.get(
      Uri.parse('${auth.baseUrl}/api/chw_cases/'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );
    if (res.statusCode == 200) {
      setState(() {
        rows = jsonDecode(res.body);
        _loading = false;
      });
    } else {
      setState(() {
        rows = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (rows.isEmpty) return const Center(child: Text('No records'));

    final columns = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
          (states) => states.contains(MaterialState.selected)
              ? Colors.blue.shade50
              : null,
        ),
        columnSpacing: 20,
        columns: columns
            .map(
              (col) => DataColumn(
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    col.toString().toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ),
            )
            .toList(),
        rows: List.generate(rows.length, (index) {
          final row = rows[index];
          final isEven = index % 2 == 0;
          return DataRow(
            color: MaterialStateProperty.all(
                isEven ? Colors.grey.shade100 : Colors.white),
            cells: columns
                .map((col) => DataCell(Text(row[col]?.toString() ?? '')))
                .toList(),
          );
        }),
      ),
    );
  }
}
      