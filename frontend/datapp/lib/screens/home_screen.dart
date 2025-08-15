import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

import 'forms/chw_form.dart';
import 'forms/clinical_form.dart';
import 'forms/hso_form.dart';

import 'chart_screen.dart';
import 'table_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});    

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  void _logout(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.logout(); // Clear token and user info
    Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final role = auth.role?.toUpperCase() ?? 'CHW';
    final token = auth.token ?? '';

    final List<Widget> tabs = [
      if (role == 'CHW')
        CHWForm()
      else if (role == 'CO' || role == 'CLINICAL')
        ClinicalFormPage()
      else
        HSOFormPage(token: token),
      const ChartScreen(),
      const TableScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Datapp: $role'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: tabs[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Charts'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Table'),   
        ],
      ),
    );
  }
}
