// import 'package:flutter/material.dart';
// import 'package:healix/navigation_drawer.dart';
// import 'package:healix/appointments_list_screen.dart';
// import 'package:healix/patient_details_screen.dart';
//
// // --- DUMMY DATA MODELS (Replace with your actual data models) ---
// // Note: To make this app truly dynamic, you would replace this static data
// // with real-time data from a backend service like Firebase or a REST API.
// // You would use a state management solution (like Provider or BLoC) to listen
// // for changes and automatically rebuild the UI.
//
// class Appointment {
//   final String patientName;
//   final String patientId;
//   final String reason;
//   final String time;
//   final AppointmentStatus status;
//
//   Appointment({
//     required this.patientName,
//     required this.patientId,
//     required this.reason,
//     required this.time,
//     required this.status,
//   });
// }
//
// enum AppointmentStatus { completed, upcoming }
//
// class LabResult {
//   final String patientName;
//   final String patientId;
//   final String testName;
//   final String date;
//   final LabStatus status;
//
//   LabResult({
//     required this.patientName,
//     required this.patientId,
//     required this.testName,
//     required this.date,
//     required this.status,
//   });
// }
//
// enum LabStatus { ready, pending }
//
//
// // --- MAIN DASHBOARD WIDGET ---
//
// class DoctorDashboardScreen extends StatefulWidget {
//   const DoctorDashboardScreen({super.key});
//
//   @override
//   State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
// }
//
// class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
//   // This state is now managed within the StatefulWidget to allow for dynamic changes,
//   // like dismissing the SOS alert.
//   bool _showSosAlert = true;
//
//   // --- DUMMY DATA (This would be fetched from your backend) ---
//   final List<Appointment> _appointments = [
//     Appointment(patientName: 'Kashish', patientId: 'CS2021001', reason: 'Routine checkup', time: '9:00 AM', status: AppointmentStatus.completed),
//     Appointment(patientName: 'Jane Smith', patientId: 'EE2021045', reason: 'Fever and headache', time: '10:30 AM', status: AppointmentStatus.completed),
//     Appointment(patientName: 'Mike Johnson', patientId: 'ME2020123', reason: 'Follow-up consultation', time: '2:30 PM', status: AppointmentStatus.upcoming),
//     Appointment(patientName: 'Sarah Wilson', patientId: 'CS2021089', reason: 'Health certificate', time: '3:45 PM', status: AppointmentStatus.upcoming),
//   ];
//
//   final List<LabResult> _labResults = [
//     LabResult(patientName: 'Kashish', patientId: 'CS2021001', testName: 'Blood Test - Complete Panel', date: '2024-01-15', status: LabStatus.ready),
//     LabResult(patientName: 'Jane Smith', patientId: 'EE2021045', testName: 'X-Ray Chest', date: '2024-01-14', status: LabStatus.pending),
//   ];
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.local_hospital_rounded, color: Theme.of(context).primaryColor),
//             const SizedBox(width: 8),
//             const Text('Healix', style: TextStyle(fontWeight: FontWeight.bold)), // UPDATED: App name
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_none_rounded),
//             onPressed: () {
//               // Handle notifications
//             },
//           ),
//         ],
//       ),
//       drawer: const AppNavigationDrawer(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // This alert card will disappear when 'Acknowledge' is tapped.
//             if (_showSosAlert) _buildSosAlertCard(),
//             const SizedBox(height: 16),
//             const Text(
//               'Good morning, Dr. Wilson',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               'Here\'s what\'s happening today',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 20),
//             _buildSummaryGrid(),
//             const SizedBox(height: 24),
//             _buildSectionHeader('Today\'s Appointments', 'Your scheduled consultations'),
//             _buildAppointmentsList(),
//             const SizedBox(height: 24),
//             _buildSectionHeader('Pending Lab Results', 'Tests awaiting review'),
//             _buildLabResultsList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- WIDGET BUILDER METHODS ---
//
//   Widget _buildSosAlertCard() {
//     return Card(
//       color: Colors.red[50],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         side: BorderSide(color: Colors.red[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.warning_amber_rounded, color: Colors.red),
//                 SizedBox(width: 8),
//                 Text('Emergency Alert', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             const Text('Kashish (CS2021001) has triggered an emergency alert from Hostel A - Room 205 at 2:56:18 PM.', style: TextStyle(height: 1.5)),
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerRight,
//               child: OutlinedButton(
//                 onPressed: () => setState(() => _showSosAlert = false), // This makes the card disappear
//                 child: const Text('Acknowledge'),
//                 style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: BorderSide(color: Colors.red[200]!)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSummaryGrid() {
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 1.8,
//       children: [
//         _buildSummaryCard('Total Appointments', '8', Icons.calendar_today_rounded, Colors.blue),
//         _buildSummaryCard('Completed', '5', Icons.check_circle_outline_rounded, Colors.green),
//         _buildSummaryCard('Pending', '3', Icons.hourglass_top_rounded, Colors.orange),
//         _buildSummaryCard('Lab Results', '2', Icons.science_outlined, Colors.purple),
//       ],
//     );
//   }
//
//   // UPDATED: This card is now tappable
//   Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AppointmentsListScreen(title: title)),
//         );
//       },
//       borderRadius: BorderRadius.circular(12.0),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
//                   Icon(icon, color: color.withOpacity(0.7)),
//                 ],
//               ),
//               Text(title, style: TextStyle(color: Colors.grey[700])),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, String subtitle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   // UPDATED: Appointment cards are now tappable
//   Widget _buildAppointmentsList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _appointments.length,
//       itemBuilder: (context, index) {
//         final appointment = _appointments[index];
//         final isCompleted = appointment.status == AppointmentStatus.completed;
//         return Card(
//           clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple stays within the card's rounded corners
//           child: InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientName: appointment.patientName, detailsType: "Appointment")),
//               );
//             },
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               leading: CircleAvatar(backgroundColor: const Color(0xFFE0F2F1), child: Icon(Icons.person_outline_rounded, color: Theme.of(context).primaryColor)),
//               title: Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Text('${appointment.patientId}\n${appointment.reason}'),
//               isThreeLine: true,
//               trailing: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(appointment.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(color: isCompleted ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(8)),
//                     child: Text(isCompleted ? 'completed' : 'upcoming', style: TextStyle(color: isCompleted ? Colors.green[700] : Colors.orange[700], fontSize: 12)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // UPDATED: Lab result cards are now tappable
//   Widget _buildLabResultsList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _labResults.length,
//       itemBuilder: (context, index) {
//         final result = _labResults[index];
//         final isReady = result.status == LabStatus.ready;
//         return Card(
//           clipBehavior: Clip.antiAlias,
//           child: InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientName: result.patientName, detailsType: "Lab Result")),
//               );
//             },
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               leading: CircleAvatar(backgroundColor: const Color(0xFFE0F2F1), child: Icon(Icons.science_outlined, color: Theme.of(context).primaryColor)),
//               title: Text(result.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Text('${result.patientId}\n${result.testName}'),
//               isThreeLine: true,
//               trailing: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(result.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(color: isReady ? Colors.green[50] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
//                     child: Text(isReady ? 'Ready' : 'Pending', style: TextStyle(color: isReady ? Colors.green[700] : Colors.grey[700], fontSize: 12)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//



