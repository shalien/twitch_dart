import 'package:dotenv/dotenv.dart';
import 'package:twitch_dart/twitch_dart.dart';
import 'package:test/test.dart';

void main() {
  late TwitchClient client;

  group('Testing the client', () {
    setUp(() {
      final env = DotEnv()..load();
      final clientId = env['CLIENT_ID']!;
      final clientSecret = env['CLIENT_SECRET']!;
      final token = env['APP_ACCESS_TOKEN']!;

      client = TwitchClient(clientId, clientSecret, token);
    });

    test('Get users', () async {
      final users =
          await client.getUsers(logins: ['shalien', 'Moanatari2', 'saltybet']);

      print(users);
    });
  });
}
