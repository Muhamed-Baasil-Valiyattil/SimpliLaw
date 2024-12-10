import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simplilaw_mobile/auth/firebase_util.dart';
import 'dart:convert';

class GetSummary extends StatefulWidget {
  const GetSummary({super.key});

  @override
  State<GetSummary> createState() => _GetSummaryState();
}

class _GetSummaryState extends State<GetSummary> {
  final TextEditingController _textController = TextEditingController();
  String? _summary;
  bool _isLoading = false;

  Future<void> summarizeText() async {
    if (_textController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Error"),
          content: Text("Input text cannot be empty."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = null;
    });

    try {
      final token = await getFirebaseToken();

      final response =
          await http.post(Uri.parse('http://127.0.0.1:8000/summarize'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode({'text': _textController.text}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final generatedSummary = data['summary'];

        for (int i = 0; i <= generatedSummary.length; i++) {
          await Future.delayed(const Duration(milliseconds: 25));
          setState(() {
            _summary = generatedSummary.substring(0, i);
          });
        }
      } else {
        throw Exception('Failed to generate summary: ${response.body}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Summarize Text"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                      minHeight: 50,
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: "Enter or copy paste text to summarize",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 1.0,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: _isLoading ? null : summarizeText,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_summary != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "Summary",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_summary!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
