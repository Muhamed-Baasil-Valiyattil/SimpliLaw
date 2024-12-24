import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplilaw_mobile/pages/summarycard.dart';

class SummariesList extends StatefulWidget {
  const SummariesList({super.key});

  @override
  State<SummariesList> createState() => _SummariesListState();
}

class _SummariesListState extends State<SummariesList> {
  bool _showSummaryCard = false;
  String _selectedInputText = "";
  String _selectedSummaryText = "";

  void _toggleSummaryCard(String inputText, String summaryText) {
    setState(() {
      _showSummaryCard = !_showSummaryCard;
      _selectedInputText = inputText;
      _selectedSummaryText = summaryText;
    });
  }

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

        return Stack(
          children: [
            ListView.builder(
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
                    onTap: () => _toggleSummaryCard(inputText, summaryText),
                  ),
                );
              },
            ),
            if (_showSummaryCard)
              SummaryCard(
                  inputText: _selectedInputText,
                  summaryText: _selectedSummaryText,
                  onClose: () => setState(() => _showSummaryCard = false))
          ],
        );
      },
    );
  }
}
