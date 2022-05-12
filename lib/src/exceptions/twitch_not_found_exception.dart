import 'package:http/http.dart';

class TwitchNotFoundException implements Exception {
  final Response response;

  TwitchNotFoundException(this.response) : super();
}
