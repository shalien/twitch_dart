import 'package:http/http.dart';

class TwitchApiRateLimitedException implements Exception {
  final Response response;

  TwitchApiRateLimitedException(this.response) : super();
}
