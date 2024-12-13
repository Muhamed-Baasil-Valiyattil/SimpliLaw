import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simplilaw_mobile/auth/authservice.dart';
import 'package:simplilaw_mobile/pages/getsummary.dart';
import 'package:simplilaw_mobile/pages/settings.dart';
import 'package:simplilaw_mobile/pages/startpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplilaw_mobile/pages/summarydetails.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

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
    final List<Widget> pages = [
      _SummariesList(), // Home
      const GetSummary(), // Create Summary
      const SettingsPage(), // Settings
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => logout(context), icon: const Icon(Icons.logout))
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Create Summary",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

// Widget to display a list of summaries
class _SummariesList extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("Please log in to view summaries."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("summaries")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No summaries found."));
        }

        final summaries = snapshot.data!.docs;

        return ListView.builder(
          itemCount: summaries.length,
          itemBuilder: (context, index) {
            final summary = summaries[index];
            final inputText = summary['input_text'] as String;
            final summaryText = summary['summary_text'] as String;

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  inputText.length > 50
                      ? "${inputText.substring(0, 50)}..."
                      : inputText,
                ),
                subtitle: Text(
                  summaryText.length > 50
                      ? "${summaryText.substring(0, 50)}..."
                      : summaryText,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryDetails(
                        inputText: inputText,
                        summaryText: summaryText,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
