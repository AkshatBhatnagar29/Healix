import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart';

class CaretakerDashboardScreen extends StatefulWidget {
  const CaretakerDashboardScreen({super.key});

  @override
  State<CaretakerDashboardScreen> createState() => _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  final AuthService _authService = AuthService();
  late Future<List<dynamic>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    setState(() {
      _alertsFuture = _authService.getActiveAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretaker Dashboard'),
        actions: [
          IconButton(onPressed: _loadAlerts, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No active alerts for your hostel.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final alert = snapshot.data![index];
              return _buildAlertCard(alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    bool isActive = alert['status'] == 'Active';
    return Card(
      color: isActive ? Colors.red[50] : Colors.orange[50],
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        leading: Icon(Icons.warning_rounded, color: isActive ? Colors.red : Colors.orange, size: 40),
        title: Text('${alert['student_name']} (${alert['student_roll_number']})', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Location: ${alert['location_info']}\nStatus: ${alert['status']}'),
        isThreeLine: true,
      ),
    );
  }
}