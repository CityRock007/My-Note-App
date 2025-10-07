class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdTime;
  final int? categoryId;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdTime': createdTime.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      createdTime: DateTime.parse(map['createdTime'] as String),
      categoryId: map['categoryId'] as int?,
    );
  }
}