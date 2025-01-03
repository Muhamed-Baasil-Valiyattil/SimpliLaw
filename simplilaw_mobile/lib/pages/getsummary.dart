import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simplilaw_mobile/auth/firebase_util.dart';
import 'package:simplilaw_mobile/components/mysnackbar.dart';

// Dynamic backend URL
const String backendUrl = "https://formerly-smashing-mastodon.ngrok-free.app";

class GetSummary extends StatefulWidget {
  const GetSummary({super.key});

  @override
  State<GetSummary> createState() => _GetSummaryState();
}

class _GetSummaryState extends State<GetSummary> {
  final TextEditingController _textController = TextEditingController();
  String? _summary;
  bool _isLoading = false;
  PlatformFile? _pickedFile;

  // Method to pick a file using FilePicker
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  // Method to upload the selected file and process it
  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      MySnackBar.show(context, "No file selected to upload.");
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = null;
    });

    try {
      final token = await getFirebaseToken();

      // Preparing a multipart request for file upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/upload'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      // // Using bytes instead of path for web compatibility
      // request.files.add(http.MultipartFile.fromBytes(
      //   'file',
      //   _pickedFile!.bytes!,
      //   filename: _pickedFile!.name,
      // ));
      if (_pickedFile!.bytes != null) {
        // Web: Use bytes
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _pickedFile!.bytes!,
          filename: _pickedFile!.name,
        ));
      } else {
        // Mobile/Desktop: Use file path and stream
        request.files.add(http.MultipartFile(
          'file',
          File(_pickedFile!.path!).openRead(),
          _pickedFile!.size,
          filename: _pickedFile!.name,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final generatedSummary = data['summary'];

        // Displaying the summary character by character
        for (int i = 0; i <= generatedSummary.length; i++) {
          await Future.delayed(const Duration(milliseconds: 25));
          setState(() {
            _summary = generatedSummary.substring(0, i);
          });
        }
      } else {
        throw Exception('Failed to generate summary: $responseBody');
      }
    } catch (e) {
      MySnackBar.show(context, "Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
        _pickedFile = null;
      });
    }
  }

  // Method to summarize input text
  Future<void> summarizeText() async {
    if (_textController.text.isEmpty) {
      MySnackBar.show(context, "Input text is required.");
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = null;
    });

    try {
      final token = await getFirebaseToken();

      // Sending a POST request with input text to summarize
      final response = await http.post(
        Uri.parse('$backendUrl/summarize'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': _textController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final generatedSummary = data['summary'];

        // Displaying the summary character by character
        for (int i = 0; i <= generatedSummary.length; i++) {
          await Future.delayed(const Duration(milliseconds: 25));
          setState(() {
            _summary = generatedSummary.substring(0, i);
          });
        }
      } else {
        throw Exception('Failed to generate summary.');
      }
    } catch (e) {
      MySnackBar.show(context, "Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Upload Documents",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        "Format: (.txt, .docx, .pdf)",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                if (_pickedFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Selected File: ${_pickedFile!.name}"),
                  ),
                if (_pickedFile == null)
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[500],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Select File"),
                  )
                else
                  ElevatedButton(
                    onPressed: _uploadFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Upload"),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey[400],
                    ),
                  ),
                  const Text(
                    " OR ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
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
                      maxLines: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
