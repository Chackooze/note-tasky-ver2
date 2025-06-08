import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/firestore_service.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  
  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskProvider(this._firestoreService, this._authService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userId = _authService.uid;
      if (userId.isNotEmpty) {
        _tasks = await _firestoreService.getTasks(userId).first;
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Task>> getTasksStream() {
    final userId = _authService.uid;
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _firestoreService.getTasks(userId);
  }
}