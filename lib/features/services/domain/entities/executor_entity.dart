enum ReplyStatus {
  pending,
  accepted,
  rejected,
  completed,
  failed,
  unknown;

  static ReplyStatus fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'pending':
        return ReplyStatus.pending;
      case 'accepted':
        return ReplyStatus.accepted;
      case 'rejected':
        return ReplyStatus.rejected;
      case 'completed':
        return ReplyStatus.completed;
      case 'failed':
        return ReplyStatus.failed;
      default:
        return ReplyStatus.unknown;
    }
  }
}

class ExecutorEntity {
  final String id;
  final String name;
  final String? surname;
  final String? imageUrl;
  final double rating;
  final ReplyStatus replyStatus;

  ExecutorEntity({
    required this.id,
    required this.name,
    this.surname,
    this.imageUrl,
    required this.rating,
    this.replyStatus = ReplyStatus.unknown,
  });

  String get displayName =>
      surname != null && surname!.isNotEmpty ? '$name $surname' : name;

  factory ExecutorEntity.fromJson(Map<String, dynamic> json) {
    return ExecutorEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String?,
      imageUrl: _normalizeUrl(json['image-url'] as String?),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      replyStatus: ReplyStatus.fromString(
        json['reply-status'] as String? ?? json['replyStatus'] as String?,
      ),
    );
  }

  /// Converts relative path to absolute using server root (not /api/ sub-path).
  static String? _normalizeUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final url = raw.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    // Relative path — strip leading slash if any, prepend server root
    const base = 'https://2839bc9a-d491-41f2-94d8-c3c98ffedc32.tunnel4.com';
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }
}
