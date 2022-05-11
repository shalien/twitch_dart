class TwitchApiRateLimitedException implements Exception {
  final String message;

  TwitchApiRateLimitedException(this.message) : super();
}