import 'package:flutter/material.dart';
import 'package:healix/navigation_drawer.dart';
import 'package:healix/appointments_list_screen.dart';
import 'package:healix/patient_details_screen.dart';

// --- DUMMY DATA MODELS (Replace with your actual data models) ---
class Appointment {
  final String patientName;
  final String patientId;
  final String reason;
  final String time;
  final AppointmentStatus status;

  Appointment({
    required this.patientName,
    required this.patientId,
    required this.reason,
    required this.time,
    required this.status,
  });
}

enum AppointmentStatus { completed, upcoming }

class LabResult {
  final String patientName;
  final String patientId;
  final String testName;
  final String date;
  final LabStatus status;

  LabResult({
    required this.patientName,
    required this.patientId,
    required this.testName,
    required this.date,
    required this.status,
  });
}

enum LabStatus { ready, pending }


// --- MAIN DASHBOARD WIDGET ---
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _showSosAlert = true;

  // --- DUMMY DATA (This would be fetched from your backend) ---
  final List<Appointment> _appointments = [
    Appointment(patientName: 'Kashish', patientId: 'CS2021001', reason: 'Routine checkup', time: '9:00 AM', status: AppointmentStatus.completed),
    Appointment(patientName: 'Aryan', patientId: 'EE2021045', reason: 'Fever and headache', time: '10:30 AM', status: AppointmentStatus.completed),
    Appointment(patientName: 'Harshpreet Singh', patientId: 'ME2020123', reason: 'Follow-up consultation', time: '2:30 PM', status: AppointmentStatus.upcoming),
    Appointment(patientName: 'Mishthi Sharma', patientId: 'CS2021089', reason: 'Health certificate', time: '3:45 PM', status: AppointmentStatus.upcoming),
  ];

  final List<LabResult> _labResults = [
    LabResult(patientName: 'Kashish', patientId: 'CS2021001', testName: 'Blood Test - Complete Panel', date: '2024-01-15', status: LabStatus.ready),
    LabResult(patientName: 'Jane Smith', patientId: 'EE2021045', testName: 'X-Ray Chest', date: '2024-01-14', status: LabStatus.pending),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Healix', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showSosAlert) _buildSosAlertCard(),
            const SizedBox(height: 16),
            const Text(
              'Good morning, Dr. Wilson',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Here\'s what\'s happening today',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildSummaryGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader('Today\'s Appointments', 'Your scheduled consultations'),
            _buildAppointmentsList(),
            const SizedBox(height: 24),
            _buildSectionHeader('Pending Lab Results', 'Tests awaiting review'),
            _buildLabResultsList(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildSosAlertCard() {
    return Card(
      color: Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.red[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text('Emergency Alert', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Kashish (CS2021001) has triggered an emergency alert from Hostel A - Room 205 at 2:56:18 PM.', style: TextStyle(height: 1.5)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => setState(() => _showSosAlert = false),
                child: const Text('Acknowledge'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: BorderSide(color: Colors.red[200]!)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    // For simplicity, this grid remains the same, but you could add specific navigation.
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildSummaryCard('Total Appointments', '8', Icons.calendar_today_rounded, Colors.blue),
        _buildSummaryCard('Completed', '5', Icons.check_circle_outline_rounded, Colors.green),
        _buildSummaryCard('Pending', '3', Icons.hourglass_top_rounded, Colors.orange),
        _buildSummaryCard('Lab Results', '2', Icons.science_outlined, Colors.purple),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppointmentsListScreen(title: title)),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  Icon(icon, color: color.withOpacity(0.7)),
                ],
              ),
              Text(title, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        final isCompleted = appointment.status == AppointmentStatus.completed;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // --- FIX ---
              // Pass the patient's unique ID to the details screen.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientId: appointment.patientId)),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              leading: CircleAvatar(backgroundColor: const Color(0xFFE0F2F1), child: Icon(Icons.person_outline_rounded, color: Theme.of(context).primaryColor)),
              title: Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${appointment.patientId}\n${appointment.reason}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(appointment.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isCompleted ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(isCompleted ? 'completed' : 'upcoming', style: TextStyle(color: isCompleted ? Colors.green[700] : Colors.orange[700], fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabResultsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _labResults.length,
      itemBuilder: (context, index) {
        final result = _labResults[index];
        final isReady = result.status == LabStatus.ready;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // --- FIX ---
              // Pass the patient's unique ID to the details screen.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientDetailsScreen(patientId: result.patientId)),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              leading: CircleAvatar(backgroundColor: const Color(0xFFE0F2F1), child: Icon(Icons.science_outlined, color: Theme.of(context).primaryColor)),
              title: Text(result.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${result.patientId}\n${result.testName}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(result.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isReady ? Colors.green[50] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text(isReady ? 'Ready' : 'Pending', style: TextStyle(color: isReady ? Colors.green[700] : Colors.grey[700], fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

