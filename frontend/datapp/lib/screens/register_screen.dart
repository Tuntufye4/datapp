import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> data = {
    'username': '',
    'password': '',
    'email': '',
    'first_name': '',
    'last_name': '',
    'role': 'CHW'
  };
  bool _loading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => _loading = true);

    try {
      await auth.register(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered — now login.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: _inputDecoration('Username'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter username' : null,
                      onSaved: (v) => data['username'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>               
                          v == null || v.isEmpty ? 'Enter email' : null,
                      onSaved: (v) => data['email'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('First name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter first name' : null,
                      onSaved: (v) => data['first_name'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('Last name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter last name' : null,
                      onSaved: (v) => data['last_name'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('Password'),
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter password' : null,
                      onSaved: (v) => data['password'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: data['role'],
                      decoration: _inputDecoration('Role'),
                      items: const [
                        DropdownMenuItem(
                            value: 'CHW',
                            child: Text('Community Health Worker')),
                        DropdownMenuItem(
                            value: 'CO', child: Text('Clinical Officer')),
                        DropdownMenuItem(
                            value: 'HSO',
                            child: Text('Health Surveillance Officer')),
                      ],
                      onChanged: (v) => setState(() => data['role'] = v ?? 'CHW'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
