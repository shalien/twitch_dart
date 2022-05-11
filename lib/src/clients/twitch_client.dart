import 'package:http/http.dart';

import 'twitch_client_none.dart'
    if (dart.library.io) 'twitch_client_io.dart'
    if (dart.library.html) 'twitch_client_html.dart';

abstract class TwitchClient {
  String get clientId;
  String get clientSecret;
  String get token;

  Client get client;

  Future<List<Map<String, dynamic>>> getUsers(
      {List<String>? ids, List<String>? logins});

  factory TwitchClient(String clientId, String clientSecret, String token) =>
      createTwitchClient(clientId, clientSecret, token);
}
