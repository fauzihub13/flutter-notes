class NoteModel {
  int? id;
  String? userId;
  String? title;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  NoteModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create an instance from a Map (for database)
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Method to convert an instance to a Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
    };
  }
}
