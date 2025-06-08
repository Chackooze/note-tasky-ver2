import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/auth/login_screen.dart';
import 'package:note_tasky_ver2/firestore_service.dart';
import 'package:note_tasky_ver2/screens/add_task_screen.dart';
import 'package:note_tasky_ver2/screens/add_note_screen.dart';
import 'package:note_tasky_ver2/screens/view_note_screen.dart';
import 'package:note_tasky_ver2/screens/view_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, int> _stats = {
    'totalTasks': 0,
    'completedTasks': 0,
    'totalNotes': 0,
  };

  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Try to get display name from Firebase Auth first
        String displayName = user.displayName ?? '';
        
        // If no display name in Auth, try to get from Firestore
        if (displayName.isEmpty) {
          final userData = await _authService.getUserData(user.uid);
          displayName = userData?['displayName'] ?? '';
        }
        
        // If still empty, use email
        if (displayName.isEmpty) {
          displayName = user.email?.split('@')[0] ?? 'User';
        }
        
        setState(() {
          _userName = displayName;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = 'User';
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final uid = _authService.uid;
      if (uid.isNotEmpty) {
        final stats = await _firestoreService.getUserStats(uid);
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshStats() async {
    await _loadStats();
  }

  Future<void> _signOut() async {
    try {
      await _authService.signout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
    
    // Refresh stats when returning from add task screen
    if (result == null) {
      _refreshStats();
    }
  }

  Future<void> _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );
    
    // Refresh stats when returning from add note screen
    if (result == null) {
      _refreshStats();
    }
  }

    Future<void> _navigateToViewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewTaskScreen()),
    );
    
    // Refresh stats when returning from add note screen
    if (result == null) {
      _refreshStats();
    }
    }

    Future<void> _navigateToViewNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewNoteScreen()),
    );
    
    // Refresh stats when returning from add note screen
    if (result == null) {
      _refreshStats();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteTasky'),
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'logout') {
                await _signOut();
              } else if (value == 'refresh') {
                await _refreshStats();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome, $_userName!",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Here's your productivity summary",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Stats Section
                      const Text(
                        "Your Stats",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "Total Tasks",
                              value: _stats['totalTasks'].toString(),
                              icon: Icons.task_alt,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: "Completed",
                              value: _stats['completedTasks'].toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "Total Notes",
                              value: _stats['totalNotes'].toString(),
                              icon: Icons.note,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: "Progress",
                              value: _stats['totalTasks']! > 0 
                                  ? "${((_stats['completedTasks']! / _stats['totalTasks']!) * 100).round()}%"
                                  : "0%",
                              icon: Icons.trending_up,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Quick Actions
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _navigateToAddTask,
                              icon: const Icon(Icons.add_task),
                              label: const Text("Add Task"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _navigateToAddNote,
                              icon: const Icon(Icons.note_add),
                              label: const Text("Add Note"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Additional Quick Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _navigateToViewTask,
                              icon: const Icon(Icons.list_alt),
                              label: const Text("View Task"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _navigateToViewNote,
                              icon: const Icon(Icons.folder_open),
                              label: const Text("View Notes"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}