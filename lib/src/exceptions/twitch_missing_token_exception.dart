import '../twitch_client.dart';

/// Called when the client is missing the required model for calling the Twitch API.
class TwitchMissingTokenException implements Exception {
  /// The type of token required
  final TwitchClientType clientType;

  /// The message displayed
  String get message => clientType == TwitchClientType.any
      ? 'Either an user token or an app token is required'
      : 'An ${clientType.name} token is required';

  /// constructor
  TwitchMissingTokenException(this.clientType);
}
