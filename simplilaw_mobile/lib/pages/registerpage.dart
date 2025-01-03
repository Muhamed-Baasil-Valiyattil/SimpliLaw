// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/auth/authservice.dart';
import 'package:simplilaw_mobile/components/mybutton.dart';
import 'package:simplilaw_mobile/components/mysnackbar.dart';
import 'package:simplilaw_mobile/components/mytextfield.dart';
import 'package:simplilaw_mobile/pages/home.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  Future<void> register(BuildContext context) async {
    final auth = AuthService();
    if (_passwordController.text == _confirmpwController.text) {
      try {
        await auth.signUpWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );
        MySnackBar.show(
          context,
          'Account created successfully!',
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
        if (e.code == 'invalid-email') {
          message = 'Invalid email address.';
        } else if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists with that email.';
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
      } catch (e) {
        MySnackBar.show(
          context,
          "An unexpected error has occured",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          icon: Icons.error,
        );
      }
    } else {
      MySnackBar.show(
        context,
        'Passwords do not match.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        icon: Icons.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 60,
            ),
            const SizedBox(
              height: 50,
            ),
            const Text("Let's create a new account for you"),
            const SizedBox(height: 25),
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(
              height: 10,
            ),
            MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: _confirmpwController),
            const SizedBox(
              height: 25,
            ),
            MyButton(text: "Register", onTap: () => register(context)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 12.5),
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
            GestureDetector(
              onTap: () {
                try {
                  AuthService().signInWithGoogle();
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
                  String mesg = 'Error: ${e.message}';
                  MySnackBar.show(
                    context,
                    mesg,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    icon: Icons.error,
                  );
                }
              },
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
                  "Already have an account? ",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    "Login Now",
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
