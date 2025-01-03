import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard support
import 'package:share_plus/share_plus.dart'; // For sharing
import 'package:pdf/widgets.dart' as pw; // For PDF generation
import 'package:path_provider/path_provider.dart'; // To store PDF temporarily
import 'dart:io';

import 'package:simplilaw_mobile/components/mysnackbar.dart';

class SummaryCard extends StatefulWidget {
  final String inputText;
  final String summaryText;
  final VoidCallback onClose;

  const SummaryCard({
    super.key,
    required this.inputText,
    required this.summaryText,
    required this.onClose,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  Future<void> _downloadAsPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Input Text:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(widget.inputText),
            pw.SizedBox(height: 20),
            pw.Text("Summary:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(widget.summaryText),
          ],
        ),
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/summary.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF downloaded successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
        ),

        // Floating card
        Center(
          child: Card(
            elevation: 8.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: widget.summaryText));

                              MySnackBar.show(
                                context,
                                "Copied to clipboard",
                                backgroundColor: Colors.black,
                                icon: Icons.copy_outlined,
                              );
                            },
                            icon: const Icon(Icons.copy),
                          ),
                          IconButton(
                            onPressed: _downloadAsPDF,
                            icon: const Icon(Icons.picture_as_pdf),
                          ),
                          IconButton(
                            onPressed: () {
                              Share.share(widget.summaryText,
                                  subject: "Generated Summary");
                            },
                            icon: const Icon(Icons.share),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Input Text:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.inputText),
                            const Divider(),
                            const Text(
                              "Summary:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.summaryText),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Quick Actions
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
