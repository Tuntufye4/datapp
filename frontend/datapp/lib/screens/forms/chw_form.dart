import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CHWForm extends StatefulWidget {
  const CHWForm({super.key});

  @override
  State<CHWForm> createState() => _CHWFormState();
}

class _CHWFormState extends State<CHWForm> {
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
    'symptoms': '',
    'address': '',
    'district': '',
  };

  bool _loading = false;

  final List<String> sexOptions = ['Male', 'Female'];
  final List<String> diseaseOptions = ['Malaria', 'Diabetes', 'Hypertension', 'Other'];
  final List<String> treatmentOptions = ['Medication', 'Observation', 'Referral', 'Other'];
  final List<String> diagnosisOptions = ['Confirmed', 'Suspected', 'Ruling out', 'Other'];
  final List<String> symptomOptions = ['Fever', 'Cough', 'Fatigue', 'Other'];
  final List<String> districtOptions = [
    'Chitipa', 'Karonga', 'Rumphi', 'Mzimba', 'Nkhata Bay', 'Nkhotakota', 'Kasungu',
    'Lilongwe', 'Dedza', 'Ntcheu', 'Mangochi', 'Balaka', 'Machinga', 'Zomba',
    'Blantyre', 'Phalombe', 'Mulanje', 'Thyolo', 'Chiradzulu', 'Mwanza', 'Nsanje', 'Neno'
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => _loading = true);

    final url = Uri.parse('${auth.baseUrl}/api/chw_cases/');
    final res = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}'
        },
        body: jsonEncode(formData));

    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CHW Case submitted successfully')));
      _formKey.currentState!.reset();
      setState(() {
        formData.updateAll((key, value) => '');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: ${res.body}')));
    }
    setState(() => _loading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              'CHW Case Form',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Patient Name
            TextFormField(
              decoration: _inputDecoration('Patient Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter patient name' : null,
              onSaved: (v) => formData['patient_name'] = v ?? '',
            ),
            const SizedBox(height: 12),
            // Age
            TextFormField(
              decoration: _inputDecoration('Age'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter age' : null,
              onSaved: (v) => formData['age'] = int.tryParse(v ?? '') ?? 0,
            ),
            const SizedBox(height: 12),
            // Sex
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Sex'),
              value: formData['sex'].isNotEmpty ? formData['sex'] : null,
              items: sexOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => formData['sex'] = v ?? ''),
              validator: (v) => v == null || v.isEmpty ? 'Select sex' : null,
            ),
            const SizedBox(height: 12),
            // District
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('District'),
              value: formData['district'].isNotEmpty ? formData['district'] : null,
              items: districtOptions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => formData['district'] = v ?? ''),
              validator: (v) => v == null || v.isEmpty ? 'Select district' : null,
            ),
            const SizedBox(height: 12),
            // Disease
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Disease'),
              value: formData['disease'].isNotEmpty ? formData['disease'] : null,
              items: diseaseOptions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => formData['disease'] = v ?? ''),
              validator: (v) => v == null || v.isEmpty ? 'Select disease' : null,
            ),
            const SizedBox(height: 12),
            // Notes
            TextFormField(
              decoration: _inputDecoration('Notes'),
              maxLines: 2,
              onSaved: (v) => formData['notes'] = v ?? '',
            ),
            const SizedBox(height: 12),
            // Latitude
            TextFormField(
              decoration: _inputDecoration('Latitude'),
              keyboardType: TextInputType.number,
              onSaved: (v) => formData['latitude'] = v ?? '',
            ),
            const SizedBox(height: 12),
            // Longitude
            TextFormField(
              decoration: _inputDecoration('Longitude'),
              keyboardType: TextInputType.number,
              onSaved: (v) => formData['longitude'] = v ?? '',
            ),
            const SizedBox(height: 12),
            // Treatment
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Treatment'),
              value: formData['treatment'].isNotEmpty ? formData['treatment'] : null,
              items: treatmentOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => formData['treatment'] = v ?? ''),
            ),
            const SizedBox(height: 12),
            // Diagnosis
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Diagnosis'),
              value: formData['diagnosis'].isNotEmpty ? formData['diagnosis'] : null,
              items: diagnosisOptions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => formData['diagnosis'] = v ?? ''),
            ),
            const SizedBox(height: 12),
            // Symptoms
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Symptoms'),
              value: formData['symptoms'].isNotEmpty ? formData['symptoms'] : null,
              items: symptomOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => formData['symptoms'] = v ?? ''),
            ),
            const SizedBox(height: 12),
            // Address
            TextFormField(
              decoration: _inputDecoration('Address'),
              maxLines: 2,
              onSaved: (v) => formData['address'] = v ?? '',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Submit CHW Case', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
     