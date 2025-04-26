import 'package:flutter/material.dart';
import 'progress_step.dart';
import 'progress_connector.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            ProgressStep(label: 'Received', filled: true),
            ProgressConnector(filled: true),
            ProgressStep(label: 'Cutting', filled: true),
            ProgressConnector(filled: false),
            ProgressStep(label: 'Assembly', filled: false),
            ProgressConnector(filled: false, short: true),
            ProgressStep(label: 'Finishing', filled: false),
          ],
        ),
      ),
    );
  }
}
