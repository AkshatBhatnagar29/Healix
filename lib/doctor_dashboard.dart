import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'profile_screen.dart'; // Import the profile screen

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Kept center alignment
          children: [
            const Icon(Icons.medical_services, color: Colors.teal, size: 60),
            const SizedBox(height: 30),

            // --- Status Text ---
            Text(
              apiService.isAvailable
                  ? '🟢 You are currently ONLINE'
                  : '🔴 You are currently OFFLINE',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            // --- Simple Availability Button ---
            apiService.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: apiService.isAvailable
                    ? Colors.redAccent
                    : Colors.green,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                apiService.isAvailable
                    ? Icons.logout
                    : Icons.login,
                color: Colors.white,
              ),
              label: Text(
                apiService.isAvailable ? 'Go Offline' : 'Go Online',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await apiService.setAvailability(!apiService.isAvailable);
              },
            ),

            const SizedBox(height: 20), // Added spacing

            // --- Profile Button ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Distinct color
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              label: const Text(
                'View Profile',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // --- Active SOS Alert Section ---
            if (apiService.activeSosEventId != null)
              Card(
                color: Colors.red[100],
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '🚨 Active SOS Alert!',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Event ID: ${apiService.activeSosEventId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          apiService.clearSosAlert();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Dismiss Alert'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}