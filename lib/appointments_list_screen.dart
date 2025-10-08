import 'package:flutter/material.dart';

// A placeholder screen to show lists of appointments (e.g., all pending or completed)
class AppointmentsListScreen extends StatelessWidget {
  final String title;

  const AppointmentsListScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'A detailed list of all "$title" will appear here. This page would fetch and display all relevant data from your backend.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
