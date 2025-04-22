import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  
  User? get currentUser => _currentUser;
  List<User> get users => _users;

  UserProvider() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');
      final currentUserJson = prefs.getString('currentUser');
      
      if (usersJson != null) {
        final List<dynamic> decodedUsers = json.decode(usersJson);
        _users = decodedUsers.map((user) => User.fromJson(user)).toList();
      } else {
        // Load sample users if none are found
        _loadSampleUsers();
      }

      if (currentUserJson != null) {
        _currentUser = User.fromJson(json.decode(currentUserJson));
      } else if (_users.isNotEmpty) {
        // Set the first user as current user if none is set
        _currentUser = _users.first;
        await _saveCurrentUser();
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      // Load sample users if there's an error
      _loadSampleUsers();
      if (_users.isNotEmpty) {
        _currentUser = _users.first;
        await _saveCurrentUser();
      }
      notifyListeners();
    }
  }

  void _loadSampleUsers() {
    _users = [
      User(
        name: 'John Doe',
        email: 'john@elitesigns.com',
        role: 'Admin',
        avatar: 'assets/images/avatar1.png',
      ),
      User(
        name: 'Jane Smith',
        email: 'jane@elitesigns.com',
        role: 'Salesperson',
        avatar: 'assets/images/avatar2.png',
      ),
      User(
        name: 'Mike Johnson',
        email: 'mike@elitesigns.com',
        role: 'Designer',
        avatar: 'assets/images/avatar3.png',
      ),
    ];
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(_users.map((user) => user.toJson()).toList());
    await prefs.setString('users', usersJson);
  }

  Future<void> _saveCurrentUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = json.encode(_currentUser!.toJson());
      await prefs.setString('currentUser', currentUserJson);
    }
  }

  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    await _saveCurrentUser();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    _users.add(user);
    await _saveUsers();
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      
      // Update current user if it's the same user
      if (_currentUser != null && _currentUser!.id == updatedUser.id) {
        _currentUser = updatedUser;
        await _saveCurrentUser();
      }
      
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((user) => user.id == id);
    
    // Clear current user if it's the deleted user
    if (_currentUser != null && _currentUser!.id == id) {
      _currentUser = _users.isNotEmpty ? _users.first : null;
      await _saveCurrentUser();
    }
    
    await _saveUsers();
    notifyListeners();
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
}