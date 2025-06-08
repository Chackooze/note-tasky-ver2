import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/firestore_service.dart';
import 'package:note_tasky_ver2/models/note.dart';
import 'package:note_tasky_ver2/screens/add_note_screen.dart';
import 'package:note_tasky_ver2/widget/textfield.dart';

class ViewNoteScreen extends StatefulWidget {
  const ViewNoteScreen({super.key});

  @override
  State<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Note'),
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Note>>(
        stream: _firestoreService.getNotes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada note'));
          }

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Category
                      Text(
                        'Kategori: ${note.category}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),

                      // Content with max lines and overflow
                      Text(
                        note.content,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 3, // Limit to 3 lines initially
                        overflow: TextOverflow
                            .ellipsis, // Show ... if text is too long
                      ),
                      const SizedBox(height: 8),

                      // Date
                      Text(
                        'Dibuat: ${note.createdAt.toString().substring(0, 10)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditNoteDialog(context, note);
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, note);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        backgroundColor: Colors.purple[300],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    String selectedCategory = note.category;

    // Ensure categories are unique and match the case exactly
    final List<String> categories = [
      'Personal',
      'Work',
      'Study',
      'Ideas',
      'Recipes',
      'Travel',
      'Other'
    ];

    // Make sure the selectedCategory exists in the categories list
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Personal'; // fallback to default
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Note Title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: "Enter note title",
                  label: "Title",
                  controller: titleController,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Content',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter note content",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategory = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul note tidak boleh kosong'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final updatedNote = Note(
                  id: note.id,
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  category: selectedCategory,
                  userId: note.userId,
                  createdAt: note.createdAt,
                );

                _firestoreService.updateNote(updatedNote, {
                  'title': updatedNote.title,
                  'content': updatedNote.content,
                  'category': updatedNote.category,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300],
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Note'),
          content: const Text('Apakah Anda yakin ingin menghapus note ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _firestoreService.deleteNote(note.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
