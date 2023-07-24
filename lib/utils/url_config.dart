import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlConstants {
  // static String apiKeyValue = dotenv.env['API_KEY'] ?? '';
  static String apiKeyValue = '';
  static const String baseUrl = 'api.openai.com';
  static const String completionUrl = "/v1/completions";
}
