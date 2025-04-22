import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat.dart';

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  
  List<Chat> get chats => _chats;
  
  List<Chat> get activeChats => _chats.where((chat) => 
    chat.status == ChatStatus.inProgress || 
    chat.status == ChatStatus.pending
  ).toList();

  ChatProvider() {
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = prefs.getString('chats');
      
      if (chatsJson != null) {
        final List<dynamic> decodedChats = json.decode(chatsJson);
        _chats = decodedChats.map((chat) => Chat.fromJson(chat)).toList();
      } else {
        // Load sample data if no chats are found
        _loadSampleChats();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading chats: $e');
      }
      // Load sample data if there's an error
      _loadSampleChats();
      notifyListeners();
    }
  }

  void _loadSampleChats() {
    final now = DateTime.now();
    
    _chats = [
      Chat(
        customerId: '1',
        customerName: 'Brooklyn Simmons',
        customerSpecialty: 'Dermatologist',
        messages: [
          ChatMessage(
            senderId: '1',
            senderName: 'Brooklyn Simmons',
            message: 'Hello, I need information about my sign order.',
            timestamp: now.subtract(const Duration(minutes: 30)),
          ),
          ChatMessage(
            senderId: 'admin',
            senderName: 'Admin',
            message: 'Hi Brooklyn, how can I help you today?',
            timestamp: now.subtract(const Duration(minutes: 25)),
          ),
        ],
        status: ChatStatus.inProgress,
        lastUpdated: now.subtract(const Duration(minutes: 25)),
      ),
      Chat(
        customerId: '2',
        customerName: 'Jacob Jones',
        customerSpecialty: 'Dermatologist',
        messages: [
          ChatMessage(
            senderId: '2',
            senderName: 'Jacob Jones',
            message: 'When will my sign be ready?',
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
        ],
        status: ChatStatus.pending,
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      Chat(
        customerId: '3',
        customerName: 'Kristin Watson',
        customerSpecialty: 'Infectious disease',
        messages: [
          ChatMessage(
            senderId: '3',
            senderName: 'Kristin Watson',
            message: 'Thank you for completing my sign order.',
            timestamp: now.subtract(const Duration(days: 1)),
          ),
          ChatMessage(
            senderId: 'admin',
            senderName: 'Admin',
            message: 'You\'re welcome! We\'re glad you\'re satisfied.',
            timestamp: now.subtract(const Duration(days: 1, hours: 1)),
          ),
        ],
        status: ChatStatus.approved,
        lastUpdated: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      Chat(
        customerId: '4',
        customerName: 'Cody Fisher',
        customerSpecialty: 'Cardiologist',
        messages: [
          ChatMessage(
            senderId: '4',
            senderName: 'Cody Fisher',
            message: 'I need to change the dimensions of my sign.',
            timestamp: now.subtract(const Duration(hours: 5)),
          ),
          ChatMessage(
            senderId: 'admin',
            senderName: 'Admin',
            message: 'I\'ll check if that\'s possible at this stage.',
            timestamp: now.subtract(const Duration(hours: 4)),
          ),
        ],
        status: ChatStatus.inProgress,
        lastUpdated: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  Future<void> _saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    final chatsJson = json.encode(_chats.map((chat) => chat.toJson()).toList());
    await prefs.setString('chats', chatsJson);
  }

  Future<void> addChat(Chat chat) async {
    _chats.add(chat);
    await _saveChats();
    notifyListeners();
  }

  Future<void> updateChat(Chat updatedChat) async {
    final index = _chats.indexWhere((chat) => chat.id == updatedChat.id);
    if (index != -1) {
      _chats[index] = updatedChat;
      await _saveChats();
      notifyListeners();
    }
  }

  Future<void> deleteChat(String id) async {
    _chats.removeWhere((chat) => chat.id == id);
    await _saveChats();
    notifyListeners();
  }

  Future<void> addMessage(String chatId, ChatMessage message) async {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final chat = _chats[index];
      final updatedMessages = [...chat.messages, message];
      _chats[index] = chat.copyWith(
        messages: updatedMessages,
        lastUpdated: message.timestamp,
      );
      await _saveChats();
      notifyListeners();
    }
  }

  Chat? getChatById(String id) {
    try {
      return _chats.firstWhere((chat) => chat.id == id);
    } catch (e) {
      return null;
    }
  }

  Chat? getChatByCustomerId(String customerId) {
    try {
      return _chats.firstWhere((chat) => chat.customerId == customerId);
    } catch (e) {
      return null;
    }
  }
}