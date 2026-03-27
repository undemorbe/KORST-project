import '../config/env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static String get headerAccessToken => EnvConfig.headerAccessToken;
  static String get headerAuthorization => EnvConfig.headerAuthorization;

  static String get authorizeSendOtp => EnvConfig.authorizeSendOtp;
  static String get authorizeVerifyOtp => EnvConfig.authorizeVerifyOtp;
  static String get authorizeLogout => EnvConfig.authorizeLogout;
  static String get authorizeCheckUser => EnvConfig.authorizeCheckUser;
  static String get authorizeRefresh => EnvConfig.authorizeRefresh;

  static String get userUpdate => EnvConfig.userUpdate;

  static String get cardsSaveCard => EnvConfig.cardsSaveCard;
  static String get cardsCardInfo => EnvConfig.cardsCardInfo;
  static String get cardsGetCards => EnvConfig.cardsGetCards;
}
