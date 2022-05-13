import 'package:dotenv/dotenv.dart';
import 'package:twitch_dart/src/exceptions/twitch_missing_token_exception.dart';
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

      client = TwitchClient(clientId, appToken: token);
    });

    test('Start commercial', () async {
      try {
        await client.startCommercial('test', 30);
      } catch (e) {
        expect(e, isA<TwitchMissingTokenException>());
      }
    });

    test('Get Extension Analytics', () async {
      try {
        TwitchResponse response = await client.getExtensionAnalytics();
        expect(response.data, isMap);
      } catch (e) {
        print(e.toString());
        fail(e.toString());
      }
    });

    test('Get users', () async {
      final response =
          await client.getUsers(logins: ['shalien', 'moanatari2', 'saltybet']);

      print(
          '${response.rateLimitLimit} ${response.rateLimitRemaining} ${response.rateLimitReset} ${response.data}');
    });
  });
}
