import 'chat_entity.dart';

class ChatsResponse {
  final List<ChatEntity> merchantChats;
  final List<ChatEntity> customerChats;

  const ChatsResponse({
    required this.merchantChats,
    required this.customerChats,
  });

  factory ChatsResponse.fromJson(Map<String, dynamic> json) {
    return ChatsResponse(
      merchantChats: (json['merchant-chats'] as List<dynamic>?)
              ?.map((e) => ChatEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      customerChats: (json['customer-chats'] as List<dynamic>?)
              ?.map((e) => ChatEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant-chats': merchantChats.map((e) => e.toJson()).toList(),
      'customer-chats': customerChats.map((e) => e.toJson()).toList(),
    };
  }
}
