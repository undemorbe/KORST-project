import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String _get(String key, String fallback) {
    try {
      final value = dotenv.maybeGet(key);
      if (value == null || value.trim().isEmpty) return fallback;
      return value;
    } catch (_) {
      return fallback;
    }
  }

  static String get apiBaseUrl => _get(
        'API_BASE_URL',
        'https://unexperimented-janetta-nondisrupting.ngrok-free.dev/api/',
      );

  static String get headerAccessToken => _get('API_HEADER_ACCESS_TOKEN', 'access-token');
  static String get headerAuthorization => _get('API_HEADER_AUTHORIZATION', 'Authorization');

  static String get authorizeSendOtp => _get('API_AUTHORIZE_SEND_OTP', 'authorize/send-otp');
  static String get authorizeVerifyOtp => _get('API_AUTHORIZE_VERIFY_OTP', 'authorize/verify-otp');
  static String get authorizeLogout => _get('API_AUTHORIZE_LOGOUT', 'authorize/logout');
  static String get authorizeCheckUser => _get('API_AUTHORIZE_CHECK_USER', 'authorize/check-user');
  static String get authorizeRefresh => _get('API_AUTHORIZE_REFRESH', 'authorize/refresh');

  static String get userUpdate => _get('API_USER_UPDATE', 'user/update');

  static String get cardsSaveCard => _get('API_CARDS_SAVE_CARD', 'cards/save-card');
  static String get cardsCardInfo => _get('API_CARDS_CARD_INFO', 'cards/card-info');
  static String get cardsGetCards => _get('API_CARDS_GET_CARDS', 'cards/get-cards');
}
