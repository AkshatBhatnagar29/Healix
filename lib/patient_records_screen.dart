import 'package:flutter/material.dart';
import 'package:healix/patient_details_screen.dart'; // Navigates to the screen in the Canvas

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  bool _isLoading = false;

  // Simulates searching for a patient and navigates on success.
  Future<void> _searchPatient() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate a network call

    // --- DUMMY DATA (Replace with your actual backend logic) ---
    // This logic checks if the searched ID is 'cs2021001'
    if (studentId.toLowerCase() == 'cs2021001') {
      // On success, navigate to the patient's detailed record screen.
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patientId: studentId),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient record not found.')),
      );
    }
    // De-register the old keyboard focus and hide the keyboard.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildPatientSearchCard(),
      ),
    );
  }

  // This widget builds the search card UI.
  Widget _buildPatientSearchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Patient', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Enter Student ID to access medical records',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(
                hintText: 'Enter Student ID (e.g., CS2021001)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onSubmitted: (_) => _searchPatient(), // Allow searching with the enter key
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Icon(Icons.search),
                label: Text(_isLoading ? 'Searching...' : 'Search'),
                onPressed: _isLoading ? null : _searchPatient,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

