import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HSOFormPage extends StatefulWidget {
  final String token;
  const HSOFormPage({super.key, required this.token});

  @override
  State<HSOFormPage> createState() => _HSOFormPageState();
}

class _HSOFormPageState extends State<HSOFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    'patient_name': '',
    'age': '',
    'sex': '',
    'disease': '',
    'notes': '',
    'latitude': '',
    'longitude': '',
    'treatment': '',
    'diagnosis': '',
    'surveillance_notes': '',
    'symptoms': '',
    'address': '',
  };

  bool _loading = false;

  final List<String> sexes = ['Male', 'Female'];   
  final List<String> diseases = ['Malaria', 'Typhoid', 'Cholera', 'Other'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    final url = Uri.parse('http://127.0.0.1:8000/api/hso_cases/');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(formData),
    );

    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HSO Case submitted successfully')));
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: ${res.body}')));
    }

    setState(() => _loading = false);
  }

  Widget _buildTextField(String label, {int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        maxLines: maxLines,
        keyboardType: type ?? TextInputType.text,
        validator: (v) =>
            (v == null || v.isEmpty) && label != 'Notes' ? 'Enter $label' : null,
        onSaved: (v) {
          String key = label.toLowerCase().replaceAll(' ', '_');
          if (key == 'latitude' || key == 'longitude') {
            formData[key] = double.tryParse(v ?? '') ?? 0;
          } else if (key == 'age') {
            formData[key] = int.tryParse(v ?? '') ?? 0;
          } else {
            formData[key] = v ?? '';
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'HSO Case Form',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _buildTextField('Patient Name'),
            _buildTextField('Age', type: TextInputType.number),

            // Sex Dropdown
            DropdownButtonFormField<String>(
              value: formData['sex'].isEmpty ? null : formData['sex'],
              items: sexes
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => formData['sex'] = v ?? ''),
              decoration: InputDecoration(
                labelText: 'Sex',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Select sex' : null,
            ),
            const SizedBox(height: 12),

            // Disease Dropdown
            DropdownButtonFormField<String>(
              value: formData['disease'].isEmpty ? null : formData['disease'],
              items: diseases
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => formData['disease'] = v ?? ''),
              decoration: InputDecoration(
                labelText: 'Disease',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Select disease' : null,
            ),
            const SizedBox(height: 12),

            // Other fields
            _buildTextField('Diagnosis'),
            _buildTextField('Treatment'),
            _buildTextField('Notes', maxLines: 3),
            _buildTextField('Symptoms', maxLines: 3),
            _buildTextField('Surveillance Notes', maxLines: 3),
            _buildTextField('Address', maxLines: 2),
            _buildTextField('Latitude', type: TextInputType.number),
            _buildTextField('Longitude', type: TextInputType.number),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit HSO Case', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
      