class WebSocketMessage {
  final String id;
  final String chatId;
  final String authorId;
  final String? text;
  final String? imageURL;
  final String created;
  final bool isSeen;

  const WebSocketMessage({
    required this.id,
    required this.chatId,
    required this.authorId,
    this.text,
    this.imageURL,
    required this.created,
    required this.isSeen,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      id: json['id'] as String,
      chatId: json['chat-id'] as String,
      authorId: json['author-id'] as String,
      text: json['text'] as String?,
      imageURL: json['imageURL'] as String?,
      created: json['created'] as String,
      isSeen: json['is-seen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat-id': chatId,
      'author-id': authorId,
      if (text != null) 'text': text,
      if (imageURL != null) 'imageURL': imageURL,
      'created': created,
      'is-seen': isSeen,
    };
  }
}
