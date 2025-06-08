import 'package:flutter/material.dart';
import 'package:note_tasky_ver2/auth/auth_service.dart';
import 'package:note_tasky_ver2/firestore_service.dart';
import 'package:note_tasky_ver2/models/task.dart';
import 'package:note_tasky_ver2/screens/add_task_screen.dart';
import 'package:note_tasky_ver2/widget/textfield.dart';

class ViewTaskScreen extends StatefulWidget {
  const ViewTaskScreen({super.key});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Task'),
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasks(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada task'));
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description),
                      Text(
                        'Kategori: ${task.category}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Dibuat: ${task.createdAt.toString().substring(0, 10)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            task.isCompleted = value ?? false;
                          });
                          _firestoreService.updateTask(
                            task,
                            {'isCompleted': value ?? false},
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditTaskDialog(context, task);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, task);
                        },
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
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: Colors.purple[300],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
  final titleController = TextEditingController(text: task.title);
  final descriptionController = TextEditingController(text: task.description);
  String selectedCategory = task.category;
  
  final List<String> categories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Shopping',
    'Other'
  ];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                controller: titleController,
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter task description",
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
              
              const SizedBox(height: 16),
              
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
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
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
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
                    content: Text('Judul task tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final updatedTask = Task(
                id: task.id,
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                category: selectedCategory,
                userId: task.userId,
                isCompleted: task.isCompleted,
                createdAt: task.createdAt,
              );
              
              _firestoreService.updateTask(
                updatedTask,
                {
                  'title': updatedTask.title,
                  'description': updatedTask.description,
                  'category': updatedTask.category,
                },
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Task'),
          content: const Text('Apakah Anda yakin ingin menghapus task ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _firestoreService.deleteTask(task.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}