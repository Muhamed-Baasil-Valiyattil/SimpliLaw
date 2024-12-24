import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simplilaw_mobile/auth/authservice.dart';
import 'package:simplilaw_mobile/pages/startpage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final auth = AuthService();
    try {
      auth.signout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StartPage()),
      );
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // Account Management Section
          const ListTile(
            title: Text("Account"),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: () => _signOut(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Colors.grey.shade400,
            ),
          ),

          // Theme Toggle
          const ListTile(
            title: Text("Appearance"),
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text("Light Mode"),
            trailing: Switch(
              value: true, // Replace with actual theme state
              onChanged: (bool value) {
                // Implement theme toggle logic
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Colors.grey.shade400,
            ),
          ),

          // Notifications
          const ListTile(
            title: Text("Preferences"),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Enable Notifications"),
            trailing: Switch(
              value: true, // Replace with actual notification state
              onChanged: (bool value) {
                // Implement notification toggle logic
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text("Clear Cache"),
            onTap: () {
              // Clear cache logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cache cleared!")),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Colors.grey.shade400,
            ),
          ),

          // About Section
          const ListTile(
            title: Text("About"),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Version 1.0.0"),
            onTap: () {
              // Show version info dialog
              showAboutDialog(
                context: context,
                applicationName: "SimpliLaw",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.gavel),
                children: [
                  const Text("Simpler. Smarter. Accessible."),
                  const Text("Developed by Group 1."),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
