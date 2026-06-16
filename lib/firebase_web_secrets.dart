class FirebaseWebSecrets {
  static const githubPagesOrigin = 'https://exadmax.github.io';

  // ignore: do_not_use_environment
  static const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  // ignore: do_not_use_environment
  static const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  // ignore: do_not_use_environment
  static const messagingSenderId =
      String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID');
  // ignore: do_not_use_environment
  static const projectId = String.fromEnvironment('FIREBASE_WEB_PROJECT_ID');
  // ignore: do_not_use_environment
  static const authDomain =
      String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
  // ignore: do_not_use_environment
  static const storageBucket =
      String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET');
  // ignore: do_not_use_environment
  static const measurementId =
      String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID');

  static void assertConfigured() {
    final missing = <String>[];
    if (apiKey.isEmpty) missing.add('FIREBASE_WEB_API_KEY');
    if (appId.isEmpty) missing.add('FIREBASE_WEB_APP_ID');
    if (messagingSenderId.isEmpty) {
      missing.add('FIREBASE_WEB_MESSAGING_SENDER_ID');
    }
    if (projectId.isEmpty) missing.add('FIREBASE_WEB_PROJECT_ID');
    if (authDomain.isEmpty) missing.add('FIREBASE_WEB_AUTH_DOMAIN');
    if (storageBucket.isEmpty) missing.add('FIREBASE_WEB_STORAGE_BUCKET');

    if (missing.isNotEmpty) {
      throw StateError(
        'Firebase Web não configurado. Faltam dart-defines: ${missing.join(', ')}',
      );
    }
  }
}