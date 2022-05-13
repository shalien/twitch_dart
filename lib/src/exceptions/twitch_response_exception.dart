import 'package:http/http.dart';

/// Represent a custom exception for Twitch API responses.
/// The exception contains the status code and the response body.
class TwitchResponseException implements Exception {
  final Response response;

  /// The status code
  int get statusCode => response.statusCode;

  /// The reason associated with the status code
  String? get reasonPhrase => response.reasonPhrase;

  /// The body of the response
  String? get body => response.body;

  /// The headers of the response
  Map<String, String> get headers => response.headers;

  /// Allow to create an exception from a [Response]
  TwitchResponseException.fromResponse(this.response);
}
