import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import '../screens/chat_screen.dart';

class ActiveChatsCard extends StatelessWidget {
  final List<Chat> chats;
  final String? designerId;

  const ActiveChatsCard({
    Key? key,
    required this.chats,
    this.designerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Chats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // Navigate to all chats screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            chats.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active chats',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 300, // Fixed height instead of Expanded
                    child: ListView.separated(
                      itemCount: chats.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return _buildChatItem(context, chat);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Chat chat) {
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              customerId: chat.customerId,
              customerName: chat.customerName,
              designerId: designerId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: Text(
                chat.customerName.substring(0, 1),
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
                    chat.customerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    chat.customerSpecialty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                chat.status.toString().split('.').last,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
