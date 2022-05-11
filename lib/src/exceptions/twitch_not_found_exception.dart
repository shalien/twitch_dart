class TwitchNotFoundException implements Exception {
  final String message;

  TwitchNotFoundException(this.message) : super();
}
