import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/job_provider.dart';
import '../providers/chat_provider.dart';
import '../models/job.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import '../widgets/upload_draft_widget.dart';
import '../services/design_service.dart';
import 'chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({
    Key? key,
    required this.jobId,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _notesController = TextEditingController();
  final _commentsController = TextEditingController();
  final _measurementsController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  final GlobalKey<UploadDraftWidgetState> _uploadDraftKey = GlobalKey<UploadDraftWidgetState>();
  Job? _job;
  Chat? _activeChat;
  bool _isEditingDetails = false;
  bool _showChatPanel = false;
  List<File> _selectedImages = [];
  bool _showImagePreview = false;
  bool _isUploading = false;

  // Status tracking
  double _progressValue = 0.0;
  String _progressStatus = 'Not Started';
  String _estimatedCompletion = 'N/A';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobDetails();
      _loadActiveChat();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _commentsController.dispose();
    _measurementsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadJobDetails() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final Job? nullableJob = jobProvider.getJobById(widget.jobId);

    if (nullableJob == null) {
      // Handle the case where job is not found
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job with ID ${widget.jobId} not found.')),
        );
        // Optionally navigate back or show an error UI
        Navigator.of(context).pop();
      }
      return;
    }
    // If we reach here, nullableJob is not null.
    final Job job = nullableJob;

    setState(() {
      _job = job;      _notesController.text = job.notes ?? "";
      _addressController.text = job.address; // job.address is non-nullable
      _phoneController.text = job.phoneNumber; // phoneNumber is non-nullable
      _measurementsController.text = job.measurements ?? "";

      // Set progress based on status
      switch (job.status) {
        case JobStatus.inProgress:
          _progressValue = 0.3;
          _progressStatus = 'In Progress';
          _estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(DateTime.now().add(const Duration(days: 14)));
          break;
        case JobStatus.pending:
          _progressValue = 0.7;
          _progressStatus = 'Pending Approval';
          _estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(DateTime.now().add(const Duration(days: 7)));
          break;
        case JobStatus.approved:
          _progressValue = 1.0;
          _progressStatus = 'Completed';
          _estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(DateTime.now().subtract(const Duration(days: 2)));
          break;
      }
    });
  }

  void _loadActiveChat() {
    if (_job == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chat = chatProvider.getChatByCustomerId(_job!.id);

    if (chat != null) {
      setState(() {
        _activeChat = chat;
      });
    }
  }

  void _updateJobStatus(JobStatus status) {
    if (_job != null) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final updatedJob = _job!.copyWith(
        status: status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        measurements: _measurementsController.text.isEmpty
            ? null
            : _measurementsController.text,
      );

      jobProvider.updateJob(updatedJob);
      setState(() {
        _job = updatedJob;

        // Update progress based on new status
        switch (status) {
          case JobStatus.inProgress:
            _progressValue = 0.3;
            _progressStatus = 'In Progress';
            _estimatedCompletion = DateFormat('dd/MM/yyyy')
                .format(DateTime.now().add(const Duration(days: 14)));
            break;
          case JobStatus.pending:
            _progressValue = 0.7;
            _progressStatus = 'Pending Approval';
            _estimatedCompletion = DateFormat('dd/MM/yyyy')
                .format(DateTime.now().add(const Duration(days: 7)));
            break;
          case JobStatus.approved:
            _progressValue = 1.0;
            _progressStatus = 'Completed';
            _estimatedCompletion =
                DateFormat('dd/MM/yyyy').format(DateTime.now());
            break;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job status updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }  Future<void> _submitForApproval() async {
    if (_job == null) return;

    // Check if comments are empty
    if (_commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add comments before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if files are selected
    final files = _uploadDraftKey.currentState?.selectedFiles ?? [];
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file to upload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading overlay in UploadDraftWidget
    _uploadDraftKey.currentState?.setLoading(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Submitting designs and comments for approval...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );
    try {
      // Upload images from UploadDraftWidget
      final files = _uploadDraftKey.currentState?.selectedFiles ?? [];
      final List<String> uploadedUrls = [];
      for (final file in files) {
        final url = await DesignService().uploadDraftFile(file);
        if (url != null) uploadedUrls.add(url);
      }
      // Prepare new draft data
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final newDraft = {
        'comments': _commentsController.text,
        'submission_date': dateStr,
        'submission_time': timeStr,
        'status': 'pending_approval',
        'images': uploadedUrls, // Store as List<String>
      };
      // Append new draft to design JSONB (as sub-event)
      await DesignService().updateJobDesignData(_job!.id, newDraft);
      // Update the status column in jobs table to 'design'
      final supabase = Supabase.instance.client;
      await supabase.from('jobs').update({'status': 'design'}).eq('id', _job!.id);
      setState(() {
        _job = _job!.copyWith(status: JobStatus.inProgress);
      });
      _uploadDraftKey.currentState?.clearFiles();
      _commentsController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design submitted for approval successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting design: \\${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _uploadDraftKey.currentState?.setLoading(false);
    }
  }

  void _approveJob() {
    _updateJobStatus(JobStatus.approved);
  }

  void _setInProgress() {
    _updateJobStatus(JobStatus.inProgress);
  }

  void _toggleChatPanel() {
    setState(() {
      _showChatPanel = !_showChatPanel;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditingDetails = !_isEditingDetails;
    });
  }

  void _openChatWithCustomer() {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    if (_job != null) {
      if (isDesktop) {
        // On desktop, toggle the side panel
        _toggleChatPanel();
      } else {
        // On mobile, navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              customerId: _job!.id,
              customerName: _job!.clientName,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            result.files.where((file) => file.path != null).map((file) => File(file.path!)),
          );
          _showImagePreview = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _showImagePreview = false;
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_job == null) return;
    if (_messageController.text.trim().isEmpty && _selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final designService = DesignService();

      // Upload images if any
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        for (var image in _selectedImages) {
          try {
            final url = await designService.uploadDraftFile(image);
            if (url != null) {
              uploadedImageUrls.add(url);
            }
          } catch (e) {
            print('Error uploading image: $e');
            continue;
          }
        }
      }

      // Create chat if it doesn't exist
      if (_activeChat == null) {
        final newChat = Chat(
          customerId: _job!.id,
          customerName: _job!.clientName,
          customerSpecialty: 'Client',
          messages: [],
          status: ChatStatus.inProgress,
          lastUpdated: DateTime.now(),
        );
        chatProvider.addChat(newChat);
        _activeChat = newChat;
      }

      // Send message with images
      final message = ChatMessage(
        senderId: 'admin',
        senderName: 'Admin',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        imageUrls: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
      );

      await chatProvider.addMessage(_activeChat!.id, message);
      
      // Clear input and reset state
      _messageController.clear();
      setState(() {
        _selectedImages.clear();
        _showImagePreview = false;
        _isUploading = false;
        _activeChat = chatProvider.getChatById(_activeChat!.id);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_job == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Job (${_job?.id ?? ''})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isDesktop || !_showChatPanel)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: _openChatWithCustomer,
              tooltip: 'Chat with customer',
            ),
          IconButton(
            icon: Icon(_isEditingDetails ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditingDetails ? 'Save changes' : 'Edit details',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'approve':
                  _approveJob();
                  break;
                case 'pending':
                  _submitForApproval();
                  break;
                case 'progress':
                  _setInProgress();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'approve',
                child: Text('Mark as Approved'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Mark as Pending'),
              ),
              const PopupMenuItem(
                value: 'progress',
                child: Text('Mark as In Progress'),
              ),
            ],
          ),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout()
          : isTablet
              ? _buildTabletLayout()
              : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area
        Expanded(
          flex: _showChatPanel ? 2 : 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobHeader(),
                const SizedBox(height: 28),
                // Site Visit Images section
                _buildSiteVisitImages(),
                const SizedBox(height: 28),
                // Site Visit Data at the top
                _buildSiteVisitData(),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobProgress(),
                          const SizedBox(height: 28),
                          _buildUploadDraftDesign(),
                          const SizedBox(height: 28),
                          _buildComments(),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _submitForApproval,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text(
                                    'Submit for Approval',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    // Right column: Customer and Salesperson info at the bottom
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerInformation(),
                          const SizedBox(height: 28),
                          _buildSalespersonInformation(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Chat panel (only shown when _showChatPanel is true)
        if (_showChatPanel)
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Chat header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          _job!.clientName.substring(0, 1),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _job!.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _job!.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleChatPanel,
                      ),
                    ],
                  ),
                ),

                // Chat messages
                Expanded(
                  child: _activeChat != null && _activeChat!.messages.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _activeChat!.messages.length,
                          itemBuilder: (context, index) {
                            final message = _activeChat!.messages[index];
                            final isAdmin = message.senderId == 'admin';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: isAdmin
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isAdmin) ...[
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[200],
                                      child: Text(
                                        _job!.clientName.substring(0, 1),
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 250,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? AppTheme.accentColor
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.message,
                                          style: TextStyle(
                                            color: isAdmin
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('h:mm a')
                                              .format(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isAdmin
                                                ? Colors.white.withAlpha(179)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin) ...[
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.accentColor,
                                      child: const Text(
                                        'A',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                ),

                // Message input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.accentColor,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 24),
          // Site Visit Images section
          _buildSiteVisitImages(),
          const SizedBox(height: 24),
          // Site Visit Data at the top
          _buildSiteVisitData(),
          const SizedBox(height: 24),
          _buildJobProgress(),
          const SizedBox(height: 24),
          _buildUploadDraftDesign(),
          const SizedBox(height: 24),
          _buildComments(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForApproval,
                  icon: const Icon(Icons.upload_file),
                  label: const Text(
                    'Submit for Approval',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Customer and Salesperson info at the bottom
          _buildCustomerInformation(),
          const SizedBox(height: 24),
          _buildSalespersonInformation(),
        ],
      ),
    );
  }
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 20),
          // Site Visit Images section
          _buildSiteVisitImages(),
          const SizedBox(height: 20),
          // Site Visit Data at the top
          _buildSiteVisitData(),
          const SizedBox(height: 20),
          _buildJobProgress(),
          const SizedBox(height: 20),
          _buildUploadDraftDesign(),
          const SizedBox(height: 20),
          _buildComments(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForApproval,
                  icon: const Icon(Icons.upload_file),
                  label: const Text(
                    'Submit for Approval',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Customer and Salesperson info at the bottom
          _buildCustomerInformation(),
          const SizedBox(height: 16),
          _buildSalespersonInformation(),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Job Details',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_job!.status).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(_job!.status),
                style: TextStyle(
                  color: _getStatusColor(_job!.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Created on ${DateFormat('dd MMM yyyy').format(_job!.dateAdded)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ],
    );
  }
  Widget _buildJobProgress() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Job Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey[200],
              color: AppTheme.accentColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressItem('Status', _progressStatus),
                _buildProgressItem(
                    'Estimated Completion', _estimatedCompletion),
                _buildProgressItem('Job Number', _job!.jobNo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
  Widget _buildCustomerInformation() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Client Name', _job!.clientName),
            const SizedBox(height: 12),
            _buildInfoRow('Phone no.', _job!.phoneNumber),
            const SizedBox(height: 12),
            _buildInfoRow('Address', _job!.address),
          ],
        ),
      ),
    );
  }
  Widget _buildSalespersonInformation() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business_center_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Assigned Salesperson Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', 'Jane Smith'),
            const SizedBox(height: 12),
            _buildInfoRow('Phone no.', '+123 456-7890'),
          ],
        ),
      ),
    );
  }  Widget _buildSiteVisitData() {
    final Map<String, dynamic> salespersonData = _job?.salespersonData ?? {};

    // Helper to get a value or fallback
    String getField(String key, [String fallback = '-']) {
      final value = salespersonData[key];
      if (value == null || (value is String && value.trim().isEmpty)) return fallback;
      return value.toString();
    }

    // Fields to exclude
    const excludedFields = {'customer', 'paymentAmount', 'salespersonId', 'imageUrl', 'images'};

    // Build info rows for all fields except excluded and image URLs
    final infoRows = <Widget>[];
    
    // Sort keys alphabetically for better organization
    final sortedKeys = salespersonData.keys.where((key) => 
      !excludedFields.contains(key) && 
      !(salespersonData[key] is String && 
        (salespersonData[key] as String).startsWith('http') && 
        RegExp(r'\.(jpg|jpeg|png|webp|gif)$', caseSensitive: false).hasMatch(salespersonData[key]))
    ).toList()..sort();
    
    // Process sorted keys
    for (var key in sortedKeys) {
      var value = salespersonData[key];
      
      // Handle date and time separation
      if (key.toLowerCase().contains('date') && value is String && value.contains(' ') && value.length > 10) {
        // This could be a datetime string, try to split it
        try {
          final parts = value.split(' ');
          if (parts.length >= 2) {
            final dateStr = parts[0];
            final timeStr = parts.sublist(1).join(' ');
            
            infoRows.add(_buildInfoRow(
              '${_beautifyKey(key)} (Date)', 
              dateStr,
              icon: Icons.calendar_today_outlined,
            ));
            infoRows.add(const SizedBox(height: 12));
            infoRows.add(_buildInfoRow(
              '${_beautifyKey(key)} (Time)', 
              timeStr,
              icon: Icons.access_time,
            ));
            infoRows.add(const Divider(height: 24));
          } else {
            infoRows.add(_buildInfoRow(_beautifyKey(key), getField(key)));
            infoRows.add(const Divider(height: 24));
          }
        } catch (e) {
          // If parsing fails, just display as is
          infoRows.add(_buildInfoRow(_beautifyKey(key), getField(key)));
          infoRows.add(const Divider(height: 24));
        }
      } else {
        // Add appropriate icons based on field type
        IconData? fieldIcon;
        if (key.toLowerCase().contains('name')) {
          fieldIcon = Icons.person_outline;
        } else if (key.toLowerCase().contains('phone') || key.toLowerCase().contains('contact')) {
          fieldIcon = Icons.phone_outlined;
        } else if (key.toLowerCase().contains('email')) {
          fieldIcon = Icons.email_outlined;
        } else if (key.toLowerCase().contains('address')) {
          fieldIcon = Icons.location_on_outlined;
        } else if (key.toLowerCase().contains('note') || key.toLowerCase().contains('comment')) {
          fieldIcon = Icons.description_outlined;
        } else if (key.toLowerCase().contains('price') || key.toLowerCase().contains('cost') || key.toLowerCase().contains('amount')) {
          fieldIcon = Icons.attach_money;
        }
        
        infoRows.add(_buildInfoRow(_beautifyKey(key), getField(key), icon: fieldIcon));
        // Use divider instead of simple spacing for better visual separation
        if (sortedKeys.last != key) {
          infoRows.add(const Divider(height: 24));
        }
      }
    }

    if (infoRows.isEmpty) {
      infoRows.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No site visit data available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        )
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text('Site Visit Data', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ],
            ),
            const SizedBox(height: 24),
            ...infoRows,
          ],
        ),
      ),
    );
  }  Widget _buildSiteVisitImages() {
    final Map<String, dynamic> salespersonData = _job?.salespersonData ?? {};
    final List<String> imageUrls = [];
      // Check if there's an images array in the salesperson data
    if (salespersonData.containsKey('images') && salespersonData['images'] != null) {
      // Handle images as an array
      if (salespersonData['images'] is List) {
        for (var imageUrl in salespersonData['images']) {
          if (imageUrl is String && imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
            print('Found image URL from images array: $imageUrl');
          }
        }
      } 
      // Handle images as a comma-separated string (used by UploadDraftWidget)
      else if (salespersonData['images'] is String && salespersonData['images'].isNotEmpty) {
        if (salespersonData['images'].contains(',')) {
          // Split the comma-separated string into individual URLs
          final urlsList = salespersonData['images'].split(',');
          for (var url in urlsList) {
            if (url.trim().isNotEmpty) {
              imageUrls.add(url.trim());
              print('Found image URL from comma-separated string: $url');
            }
          }
        } else {
          // It's a single URL string
          imageUrls.add(salespersonData['images']);
          print('Found single image URL from images: ${salespersonData['images']}');
        }
      }
    }
    
    // Also look for any other image URLs in other fields as a fallback
    salespersonData.forEach((key, value) {
      if (key != 'images' && value is String && 
          (value.startsWith('https://') || value.startsWith('http://')) && 
          RegExp(r'\.(jpg|jpeg|png|webp|gif)', caseSensitive: false).hasMatch(value)) {
        imageUrls.add(value);
        print('Found image URL from field $key: $value');
      }
    });
    
    // If no images are found, show a "No site images" message
    if (imageUrls.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.collections_outlined, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text('Site Visit Images', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No site images available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.collections_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text('Site Visit Images', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Increased height for better visibility
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrls[index],
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 200,
                                height: 150,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / 
                                          loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return _buildImagePlaceholder();
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Site Image ${index + 1}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildUploadDraftDesign() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_file_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Upload Draft Design',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),            const SizedBox(height: 16),
            UploadDraftWidget(
              key: _uploadDraftKey,
              jobId: widget.jobId,
              comments: _commentsController.text,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildComments() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.comment_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),            TextField(
              controller: _commentsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    Color? valueBackground,
    IconData? icon,
  }) {
    final valueWidget = valueBackground != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: valueBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                  ),
            ),
          )
        : Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                ),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  '$label -',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: valueWidget),
      ],
    );
  }
  Widget _buildImagePlaceholder() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return 'Approved';
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.inProgress:
        return 'In progress';
    }
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return AppTheme.approvedColor;
      case JobStatus.pending:
        return AppTheme.pendingColor;
      case JobStatus.inProgress:
        return AppTheme.inProgressColor;
    }
  }

  String _beautifyKey(String key) {
    // Convert camelCase or snake_case to Title Case for labels
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ' + m.group(0)!)
        .replaceAll('_', ' ')
        .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
  }
}
