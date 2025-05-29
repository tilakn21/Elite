import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import '../services/design_service.dart'; // Add this import

class ChatScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const ChatScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Chat? _chat;
  List<File> _selectedImages = [];
  bool _showImagePreview = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrCreateChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadOrCreateChat() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Try to find existing chat
    _chat = chatProvider.getChatByCustomerId(widget.customerId);

    // If no chat exists, create a new one
    if (_chat == null) {
      final newChat = Chat(
        customerId: widget.customerId,
        customerName: widget.customerName,
        customerSpecialty: 'Client',
        messages: [],
        status: ChatStatus.inProgress,
        lastUpdated: DateTime.now(),
      );

      chatProvider.addChat(newChat);
      _chat = newChat;
    }

    setState(() {});

    // Scroll to bottom after chat loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
    if ((_messageController.text.trim().isEmpty && _selectedImages.isEmpty) || _chat == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final designService = DesignService();

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload images if any
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        for (var image in _selectedImages) {
          try {
            // Upload each image
            final url = await designService.uploadDraftFile(image);
            if (url != null) {
              uploadedImageUrls.add(url);
            }
          } catch (e) {
            print('Error uploading image: $e');
            // Continue with other images
            continue;
          }
        }
      }

      // Create and send message
      final newMessage = ChatMessage(
        senderId: 'admin',
        senderName: 'Admin',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        imageUrls: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
      );

      await chatProvider.addMessage(_chat!.id, newMessage);

      // Clear input and images
      _messageController.clear();
      setState(() {
        _selectedImages.clear();
        _showImagePreview = false;
        _isUploading = false;
      });

      // Reload chat and scroll to bottom
      setState(() {
        _chat = chatProvider.getChatById(_chat!.id);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildImagePreview() {
    if (!_showImagePreview || _selectedImages.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImages[index],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required DateTime time,
    required bool isAdmin,
    List<String>? imageUrls,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: Text(
                widget.customerName.substring(0, 1),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin ? AppTheme.accentColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isAdmin ? null : Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isNotEmpty) ...[
                    Text(
                      message,
                      style: TextStyle(
                        color: isAdmin ? Colors.white : AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (imageUrls != null && imageUrls.isNotEmpty)
                      const SizedBox(height: 8),
                  ],
                  if (imageUrls != null && imageUrls.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: imageUrls.map((url) => Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 150,
                                width: 150,
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
                              return Container(
                                height: 150,
                                width: 150,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    DateFormat('h:mm a').format(time),
                    style: TextStyle(
                      fontSize: 10,
                      color: isAdmin
                          ? Colors.white.withAlpha(179)
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: Text(
                widget.customerName.substring(0, 1),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd MMM, HH:mm').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _chat == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chat messages
                Expanded(
                  child: _chat!.messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet. Start the conversation!',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _chat!.messages.length,
                          itemBuilder: (context, index) {
                            final message = _chat!.messages[index];
                            final isAdmin = message.senderId == 'admin';

                            return _buildMessageBubble(
                              message: message.message,
                              time: message.timestamp,
                              isAdmin: isAdmin,
                              imageUrls: message.imageUrls,
                            );
                          },
                        ),
                ),

                // Image preview
                _buildImagePreview(),

                // Message input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppTheme.dividerColor),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Attachment button
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _isUploading ? null : _pickImages,
                        color: AppTheme.primaryColor,
                        tooltip: 'Attach images',
                      ),
                      const SizedBox(width: 8),
                      // Message input field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isUploading,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Write a message...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _isUploading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.white,
                          onPressed: _isUploading ? null : _sendMessage,
                          tooltip: 'Send message',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
