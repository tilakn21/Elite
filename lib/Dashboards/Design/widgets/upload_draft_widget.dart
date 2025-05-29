import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class UploadDraftWidget extends StatefulWidget {
  final String? jobId;
  final String? comments;
  
  const UploadDraftWidget({
    Key? key, 
    this.jobId,
    this.comments,
  }) : super(key: key);

  @override
  State<UploadDraftWidget> createState() => UploadDraftWidgetState();
}

class UploadDraftWidgetState extends State<UploadDraftWidget> {
  bool _isDragging = false;
  List<File> _selectedFiles = [];
  bool _loading = false; // Add loading state

  // Expose selected files to parent via a getter
  List<File> get selectedFiles => _selectedFiles;

  // Allow parent to control loading animation
  void setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  // Add this method to clear files from parent
  void clearFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final newFiles = result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
      setState(() {
        _selectedFiles.addAll(newFiles);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                },
                onLeave: (data) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return InkWell(
                    onTap: _pickFiles,
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
                          'Select Design Images',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _isDragging
                                    ? AppTheme.accentColor
                                    : AppTheme.textPrimaryColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag and drop files here or click to browse',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supports multiple images (JPG, PNG, WEBP)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Files (${_selectedFiles.length}):',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: InkWell(
                              onTap: () => _removeFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Images will be uploaded when you click "Submit for Approval"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
