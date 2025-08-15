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
  List<Map<String, dynamic>> rows = [];
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
      final data = jsonDecode(res.body);
      if (data is List) {
        setState(() {
          rows = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      } else {
        setState(() {
          rows = [];
          _loading = false;
        });
      }
    } else {
      setState(() {
        rows = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
              ? const Center(child: Text('No records found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Scrollbar(
                          thumbVisibility: true,      
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor:
                                    MaterialStateProperty.all(Color.fromARGB(255, 68, 236, 138)),
                                dataRowColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (states) => states.contains(MaterialState.selected)
                                      ? Colors.blue.shade50
                                      : null,
                                ),
                                columnSpacing: 20,
                                headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                                columns: rows.first.keys
                                    .map((col) => DataColumn(
                                          label: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Text(
                                              col.toUpperCase(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                rows: List.generate(rows.length, (index) {
                                  final row = rows[index];
                                  final isEven = index % 2 == 0;
                                  return DataRow(
                                    color: MaterialStateProperty.all(
                                        isEven ? Colors.grey.shade100 : Colors.white),
                                    cells: rows.first.keys
                                        .map((col) => DataCell(
                                            Text(row[col]?.toString() ?? '')))
                                        .toList(),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
      