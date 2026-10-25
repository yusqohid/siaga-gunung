import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable via --dart-define=API_URL=...
  // Di emulator Android, 10.0.2.2 menunjuk ke host OS (laptop).
  // Di Web / Linux, 127.0.0.1 menunjuk ke localhost.
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;
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
