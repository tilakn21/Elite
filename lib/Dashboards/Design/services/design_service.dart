// lib/Dashboards/Design/services/design_service.dart
import '../models/job.dart';
import '../models/chat.dart'; // Added Chat model import
import '../models/user.dart'; // Added User model import
// import 'package:http/http.dart' as http; // Placeholder for HTTP requests
// import 'dart:convert'; // For json encoding/decoding

class DesignService {
  // Mock base URL - replace with actual API endpoint
  // static const String _baseUrl = 'https://api.example.com/design';

  Future<List<Job>> getJobs() async {
    print('DesignService: Fetching jobs (mocked)');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final now = DateTime.now();
    return [
      Job(
        jobNo: '#DSGN001',
        clientName: 'Creative Solutions Ltd.',
        email: 'contact@creativesolutions.com',
        phoneNumber: '(555) 123-4567',
        address: '123 Design Avenue, Art City',
        dateAdded: now.subtract(const Duration(days: 5)),
        status: JobStatus.inProgress,
        assignedTo: 'Designer Alice',
        measurements: 'Banner: 3m x 1m',
        uploadedImages: ['https://via.placeholder.com/150/FF0000/FFFFFF?Text=Draft1.jpg'],
        notes: 'Client wants a modern and sleek design.',
      ),
      Job(
        jobNo: '#DSGN002',
        clientName: 'Tech Innovators Inc.',
        email: 'info@techinnovators.com',
        phoneNumber: '(555) 987-6543',
        address: '456 Innovation Drive, Techville',
        dateAdded: now.subtract(const Duration(days: 2)),
        status: JobStatus.pending,
        assignedTo: 'Designer Bob',
        measurements: 'Logo: various sizes',
        notes: 'Awaiting client brief for logo requirements.',
      ),
      Job(
        jobNo: '#DSGN003',
        clientName: 'Local Bakery Co.',
        email: 'orders@localbakery.com',
        phoneNumber: '(555) 222-3333',
        address: '789 Pastry Lane, Sweet Town',
        dateAdded: now.subtract(const Duration(days: 10)),
        status: JobStatus.approved,
        assignedTo: 'Designer Carol',
        measurements: 'Menu Board: 1.5m x 0.8m',
        uploadedImages: [
          'https://via.placeholder.com/150/00FF00/FFFFFF?Text=MenuV1.jpg',
          'https://via.placeholder.com/150/0000FF/FFFFFF?Text=MenuV2.jpg'
        ],
        notes: 'Final design approved. Ready for production.',
      ),
    ];
  }

  Future<Job> createJob(Job job) async {
    print('DesignService: Creating job (mocked) - ${job.jobNo}');
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real scenario, the backend would assign the ID and return the created job.
    // For this mock, we assume the job object passed in already has a generated ID.
    return job;
  }

  Future<Job> updateJob(Job job) async {
    print('DesignService: Updating job (mocked) - ${job.jobNo}');
    await Future.delayed(const Duration(milliseconds: 500));
    return job; // Return the updated job
  }

  Future<void> deleteJob(String jobId) async {
    print('DesignService: Deleting job (mocked) - ID: $jobId');
    await Future.delayed(const Duration(milliseconds: 500));
    // No return value needed for delete
  }

  // Add other methods as needed, e.g., for chat, user details specific to design context

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
            senderId: 'designer_007',
            senderName: 'James Bond (Designer)',
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

  // --- User Methods (Mocked) ---
  Future<List<User>> getUsers() async {
    print('DesignService: Fetching users (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    return [
      User(name: 'Designer Dave', email: 'dave@example.com', role: 'Designer', avatar: 'assets/images/avatar_dave.png'),
      User(name: 'Manager Mary', email: 'mary@example.com', role: 'Manager', avatar: 'assets/images/avatar_mary.png'),
      User(name: 'Client Clara', email: 'clara@example.com', role: 'Client', avatar: 'assets/images/avatar_clara.png'),
    ];
  }

  Future<User?> getCurrentUser() async {
    print('DesignService: Fetching current user (mocked)');
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real app, this might involve checking auth tokens or a specific endpoint
    // For mock, let's return the first user from our list or a specific one
    final users = await getUsers(); // Re-use getUsers to ensure consistency for mock
    return users.isNotEmpty ? users.first : null;
  }

  Future<void> setCurrentUser(String userId) async {
    print('DesignService: Setting current user (mocked) - User ID: $userId');
    // In a real app, this might update a local preference or send a signal to the backend.
    // For mock, this is a no-op as the provider will handle the local state.
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<User> createUser(User user) async {
    print('DesignService: Creating user (mocked) - ${user.name}');
    await Future.delayed(const Duration(milliseconds: 500));
    // Assume backend assigns ID and returns the full user object
    return user; // For mock, return as is (ID already generated by model)
  }

  Future<User> updateUser(User user) async {
    print('DesignService: Updating user (mocked) - ${user.name}');
    await Future.delayed(const Duration(milliseconds: 500));
    return user;
  }

  Future<void> deleteUser(String userId) async {
    print('DesignService: Deleting user (mocked) - ID: $userId');
    await Future.delayed(const Duration(milliseconds: 500));
  }
}