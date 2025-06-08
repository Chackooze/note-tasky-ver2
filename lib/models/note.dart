class Note {
  String? id;
  String title;
  String content;
  String category;
  DateTime createdAt;
  String userId; // Add user ID for multi-user support

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}