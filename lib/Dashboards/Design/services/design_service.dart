// lib/Dashboards/Design/services/design_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job.dart';
import '../models/chat.dart'; // Added Chat model import
import '../models/user.dart' as app; // Added User model import with alias

class DesignService {
  // Mock base URL - replace with actual API endpoint
  // static const String _baseUrl = 'https://api.example.com/design';

  Future<List<Job>> getJobs() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('jobs')
          .select()
          .not('salesperson', 'is', null);
      
      // Map each job from Supabase to the Job model
      return List<Map<String, dynamic>>.from(response)
          .map((json) => Job.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching jobs from Supabase: $e');
      // Re-throw the error to let the provider handle it
      throw Exception('Failed to fetch jobs from database: $e');
    }
  }

  // --- Chat Methods (Mocked) ---
  Future<List<Chat>> getChats() async {
    print('DesignService: Fetching chats (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Chat(
        customerId: 'cust_101',
        customerName: 'Alice Wonderland',
        customerSpecialty: 'Illustrator',
        messages: [
          ChatMessage(
            senderId: 'cust_101',
            senderName: 'Alice Wonderland',
            message: 'Hi, I have a question about my design project.',
            timestamp: now.subtract(const Duration(minutes: 15)),
          ),
          ChatMessage(
            senderId: 'design_007',
            senderName: 'James Bond (design)',
            message: 'Hello Alice, I am here to help. What is your question?',
            timestamp: now.subtract(const Duration(minutes: 10)),
          ),
        ],
        status: ChatStatus.inProgress,
        lastUpdated: now.subtract(const Duration(minutes: 10)),
      ),
      Chat(
        customerId: 'cust_102',
        customerName: 'Bob The Builder',
        customerSpecialty: 'Architect',
        messages: [
          ChatMessage(
            senderId: 'cust_102',
            senderName: 'Bob The Builder',
            message: 'Can we fix it?',
            timestamp: now.subtract(const Duration(hours: 1)),
          ),
        ],
        status: ChatStatus.pending,
        lastUpdated: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  Future<Chat> createChat(Chat chat) async {
    print('DesignService: Creating chat (mocked) for customer ${chat.customerName}');
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real backend, ID would be assigned here.
    // For mock, we assume chat object passed in has a generated ID.
    return chat;
  }

  Future<Chat> updateChat(Chat chat) async {
    print('DesignService: Updating chat (mocked) - ID: ${chat.id}');
    await Future.delayed(const Duration(milliseconds: 500));
    // This mock simply returns the chat. A real service might update specific fields.
    return chat;
  }

  Future<void> deleteChat(String chatId) async {
    print('DesignService: Deleting chat (mocked) - ID: $chatId');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<ChatMessage> addMessageToChat(String chatId, ChatMessage message) async {
    print('DesignService: Adding message to chat (mocked) - Chat ID: $chatId, Message: ${message.message}');
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real backend, the message would be persisted and returned, possibly with a new ID or timestamp.
    // For mock, we assume message object passed in has a generated ID.
    return message;
  }

  Future<String?> uploadDraftFile(File file) async {
    try {
      // Create a unique filename with timestamp to avoid overwriting
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${file.path.split('/').last}';
      
      // Upload the file
      await Supabase.instance.client.storage.from('eliteimage').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      // Get the public URL of the uploaded file
      final publicUrl = Supabase.instance.client.storage.from('eliteimage').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }
  
  Future<void> updateJobDesignData(String jobId, Map<String, dynamic> newDraft) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('jobs')
          .select()
          .eq('id', jobId)
          .maybeSingle();
      if (response == null) {
        throw Exception('Job not found');
      }
      // Always store design as a List<Map<String, dynamic>>
      List<dynamic> drafts = [];
      if (response['design'] != null) {
        final existing = response['design'];
        if (existing is List) {
          drafts = List<Map<String, dynamic>>.from(existing);
        } else if (existing is Map) {
          drafts = [Map<String, dynamic>.from(existing)];
        }
      }
      drafts.add(newDraft);
      await supabase
          .from('jobs')
          .update({'design': drafts})
          .eq('id', jobId);
      print('Successfully appended new draft to job design data for job: $jobId');
    } catch (e) {
      print('Error updating job design data: $e');
      rethrow;
    }
  }

  // Mocked user data for demonstration
  Future<List<app.User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      app.User(id: '1', name: 'John Doe', email: 'john@elitesigns.com', role: 'Admin', avatar: 'assets/images/avatars/default_avatar.png'),
      app.User(id: '2', name: 'Jane Smith', email: 'jane@elitesigns.com', role: 'Salesperson', avatar: 'assets/images/avatars/default_avatar.png'),
      app.User(id: '3', name: 'Mike Johnson', email: 'mike@elitesigns.com', role: 'design', avatar: 'assets/images/avatars/default_avatar.png'),
    ];
  }

  Future<app.User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For mock, return the first user
    return app.User(id: '1', name: 'John Doe', email: 'john@elitesigns.com', role: 'Admin', avatar: 'assets/images/avatars/default_avatar.png');
  }
}