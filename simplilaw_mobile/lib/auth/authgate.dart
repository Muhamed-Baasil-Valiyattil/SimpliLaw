import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/pages/home.dart';
import 'package:simplilaw_mobile/pages/startpage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // user logged in
            if (snapshot.hasData) {
              return const Dashboard();
            } else {
              return const StartPage();
            }
          }),
    );
  }
}
