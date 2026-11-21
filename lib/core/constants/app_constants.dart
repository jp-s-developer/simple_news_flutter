class AppConstants {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const int pageSize = 20;
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration searchDebounce = Duration(milliseconds: 450);
}
