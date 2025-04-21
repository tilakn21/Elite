import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class UploadDraftWidget extends StatefulWidget {
  const UploadDraftWidget({Key? key}) : super(key: key);

  @override
  State<UploadDraftWidget> createState() => _UploadDraftWidgetState();
}

class _UploadDraftWidgetState extends State<UploadDraftWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isDragging ? AppTheme.accentColor : AppTheme.dividerColor,
          width: _isDragging ? 2 : 1,
        ),
      ),
      child: DragTarget<String>(
        onWillAccept: (data) {
          setState(() {
            _isDragging = true;
          });
          return true;
        },
        onAccept: (data) {
          setState(() {
            _isDragging = false;
          });
          // Handle file upload logic here
        },
        onLeave: (data) {
          setState(() {
            _isDragging = false;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return InkWell(
            onTap: () {
              // Open file picker
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: _isDragging ? AppTheme.accentColor : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Draft Design',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _isDragging ? AppTheme.accentColor : AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag and drop files here or click to browse',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
