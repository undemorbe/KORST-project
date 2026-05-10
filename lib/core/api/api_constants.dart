import '../config/env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static String get headerAccessToken => EnvConfig.headerAccessToken;
  static String get headerAuthorization => EnvConfig.headerAuthorization;
  static String get headerUserId => EnvConfig.headerUserId;

  static String get authorizeSendOtp => EnvConfig.authorizeSendOtp;
  static String get authorizeVerifyOtp => EnvConfig.authorizeVerifyOtp;
  static String get authorizeLogout => EnvConfig.authorizeLogout;
  static String get authorizeCheckUser => EnvConfig.authorizeCheckUser;
  static String get authorizeRefresh => EnvConfig.authorizeRefresh;

  static String get userUpdate => EnvConfig.userUpdate;
  static String get userGetInfo => EnvConfig.userGetInfo;
  static String get userMe => EnvConfig.userMe;
  static String get userSaveImage => EnvConfig.userSaveImage;
  static String get userReviews => EnvConfig.userReviews;
  static String get userPostReview => EnvConfig.userPostReview;

  static String get cardsSaveCard => EnvConfig.cardsSaveCard;
  static String get cardsUpdateCard => EnvConfig.cardsUpdateCard;
  static String get cardsCardInfo => EnvConfig.cardsCardInfo;
  static String get cardsGetCards => EnvConfig.cardsGetCards;
  static String get cardsGetWithQuery => EnvConfig.cardsGetWithQuery;
  static String get cardsSaveImage => EnvConfig.cardsSaveImage;
  static String get repliesCreateReply => EnvConfig.repliesCreateReply;
  static String get repliesApproveExecutor => EnvConfig.repliesApproveExecutor;
  static String get repliesRejectExecutor => EnvConfig.repliesRejectExecutor;
  static String get repliesClose => EnvConfig.repliesClose;
  static String get repliesGetExecutors => EnvConfig.repliesGetExecutors;

  static String get bannersGetBanners => EnvConfig.bannersGetBanners;

  static String get messengerChats => EnvConfig.messengerChats;
  static String get messengerMessages => EnvConfig.messengerMessages;
  static String get messengerCreateChat => EnvConfig.messengerCreateChat;
  static String get messengerSendMessage => EnvConfig.messengerSendMessage;
  static String get messengerSendImage => EnvConfig.messengerSendImage;
  static String get messengerChangeMessage => EnvConfig.messengerChangeMessage;
  static String get messengerDeleteMessage => EnvConfig.messengerDeleteMessage;
  static String get messengerSocketUrl => EnvConfig.messengerSocketUrl;
}
