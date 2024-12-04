import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/auth/loginorregister.dart';
import 'package:simplilaw_mobile/components/mybutton.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 70,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SimpliLaw',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Simpler. Smarter. Accessible.")
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              MyButton(
                text: "Create Account",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginOrRegister(
                        show: false,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 15,
              ),
              MyButton(
                text: "Already have an Account",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginOrRegister(
                        show: true,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ],
      ),
    );
  }
}
