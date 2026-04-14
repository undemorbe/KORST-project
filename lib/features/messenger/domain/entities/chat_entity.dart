class ChatEntity {
  final String id;
  final ChatUserInfo user;
  final LastMessage? lastMessage;
  final CardInfo card;

  const ChatEntity({
    required this.id,
    required this.user,
    this.lastMessage,
    required this.card,
  });

  ChatEntity copyWith({
    String? id,
    ChatUserInfo? user,
    LastMessage? lastMessage,
    CardInfo? card,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      card: card ?? this.card,
    );
  }

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    return ChatEntity(
      id: json['id'] as String,
      user: ChatUserInfo.fromJson(json['user'] as Map<String, dynamic>),
      lastMessage: json['last-message'] != null || json['lastMessage'] != null
          ? LastMessage.fromJson((json['last-message'] ?? json['lastMessage']) as Map<String, dynamic>)
          : null,
      card: CardInfo.fromJson(json['card'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'last-message': lastMessage?.toJson(),
      'card': card.toJson(),
    };
  }
}

class ChatUserInfo {
  final String id;
  final String name;
  final String? surname;
  final String? imageUrl;

  const ChatUserInfo({
    required this.id,
    required this.name,
    this.surname,
    this.imageUrl,
  });

  ChatUserInfo copyWith({
    String? id,
    String? name,
    String? surname,
    String? imageUrl,
  }) {
    return ChatUserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory ChatUserInfo.fromJson(Map<String, dynamic> json) {
    return ChatUserInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String?,
      imageUrl: json['image-url'] as String? ?? json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'image-url': imageUrl,
    };
  }
}

class LastMessage {
  final String id;
  final String authorId;
  final String text;
  final DateTime created;

  const LastMessage({
    required this.id,
    required this.authorId,
    required this.text,
    required this.created,
  });

  LastMessage copyWith({
    String? id,
    String? authorId,
    String? text,
    DateTime? created,
  }) {
    return LastMessage(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      created: created ?? this.created,
    );
  }

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
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

class CardInfo {
  final String id;
  final String name;
  final String? imageUrl;

  const CardInfo({required this.id, required this.name, this.imageUrl});

  CardInfo copyWith({String? id, String? name, String? imageUrl}) {
    return CardInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      imageUrl: json['image-url'] as String? ?? json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image-url': imageUrl,
    };
  }
}
