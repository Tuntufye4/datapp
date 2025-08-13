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
    final res = await http.get(Uri.parse('${auth.baseUrl}/api/chw_cases/'),     
        headers: {'Authorization': 'Bearer ${auth.token}'});
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Disease')),
          DataColumn(label: Text('Date')),
        ],
        rows: rows
            .map((r) => DataRow(cells: [
                  DataCell(Text(r['id'].toString())),
                  DataCell(Text(r['patient_name'] ?? '')),
                  DataCell(Text(r['disease'] ?? '')),
                  DataCell(Text(r['created_at'] ?? '')),
                ]))
            .toList(),
      ),
    );
  }
}
        