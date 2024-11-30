import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/auth/authservice.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  void logout() {
    final auth = AuthService();
    auth.signout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
    );
  }
}
