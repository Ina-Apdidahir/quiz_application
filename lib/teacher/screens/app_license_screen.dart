
// app_license_screen.dart
import 'package:flutter/material.dart';

class AppLicensePage extends StatelessWidget {
  const AppLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App License"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "License Agreement for Puntland State University Quiz App",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Last Updated: August 28, 2025",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(context, "1. Acceptance of Terms"),
              const Text(
                "By downloading or using the Puntland State University Quiz App, you agree to be bound by the terms and conditions of this License Agreement. If you do not agree, do not use the application.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              _buildSectionTitle(context, "2. User Rights and Restrictions"),
              const Text(
                "This app is provided for educational use by the Puntland State University community. You are granted a non-exclusive, non-transferable, revocable license to use the app for its intended purpose. You may not:",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 5),
              _buildListItem("Redistribute, sell, rent, lease, or sublicense the application."),
              _buildListItem("Modify, decompile, reverse engineer, or create derivative works of the application."),
              _buildListItem("Use the app for any illegal or unauthorized purpose."),
              _buildSectionTitle(context, "3. Intellectual Property"),
              const Text(
                "The application, including all intellectual property rights, remains the property of Puntland State University. All content created by teachers remains their intellectual property, though a license is granted for use within the app.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              _buildSectionTitle(context, "4. Limitation of Liability"),
              const Text(
                "The application is provided 'as is' without any warranties, express or implied. The developers and Puntland State University are not liable for any damages, data loss, or other issues arising from the use of this app.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              _buildSectionTitle(context, "5. Third-Party Licenses"),
              const Text(
                "This application may include open-source packages and libraries licensed under their respective terms, including but not limited to MIT and Apache 2.0 licenses.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
