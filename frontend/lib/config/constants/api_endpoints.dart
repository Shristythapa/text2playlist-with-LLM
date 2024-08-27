class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 1000);
  static const Duration receiveTimeout = Duration(seconds: 1000);

  static const String baseUrl = "http://192.168.246.63:5000/";

  static const String login = "login";
  static const String callBack = "spotify/callback";
  static const String refreshToken = "spotify/refreshToken";
  static const String createPlaylist = "spotify/createPlaylist";
  static const String listPlaylist = "generate";
}
