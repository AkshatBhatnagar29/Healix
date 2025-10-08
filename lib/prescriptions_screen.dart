import 'package:flutter/material.dart';

// Placeholder models for patient and medication data.
class Patient {
  final String id;
  final String name;
  Patient({required this.id, required this.name});
}

class Medication {
  String name;
  String dosage;
  Medication({required this.name, required this.dosage});
}

class CreatePrescriptionScreen extends StatefulWidget {
  const CreatePrescriptionScreen({super.key});

  @override
  State<CreatePrescriptionScreen> createState() =>
      _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final List<Medication> _medications = [];
  Patient? _selectedPatient;
  bool _isLoading = false;

  // Simulates searching for a patient.
  Future<void> _searchPatient() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) return;

    setState(() => _isLoading = true);
    // In a real app, you would make an API call here.
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data for demonstration.
    if (studentId.toLowerCase() == 'cs2021') {
      _selectedPatient = Patient(id: studentId, name: 'John Doe');
      _medications.add(Medication(name: '', dosage: '')); // Add one empty row
    } else {
      _selectedPatient = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient not found.')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _addMedicationRow() {
    setState(() {
      _medications.add(Medication(name: '', dosage: ''));
    });
  }

  void _removeMedicationRow(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Prescription'),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPatientSearchCard(),
            if (_selectedPatient != null) ...[
              const SizedBox(height: 24),
              _buildMedicationCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSearchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Patient',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Choose patient for prescription',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      hintText: 'Enter Student ID (e.g., CS2021)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Searching...' : 'Search'),
                  onPressed: _isLoading ? null : _searchPatient,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(_selectedPatient?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${_selectedPatient?.id ?? ''}'),
            ),
            const Divider(height: 24),
            ..._medications.asMap().entries.map((entry) {
              int idx = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Medication',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) => _medications[idx].name = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Dosage',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) => _medications[idx].dosage = val,
                      ),
                    ),
                    if (_medications.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeMedicationRow(idx),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
              onPressed: _addMedicationRow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement prescription submission logic
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text('Submit Prescription'),
      ),
    );
  }
}
