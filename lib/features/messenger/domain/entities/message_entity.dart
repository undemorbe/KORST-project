class MessageEntity {
  final String id;
  final String authorId;
  final String text;
  final String? imageUrl;
  final bool? isSeen;
  final DateTime created;

  const MessageEntity({
    required this.id,
    required this.authorId,
    required this.text,
    this.imageUrl,
    this.isSeen,
    required this.created,
  });

  MessageEntity copyWith({
    String? id,
    String? authorId,
    String? text,
    String? imageUrl,
    bool? isSeen,
    DateTime? created,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isSeen: isSeen ?? this.isSeen,
      created: created ?? this.created,
    );
  }

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] as String,
      authorId:
          json['author-id'] as String? ?? json['authorId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl:
          json['imageURL'] as String? ??
          json['image-url'] as String? ??
          json['imageUrl'] as String?,
      isSeen: json['is-seen'] as bool? ?? json['isSeen'] as bool?,
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
      if (imageUrl != null) 'imageURL': imageUrl,
      if (isSeen != null) 'is-seen': isSeen,
      'created': created.toIso8601String(),
    };
  }
}
