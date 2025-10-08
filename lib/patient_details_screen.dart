import 'package:flutter/material.dart';

// --- PLACEHOLDER MODELS (Replace with your actual data models) ---
class PatientDetails {
  final String id;
  final String name;
  final String age;
  final String gender;
  final List<AppointmentRecord> appointments;
  final List<PrescriptionRecord> prescriptions;

  PatientDetails({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.appointments,
    required this.prescriptions,
  });
}

class AppointmentRecord {
  final String date;
  final String reason;
  final String doctor;
  AppointmentRecord({required this.date, required this.reason, required this.doctor});
}

class PrescriptionRecord {
  final String date;
  final int medicationCount;
  final String doctor;
  PrescriptionRecord({required this.date, required this.medicationCount, required this.doctor});
}
// --- END OF MODELS ---

class PatientDetailsScreen extends StatefulWidget {
  // --- FIX ---
  // The screen now correctly accepts a single, required `patientId`.
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late Future<PatientDetails?> _patientDetailsFuture;

  @override
  void initState() {
    super.initState();
    _patientDetailsFuture = _fetchPatientDetails();
  }

  // Simulates fetching detailed patient data from a backend using the patientId.
  Future<PatientDetails?> _fetchPatientDetails() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In a real app, you would make an API call with widget.patientId.
    // This is a simple check using our dummy data.
    if (widget.patientId == 'CS2021001') {
      return PatientDetails(
        id: 'CS2021001',
        name: 'John Doe',
        age: '21',
        gender: 'Male',
        appointments: [
          AppointmentRecord(date: '2024-09-15', reason: 'Fever and headache', doctor: 'Dr. Wilson'),
          AppointmentRecord(date: '2024-08-02', reason: 'Routine checkup', doctor: 'Dr. Wilson'),
        ],
        prescriptions: [
          PrescriptionRecord(date: '2024-09-15', medicationCount: 3, doctor: 'Dr. Wilson'),
        ],
      );
    }
    // Return another patient or null if not found
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Medical Record'),
      ),
      body: FutureBuilder<PatientDetails?>(
        future: _patientDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Patient record not found or failed to load.'),
            );
          }

          final patient = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientHeaderCard(patient),
                const SizedBox(height: 24),
                _buildSectionHeader('Appointment History'),
                _buildAppointmentList(patient.appointments),
                const SizedBox(height: 24),
                _buildSectionHeader('Prescription History'),
                _buildPrescriptionList(patient.prescriptions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientHeaderCard(PatientDetails patient) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('ID: ${patient.id} • ${patient.age} years • ${patient.gender}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildAppointmentList(List<AppointmentRecord> appointments) {
    if (appointments.isEmpty) {
      return const Text('No appointment history found.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(appointment.reason),
            subtitle: Text('with ${appointment.doctor}'),
            trailing: Text(appointment.date),
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionList(List<PrescriptionRecord> prescriptions) {
    if (prescriptions.isEmpty) {
      return const Text('No prescription history found.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text('${prescription.medicationCount} medications prescribed'),
            subtitle: Text('by ${prescription.doctor}'),
            trailing: Text(prescription.date),
          ),
        );
      },
    );
  }
}

