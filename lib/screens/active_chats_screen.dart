import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import 'chat_screen.dart';

class ActiveChatsScreen extends StatefulWidget {
  const ActiveChatsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveChatsScreen> createState() => _ActiveChatsScreenState();
}

class _ActiveChatsScreenState extends State<ActiveChatsScreen> with AutomaticKeepAliveClientMixin {
  Chat? _selectedChat;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedChat == null) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    final newMessage = ChatMessage(
      senderId: 'admin',
      senderName: 'Admin',
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );
    
    chatProvider.addMessage(_selectedChat!.id, newMessage);
    
    _messageController.clear();
    
    // Reload chat
    setState(() {
      _selectedChat = chatProvider.getChatById(_selectedChat!.id);
    });
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final chatProvider = Provider.of<ChatProvider>(context);
    final activeChats = chatProvider.activeChats;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      return _buildMobileLayout(activeChats);
    } else {
      return _buildDesktopLayout(activeChats, isDesktop);
    }
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
                          color: AppTheme.textSecondaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active chats',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: activeChats.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: activeChats.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final chat = activeChats[index];
                            return _buildChatListItem(context, chat, onTap: () => _selectChat(chat));
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
                                color: AppTheme.textSecondaryColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select a chat to view the conversation',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                    color: Colors.black.withOpacity(0.05),
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
                                      _selectedChat!.customerName.substring(0, 1),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getChatStatusColor(_selectedChat!.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _getChatStatusText(_selectedChat!.status),
                                      style: TextStyle(
                                        color: _getChatStatusColor(_selectedChat!.status),
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
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _selectedChat!.messages.length,
                                      itemBuilder: (context, index) {
                                        final message = _selectedChat!.messages[index];
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
                                                constraints: BoxConstraints(
                                                  maxWidth: 400,
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      DateFormat('h:mm a').format(message.timestamp),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: isAdmin 
                                                            ? Colors.white.withOpacity(0.7) 
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
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.accentColor,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _sendMessage,
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
      default:
        return 'Active';
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
      default:
        return AppTheme.accentColor;
    }
  }

  Widget _buildChatListItem(BuildContext context, Chat chat, {VoidCallback? onTap}) {
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
      onTap: onTap ?? () {
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
              backgroundColor: Colors.grey[200],
              child: Text(
                chat.customerName.isNotEmpty ? chat.customerName.substring(0, 1) : '?',
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: isMobile ? 11 : 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Status badge - not in Expanded to keep it at its natural size
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _getShortStatusText(chat.status),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
