class MessageEntity {
  final String id;
  final String authorId;
  final String text;
  final DateTime created;

  const MessageEntity({
    required this.id,
    required this.authorId,
    required this.text,
    required this.created,
  });

  MessageEntity copyWith({
    String? id,
    String? authorId,
    String? text,
    DateTime? created,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      created: created ?? this.created,
    );
  }

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] as String,
      authorId: json['author-id'] as String? ?? json['authorId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author-id': authorId,
      'text': text,
      'created': created.toIso8601String(),
    };
  }
}
