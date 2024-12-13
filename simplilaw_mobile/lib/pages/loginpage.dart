// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/auth/authservice.dart';
import 'package:simplilaw_mobile/components/mybutton.dart';
import 'package:simplilaw_mobile/components/mysnackbar.dart';
import 'package:simplilaw_mobile/components/mytextfield.dart';
import 'package:simplilaw_mobile/pages/home.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});
  Future<void> login(BuildContext context) async {
    // auth service
    final auth = AuthService();
    try {
      await auth.signInWithEmailPassword(
        emailController.text,
        passwordController.text,
      );

      MySnackBar.show(
        context,
        'Login Succes',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        icon: Icons.check_circle,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        message = 'Invalid login credentials.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email';
      } else {
        message = 'Error: ${e.message}';
      }
      MySnackBar.show(
        context,
        message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }
  }

  Future<void> googlelogin(BuildContext context) async {
    try {
      await AuthService().signInWithGoogle();

      MySnackBar.show(
        context,
        'Login Success',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        icon: Icons.check_circle,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String mesg = 'Error: ${e.message}';
      MySnackBar.show(
        context,
        mesg,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    } catch (e) {
      String mesg = e.toString();
      MySnackBar.show(
        context,
        mesg,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // logo
          children: [
            const Icon(Icons.person, size: 60),
            const SizedBox(
              height: 40,
            ),
            const Text("Welcome back, you've been missed!"),
            const SizedBox(height: 25),
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: emailController,
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: passwordController,
            ),
            const SizedBox(height: 25),
            MyButton(
              text: "Login",
              onTap: () => login(context),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[400],
                    ),
                  ),
                  const Text(
                    " Or ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () => googlelogin(context),
              child: Container(
                height: 50,
                constraints: const BoxConstraints(
                  minWidth: 200,
                  maxWidth: 250,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('lib/images/google.png', height: 30),
                      const SizedBox(width: 10),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    "Register Now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
