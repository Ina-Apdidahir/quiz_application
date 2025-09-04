import 'package:flutter/material.dart';
import 'package:quiz_application/teacher/screens/app_license_screen.dart';
import 'package:quiz_application/teacher/screens/app_setting_screen.dart';
import 'package:quiz_application/teacher/screens/developer_info_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        children: [
          // _buildSettingItem(
          //   context,
          //   icon: Icons.info,
          //   title: "About Us",
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (_) => const AboutUsPage()),
          //   ),
          // ),
          _buildSettingItem(
            context,
            icon: Icons.article,
            title: "App License",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppLicensePage()),
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.developer_mode,
            title: "Developer Info",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeveloperInfoPage()),
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.settings,
            title: "App Settings",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppSettingsPage()),
            ),
          ),
          const Divider(),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context,
      {required IconData icon,
      required String title,
      Color? color,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual logout logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
