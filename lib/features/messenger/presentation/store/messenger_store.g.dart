// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messenger_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MessengerStore on _MessengerStore, Store {
  Computed<int>? _$totalUnreadCountComputed;

  @override
  int get totalUnreadCount => (_$totalUnreadCountComputed ??= Computed<int>(
          () => super.totalUnreadCount,
          name: '_MessengerStore.totalUnreadCount'))
      .value;
  Computed<List<ChatEntity>>? _$allChatsComputed;

  @override
  List<ChatEntity> get allChats =>
      (_$allChatsComputed ??= Computed<List<ChatEntity>>(() => super.allChats,
              name: '_MessengerStore.allChats'))
          .value;

  late final _$merchantChatsAtom =
      Atom(name: '_MessengerStore.merchantChats', context: context);

  @override
  ObservableList<ChatEntity> get merchantChats {
    _$merchantChatsAtom.reportRead();
    return super.merchantChats;
  }

  @override
  set merchantChats(ObservableList<ChatEntity> value) {
    _$merchantChatsAtom.reportWrite(value, super.merchantChats, () {
      super.merchantChats = value;
    });
  }

  late final _$customerChatsAtom =
      Atom(name: '_MessengerStore.customerChats', context: context);

  @override
  ObservableList<ChatEntity> get customerChats {
    _$customerChatsAtom.reportRead();
    return super.customerChats;
  }

  @override
  set customerChats(ObservableList<ChatEntity> value) {
    _$customerChatsAtom.reportWrite(value, super.customerChats, () {
      super.customerChats = value;
    });
  }

  late final _$messagesAtom =
      Atom(name: '_MessengerStore.messages', context: context);

  @override
  ObservableList<MessageEntity> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(ObservableList<MessageEntity> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$selectedChatAtom =
      Atom(name: '_MessengerStore.selectedChat', context: context);

  @override
  ChatEntity? get selectedChat {
    _$selectedChatAtom.reportRead();
    return super.selectedChat;
  }

  @override
  set selectedChat(ChatEntity? value) {
    _$selectedChatAtom.reportWrite(value, super.selectedChat, () {
      super.selectedChat = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_MessengerStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isSendingMessageAtom =
      Atom(name: '_MessengerStore.isSendingMessage', context: context);

  @override
  bool get isSendingMessage {
    _$isSendingMessageAtom.reportRead();
    return super.isSendingMessage;
  }

  @override
  set isSendingMessage(bool value) {
    _$isSendingMessageAtom.reportWrite(value, super.isSendingMessage, () {
      super.isSendingMessage = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_MessengerStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loadChatsAsyncAction =
      AsyncAction('_MessengerStore.loadChats', context: context);

  @override
  Future<void> loadChats() {
    return _$loadChatsAsyncAction.run(() => super.loadChats());
  }

  late final _$loadMessagesAsyncAction =
      AsyncAction('_MessengerStore.loadMessages', context: context);

  @override
  Future<void> loadMessages(String chatId) {
    return _$loadMessagesAsyncAction.run(() => super.loadMessages(chatId));
  }

  late final _$createChatAsyncAction =
      AsyncAction('_MessengerStore.createChat', context: context);

  @override
  Future<void> createChat({required String userId, required String cardId}) {
    return _$createChatAsyncAction
        .run(() => super.createChat(userId: userId, cardId: cardId));
  }

  late final _$sendMessageAsyncAction =
      AsyncAction('_MessengerStore.sendMessage', context: context);

  @override
  Future<void> sendMessage(String text) {
    return _$sendMessageAsyncAction.run(() => super.sendMessage(text));
  }

  late final _$sendImageAsyncAction =
      AsyncAction('_MessengerStore.sendImage', context: context);

  @override
  Future<void> sendImage({required String filePath, String? text}) {
    return _$sendImageAsyncAction
        .run(() => super.sendImage(filePath: filePath, text: text));
  }

  late final _$updateMessageAsyncAction =
      AsyncAction('_MessengerStore.updateMessage', context: context);

  @override
  Future<void> updateMessage(String messageId, String newText) {
    return _$updateMessageAsyncAction
        .run(() => super.updateMessage(messageId, newText));
  }

  late final _$deleteMessageAsyncAction =
      AsyncAction('_MessengerStore.deleteMessage', context: context);

  @override
  Future<void> deleteMessage(String messageId) {
    return _$deleteMessageAsyncAction.run(() => super.deleteMessage(messageId));
  }

  late final _$_MessengerStoreActionController =
      ActionController(name: '_MessengerStore', context: context);

  @override
  void selectChat(ChatEntity? chat) {
    final _$actionInfo = _$_MessengerStoreActionController.startAction(
        name: '_MessengerStore.selectChat');
    try {
      return super.selectChat(chat);
    } finally {
      _$_MessengerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_MessengerStoreActionController.startAction(
        name: '_MessengerStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_MessengerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
merchantChats: ${merchantChats},
customerChats: ${customerChats},
messages: ${messages},
selectedChat: ${selectedChat},
isLoading: ${isLoading},
isSendingMessage: ${isSendingMessage},
errorMessage: ${errorMessage},
totalUnreadCount: ${totalUnreadCount},
allChats: ${allChats}
    ''';
  }
}
