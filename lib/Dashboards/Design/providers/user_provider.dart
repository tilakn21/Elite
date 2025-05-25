import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/design_service.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // No longer used directly
// import 'dart:convert'; // No longer used directly

class UserProvider with ChangeNotifier {
  final DesignService _designService;
  User? _currentUser;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider(this._designService) {
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final users = await _designService.getUsers();
      final currentUser = await _designService.getCurrentUser();
      _users = users ?? [];
      _currentUser = currentUser;
      
      if (_currentUser == null && _users.isNotEmpty) {
        // If service doesn't specify a current user, default to first from the list (if any)
        // This part might be application specific - e.g. require login
        _currentUser = _users.first;
        // Optionally, inform the service about this default selection if needed
        // await _designService.setCurrentUser(_currentUser!.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error fetching initial user data from service: $e');
      }
      _users = [];
      _currentUser = null;
      // _loadSampleUsers(); // Fallback to sample data
      // if (_currentUser == null && _users.isNotEmpty) {
      //   _currentUser = _users.first;
      // }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSampleUsers() {
    _users = [
      User(
        id: '1',
        name: 'John Doe',
        email: 'john@elitesigns.com',
        role: 'Admin',
        avatar: 'assets/images/avatar1.png',
      ),
      User(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@elitesigns.com',
        role: 'Salesperson',
        avatar: 'assets/images/avatar2.png',
      ),
      User(
        id: '3',
        name: 'Mike Johnson',
        email: 'mike@elitesigns.com',
        role: 'Designer',
        avatar: 'assets/images/avatar3.png',
      ),
    ];
  }

  Future<void> setCurrentUser(User user) async {
    _isLoading = true;
    _errorMessage = null;
    // No notifyListeners() here for loading, as it's a quick state change.
    try {
      // Inform the service if necessary. Our mock service.setCurrentUser is a no-op.
      // await _designService.setCurrentUser(user.id);
      _currentUser = user;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error setting current user via service: $e');
      }
      // Potentially revert _currentUser or handle error
    } finally {
      _isLoading = false; // Or set to false if it was set true earlier
      notifyListeners();
    }
  }

  Future<void> addUser(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // TODO: Implement addUser with Supabase or your backend
      _users.add(user);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error adding user: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // TODO: Implement updateUser with Supabase or your backend
      final index = _users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
        if (_currentUser != null && _currentUser!.id == updatedUser.id) {
          _currentUser = updatedUser;
        }
      } else {
        print('UserProvider: Updated user ID ${updatedUser.id} not found in local list.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error updating user: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // TODO: Implement deleteUser with Supabase or your backend
      _users.removeWhere((user) => user.id == id);
      if (_currentUser != null && _currentUser!.id == id) {
        _currentUser = _users.isNotEmpty ? _users.first : null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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