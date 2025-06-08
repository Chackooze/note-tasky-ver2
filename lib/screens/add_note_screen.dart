import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/firestore_service.dart';
import 'package:note_tasky_ver2/models/note.dart';
import 'package:note_tasky_ver2/widget/textfield.dart';
import 'package:note_tasky_ver2/widget/button.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'Personal';
  bool _isLoading = false;
  
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  final List<String> _categories = [
    'Personal',
    'Work',
    'Study',
    'Ideas',
    'Recipes',
    'Travel',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
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
                'Note Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hint: "Enter note title",
                label: "Title",
                controller: _titleController,
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "Write your note content here...",
                    contentPadding: const EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
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
              
              const SizedBox(height: 20),
              
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        label: "Add Note",
                        onPressed: _addNote,
                      ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showError("Please enter a note title");
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showError("Please enter note content");
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
      final note = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        userId: userId,
      );

      await _firestoreService.addNote(note);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to add note: ${e.toString()}");
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