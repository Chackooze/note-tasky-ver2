import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/note.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Task Operations
  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateTask(Task task, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(updates);  // Only update the provided fields
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Note Operations
  Future<void> addNote(Note note) async {
    try {
      await _firestore.collection('notes').add(note.toMap());
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  Stream<List<Note>> getNotes(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateNote(Note note, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('notes')
          .doc(note.id)
          .update(updates);  // Only update the provided fields
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }


  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      
      final notesSnapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();

      final completedTasks = tasksSnapshot.docs
          .where((doc) => doc.data()['isCompleted'] == true)
          .length;

      return {
        'totalTasks': tasksSnapshot.docs.length,
        'completedTasks': completedTasks,
        'totalNotes': notesSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'totalNotes': 0,
      };
    }
  }
}