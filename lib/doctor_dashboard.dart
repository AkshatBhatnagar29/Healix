import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart';
import 'package:healix/login_page.dart'; // Import the login page for logout redirection

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final AuthService _authService = AuthService();

  // State variables to hold the data and manage the UI
  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _activeAlerts = [];

  // Dummy data for other sections, can be made dynamic later
  final int _totalAppointments = 8;
  final int _completedAppointments = 5;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // --- DATA FETCHING & HANDLING ---

  void _handleLogout() {
    if (mounted) {
      // Navigate to login screen and remove all other routes from the stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Fetch live SOS alerts
    final alerts = await _authService.getActiveAlerts();
    // In a real app, you would also fetch appointments, lab results, etc.
    // For now, we only check for logout on the alerts call.
    if (alerts.isEmpty && await _authService.getAccessToken() == null) {
      _handleLogout();
      return;
    }

    if (mounted) {
      setState(() {
        _activeAlerts = alerts;
        _isLoading = false;
      });
    }
  }

  Future<void> _acknowledgeAlert(int alertId) async {
    final success = await _authService.acknowledgeAlert(alertId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        // FIX: Added the missing color value
        const SnackBar(
            content: Text("Alert acknowledged successfully."),
            backgroundColor: Colors.green),
      );
      _loadDashboardData(); // Refresh the data
    } else {
      // If acknowledging fails, check if it was due to an auth issue
      if (await _authService.getAccessToken() == null) {
        _handleLogout();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to acknowledge alert."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UI BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.deleteTokens();
              _handleLogout();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
          child: Text(_errorMessage,
              style: const TextStyle(color: Colors.red)))
          : _buildDashboardContent(),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conditionally show the alerts section only if there are active alerts
          if (_activeAlerts.isNotEmpty) ...[
            const Text('Emergency Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._activeAlerts.map((alert) => _buildSosAlertCard(alert)).toList(),
            const SizedBox(height: 24),
          ],
          const Text('Good morning, Dr. Wilson',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Here\'s your summary for today',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          _buildSummaryGrid(),
          // ... you can add other sections like appointments list here
        ],
      ),
    );
  }

  Widget _buildSosAlertCard(Map<String, dynamic> alert) {
    bool isActive = alert['status'] == 'Active';
    return Card(
      color: isActive ? Colors.red[50] : Colors.orange[50],
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color:
                    isActive ? Colors.red.shade700 : Colors.orange.shade700),
                const SizedBox(width: 8),
                Text('Emergency Alert (${alert['status']})',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.red.shade800
                            : Colors.orange.shade800)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                '${alert['student_name']} (${alert['student_roll_number']}) triggered an alert from ${alert['hostel_name'] ?? 'N/A'}.'),
            const Divider(height: 24, thickness: 1),
            Text(
                'Caretaker: ${alert['caretaker_name'] ?? 'Not Assigned'}\nPhone: ${alert['caretaker_phone'] ?? 'N/A'}',
                style: TextStyle(color: Colors.grey[800], height: 1.5)),
            const SizedBox(height: 12),
            if (isActive)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _acknowledgeAlert(alert['id']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: const Text('Acknowledge'),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildSummaryCard('Total Appointments', _totalAppointments.toString(),
            Icons.calendar_today_rounded, Colors.blue),
        _buildSummaryCard('Completed', _completedAppointments.toString(),
            Icons.check_circle_outline_rounded, Colors.green),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Icon(icon, color: color.withOpacity(0.8), size: 28),
              ],
            ),
            Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

