import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import '../services/design_service.dart';
import 'chat_screen.dart';
import '../widgets/design_top_bar.dart';
import '../widgets/sidebar.dart';

class ActiveChatsScreen extends StatefulWidget {
  const ActiveChatsScreen({super.key});

  @override
  State<ActiveChatsScreen> createState() => _ActiveChatsScreenState();
}

class _ActiveChatsScreenState extends State<ActiveChatsScreen>
    with AutomaticKeepAliveClientMixin {
  Chat? _selectedChat;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<File> _selectedImages = [];
  bool _showImagePreview = false;
  bool _isUploading = false;
  String? _designerId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectChat(Chat chat) {
    setState(() {
      _selectedChat = chat;
    });

    // Scroll to bottom of messages when chat is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
  Future<void> _sendMessage() async {
    if ((_messageController.text.trim().isEmpty && _selectedImages.isEmpty) || _selectedChat == null) return;

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
            // Continue with other images
            continue;
          }
        }
      }

      final newMessage = ChatMessage(
        senderId: 'admin',
        senderName: 'Admin',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        imageUrls: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
      );

      await chatProvider.addMessage(_selectedChat!.id, newMessage);

      _messageController.clear();
      setState(() {
        _selectedImages.clear();
        _showImagePreview = false;
        _isUploading = false;
      });

      // Reload chat
      setState(() {
        _selectedChat = chatProvider.getChatById(_selectedChat!.id);
      });

      // Scroll to bottom after sending message
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

  @override
  bool get wantKeepAlive => true;

  String _getShortStatusText(ChatStatus status) {
    switch (status) {
      case ChatStatus.approved:
        return 'Approved';
      case ChatStatus.pending:
        return 'Pending';
      case ChatStatus.inProgress:
        return 'In Progress';
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

  @override
  void initState() {
    super.initState();
    _fetchDesignerId();
  }

  Future<void> _fetchDesignerId() async {
    final user = await DesignService().getCurrentUser();
    if (!mounted) return;
    setState(() {
      _designerId = user?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final chatProvider = Provider.of<ChatProvider>(context);
    final activeChats = chatProvider.activeChats;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          const DesignTopBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignSidebar(
                  selectedIndex: 3,
                  onItemTapped: (index) {
                    if (index != 3) {
                      // If not selecting chats again, navigate accordingly
                      switch (index) {
                        case 0:
                          Navigator.of(context).pushReplacementNamed('/design/dashboard');
                          break;
                        case 1:
                          Navigator.of(context).pushReplacementNamed('/design/jobs');
                          break;
                        case 2:
                          Navigator.of(context).pushReplacementNamed('/design/reimbursement');
                          break;
                      }
                    }
                  },
                  employeeId: _designerId,
                ),
                Expanded(
                  child: isMobile 
                    ? _buildMobileLayout(activeChats)
                    : _buildDesktopLayout(activeChats, isDesktop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout methods
  Widget _buildMobileLayout(List<Chat> activeChats) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Active Chats'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: activeChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.textSecondaryColor.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active chats',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: activeChats.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chat = activeChats[index];
                      return _buildChatListItem(
                        context,
                        chat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                customerId: chat.customerId,
                                customerName: chat.customerName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(List<Chat> activeChats, bool isDesktop) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Active chats',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Chat list
                Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: AppTheme.dividerColor),
                    ),
                  ),
                  child: activeChats.isEmpty
                      ? Center(
                          child: Text(
                            'No active chats',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: activeChats.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final chat = activeChats[index];
                            return _buildChatListItem(context, chat,
                                onTap: () => _selectChat(chat));
                          },
                        ),
                ),

                // Right side - Chat content
                Expanded(
                  child: _selectedChat == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color:
                                    AppTheme.textSecondaryColor.withAlpha(128),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select a chat to view the conversation',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Chat header
                            Container(
                              padding: const EdgeInsets.all(16),
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
                                    backgroundColor:
                                        Colors.grey[200]?.withAlpha(255),
                                    child: Text(
                                      _selectedChat!.customerName
                                          .substring(0, 1),
                                      style: const TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedChat!.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          _selectedChat!.customerSpecialty,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getChatStatusColor(
                                              _selectedChat!.status)
                                          .withAlpha(26),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _getChatStatusText(_selectedChat!.status),
                                      style: TextStyle(
                                        color: _getChatStatusColor(
                                            _selectedChat!.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Chat messages
                            Expanded(
                              child: _selectedChat!.messages.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No messages yet. Start the conversation!',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _selectedChat!.messages.length,
                                      itemBuilder: (context, index) {
                                        final message =
                                            _selectedChat!.messages[index];
                                        final isAdmin =
                                            message.senderId == 'admin';                                        return Padding(
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
                                                    _selectedChat!.customerName.substring(0, 1),
                                                    style: const TextStyle(
                                                      color: AppTheme.primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Container(
                                                constraints: BoxConstraints(maxWidth: 400),
                                                decoration: BoxDecoration(
                                                  color: isAdmin
                                                      ? AppTheme.accentColor
                                                      : Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (message.message.isNotEmpty) ...[
                                                      Padding(
                                                        padding: const EdgeInsets.all(12),
                                                        child: Text(
                                                          message.message,
                                                          style: TextStyle(
                                                            color: isAdmin
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    if (message.imageUrls != null &&
                                                        message.imageUrls!.isNotEmpty) ...[
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                        child: Wrap(
                                                          spacing: 8,
                                                          runSpacing: 8,
                                                          children:
                                                              message.imageUrls!.map((url) {
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                border: Border.all(
                                                                  color: Colors.grey[300]!,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(8),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(8),
                                                                child: Image.network(
                                                                  url,
                                                                  height: 150,
                                                                  width: 150,
                                                                  fit: BoxFit.cover,
                                                                  loadingBuilder: (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null) {
                                                                      return child;
                                                                    }
                                                                    return Container(
                                                                      height: 150,
                                                                      width: 150,
                                                                      color: Colors.grey[200],
                                                                      child: Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          value: loadingProgress
                                                                                      .expectedTotalBytes !=
                                                                                  null
                                                                              ? loadingProgress
                                                                                      .cumulativeBytesLoaded /
                                                                                  loadingProgress
                                                                                      .expectedTotalBytes!
                                                                              : null,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  errorBuilder: (context,
                                                                      error, stackTrace) {
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
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                        left: 12,
                                                        right: 12,
                                                        bottom: 8,
                                                      ),
                                                      child: Text(
                                                        DateFormat('h:mm a')
                                                            .format(message.timestamp),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: isAdmin
                                                              ? Colors.white.withAlpha(179)
                                                              : Colors.grey,
                                                        ),
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
                                    ),
                            ),                            // Image preview
                            if (_showImagePreview) Container(
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
                                      onSubmitted: (_) {
                                        if (!_isUploading) _sendMessage();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Send button
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.accentColor,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _isUploading ? null : _sendMessage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getChatStatusText(ChatStatus status) {
    switch (status) {
      case ChatStatus.approved:
        return 'Approved';
      case ChatStatus.pending:
        return 'Pending';
      case ChatStatus.inProgress:
        return 'In Progress';
    }
  }

  Color _getChatStatusColor(ChatStatus status) {
    switch (status) {
      case ChatStatus.approved:
        return AppTheme.approvedColor;
      case ChatStatus.pending:
        return AppTheme.pendingColor;
      case ChatStatus.inProgress:
        return AppTheme.inProgressColor;
    }
  }

  Widget _buildChatListItem(BuildContext context, Chat chat,
      {VoidCallback? onTap}) {
    Color statusColor;

    switch (chat.status) {
      case ChatStatus.approved:
        statusColor = AppTheme.approvedColor;
        break;
      case ChatStatus.pending:
        statusColor = AppTheme.pendingColor;
        break;
      case ChatStatus.inProgress:
        statusColor = AppTheme.inProgressColor;
        break;
    }

    final lastMessage = chat.messages.isNotEmpty
        ? chat.messages.last.message
        : 'No messages yet';

    final lastMessageTime = chat.messages.isNotEmpty
        ? DateFormat('h:mm a').format(chat.messages.last.timestamp)
        : '';

    final isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  customerId: chat.customerId,
                  customerName: chat.customerName,
                ),
              ),
            );
          },
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isMobile ? 16 : 20,
              backgroundColor: Colors.grey[200]?.withAlpha(255),
              child: Text(
                chat.customerName.isNotEmpty
                    ? chat.customerName.substring(0, 1)
                    : '?',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name and status
                  Row(
                    children: [
                      // Name with constrained width
                      Expanded(
                        child: Text(
                          chat.customerName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontSize: isMobile ? 11 : 13,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Status badge - not in Expanded to keep it at its natural size
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _getShortStatusText(chat.status),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontSize: 8,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat.customerSpecialty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isMobile ? 10 : 12,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: isMobile ? 10 : 12,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessageTime.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          lastMessageTime,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 9,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
