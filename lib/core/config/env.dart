import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}
  }

  static String get baseUrl {
    const v = String.fromEnvironment('BASE_URL');
    if (v.isNotEmpty) return v;
    return dotenv.maybeGet('BASE_URL') ?? '';
  }

  static String get apiKey {
    const v = String.fromEnvironment('API_KEY');
    if (v.isNotEmpty) return v;
    return dotenv.maybeGet('API_KEY') ?? '';
  }
}
