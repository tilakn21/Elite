import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../services/design_service.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // No longer used directly
// import 'dart:convert'; // No longer used directly

class ChatProvider with ChangeNotifier {
  final DesignService _designService;
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Chat> get activeChats => _chats
      .where((chat) =>
          chat.status == ChatStatus.inProgress ||
          chat.status == ChatStatus.pending)
      .toList();

  ChatProvider(this._designService) {
    _fetchChats(); // Renamed from _loadChats
  }

  Future<void> _fetchChats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _chats = await _designService.getChats();
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error fetching chats from service: $e');
      }
      _loadSampleChats(); // Fallback to sample data
    } finally {
      _isLoading = false;
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
        isOnline: true,
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
        isOnline: false,
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
        isOnline: false,
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
        isOnline: true,
      ),
    ];
  }

  Future<void> addChat(Chat chat) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newChat = await _designService.createChat(chat);
      _chats.add(newChat);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error adding chat via service: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateChat(Chat updatedChat) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final returnedChat = await _designService.updateChat(updatedChat);
      final index = _chats.indexWhere((chat) => chat.id == returnedChat.id);
      if (index != -1) {
        _chats[index] = returnedChat;
      } else {
        print(
            'ChatProvider: Updated chat ID ${returnedChat.id} not found in local list.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error updating chat via service: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteChat(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _designService.deleteChat(id);
      _chats.removeWhere((chat) => chat.id == id);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error deleting chat via service: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMessage(String chatId, ChatMessage message) async {
    // Note: This operation might be more complex with a real backend.
    // For instance, the backend might handle adding the message and updating the chat's lastUpdated time.
    // The provider would then fetch the updated chat or just the new message.
    // For this mock, we'll simulate adding locally after a service call for the message.
    _isLoading = true;
    _errorMessage = null;
    // We don't notify listeners immediately for isLoading here, as it's a sub-operation on an existing chat.
    // UI updates for this might be handled differently (e.g., optimistic update).
    try {
      final newMessage = await _designService.addMessageToChat(chatId, message);
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        final chat = _chats[index];
        final updatedMessages = [...chat.messages, newMessage];
        _chats[index] = chat.copyWith(
          messages: updatedMessages,
          lastUpdated: newMessage
              .timestamp, // Or use server-provided timestamp if different
          status: ChatStatus.inProgress, // Potentially update status
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error adding message via service: $e');
      }
    } finally {
      // _isLoading = false; // Might not be needed if not globally set for this op
      notifyListeners(); // Notify that chat list (specifically one chat) has changed
    }
  }

  Future<void> refreshChats() async {
    await _fetchChats();
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
