import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/pages/loginpage.dart';
import 'package:simplilaw_mobile/pages/registerpage.dart';

class LoginOrRegister extends StatefulWidget {
  final bool show;
  const LoginOrRegister({super.key, required this.show});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initially show login page
  late bool showLoginPage;
  @override
  void initState() {
    super.initState();
    showLoginPage = widget.show; // Initialize with the passed value
  }

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
