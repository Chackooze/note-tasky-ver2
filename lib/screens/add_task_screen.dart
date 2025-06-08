import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/firestore_service.dart';
import 'package:note_tasky_ver2/models/task.dart';
import 'package:note_tasky_ver2/widget/textfield.dart';
import 'package:note_tasky_ver2/widget/button.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'Personal';
  bool _isLoading = false;
  
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  final List<String> _categories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Shopping',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hint: "Enter task title",
                label: "Title",
                controller: _titleController,
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter task description (optional)",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15, 
                    horizontal: 10
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15, 
                    horizontal: 10
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              
              const Spacer(),
              
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        label: "Add Task",
                        onPressed: _addTask,
                      ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) {
      _showError("Please enter a task title");
      return;
    }

    final userId = _authService.uid;
    if (userId.isEmpty) {
      _showError("User not authenticated");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        userId: userId,
      );

      await _firestoreService.addTask(task);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to add task: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}