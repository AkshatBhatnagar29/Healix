import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';

class SosDetailScreen extends StatelessWidget {
  final String eventId;

  const SosDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Alert Details'),
      ),
      body: FutureBuilder<SosDetails>(
        future: apiService.getSosDetails(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data found for this alert.'));
          }

          final details = snapshot.data!;
          final profile = details.profile;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildDetailCard('Student', details.studentUsername),
                _buildDetailCard('Alert Time', details.alertTime),
                // _buildDetailCard('Location', 'Lat: ${details.latitude}, Lon: ${details.longitude}'),
                SizedBox(height: 10),
                Text('Student Profile Data', style: Theme.of(context).textTheme.titleLarge),
                _buildDetailCard('Full Name', profile['full_name'] ?? 'N/A'),
                _buildDetailCard('Roll Number', profile['roll_number'] ?? 'N/A'),
                _buildDetailCard('Blood Group', profile['blood_group'] ?? 'N/A'),
                _buildDetailCard('Allergies', profile['allergies'] ?? 'N/A'),
                _buildDetailCard('Emergency Contact', profile['emergency_contact'] ?? 'N/As'),
                // Add more fields from the profile map as needed
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}