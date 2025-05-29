import 'package:uuid/uuid.dart';

enum ChatStatus {
  inProgress,
  pending,
  approved,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;  final String message;
  final DateTime timestamp;
  final bool isRead;
  final List<String>? imageUrls;

  ChatMessage({
    String? id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrls,
  }) : id = id ?? const Uuid().v4();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrls': imageUrls,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls'])
          : null,
    );
  }
}

class Chat {
  final String id;
  final String customerId;
  final String customerName;
  final String customerSpecialty;
  final List<ChatMessage> messages;
  final ChatStatus status;
  final DateTime lastUpdated;

  Chat({
    String? id,
    required this.customerId,
    required this.customerName,
    required this.customerSpecialty,
    required this.messages,
    required this.status,
    required this.lastUpdated,
  }) : id = id ?? const Uuid().v4();

  Chat copyWith({
    String? customerId,
    String? customerName,
    String? customerSpecialty,
    List<ChatMessage>? messages,
    ChatStatus? status,
    DateTime? lastUpdated,
  }) {
    return Chat(
      id: this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerSpecialty: customerSpecialty ?? this.customerSpecialty,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerSpecialty': customerSpecialty,
      'messages': messages.map((message) => message.toJson()).toList(),
      'status': status.toString().split('.').last,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerSpecialty: json['customerSpecialty'],
      messages: (json['messages'] as List)
          .map((message) => ChatMessage.fromJson(message))
          .toList(),
      status: ChatStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ChatStatus.pending,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
