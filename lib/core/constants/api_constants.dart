import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable via --dart-define=API_URL=...
  // Di Release mode: otomatis mengarah ke backend production Render.
  // Di Debug mode: Android Emulator -> 10.0.2.2:8000, Web/Desktop -> 127.0.0.1:8000.
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kReleaseMode) {
      return 'https://siaga-gunung.onrender.com';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }
  
  static const String volcanoesEndpoint = '/api/v1/volcanoes';
  static const String healthEndpoint = '/api/v1/health';
  
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}
