import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simplilaw_mobile/auth/authservice.dart';
import 'package:simplilaw_mobile/pages/startpage.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<void> logout(BuildContext context) async {
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
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => logout(context), icon: const Icon(Icons.logout))
        ],
      ),
    );
  }
}
