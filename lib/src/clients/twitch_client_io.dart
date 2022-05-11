import 'package:http/io_client.dart';
import 'package:twitch_dart/src/clients/twitch_client.dart';

import 'twitch_client_base.dart';

TwitchClient createTwitchClient(
        String clientId, String clientSecret, String token) =>
    TwitchClientIO(clientId, clientSecret, token);

class TwitchClientIO extends TwitchClientBase {
  TwitchClientIO(String clientId, String clientSecret, String token)
      : super(clientId, clientSecret, token, IOClient());
}
