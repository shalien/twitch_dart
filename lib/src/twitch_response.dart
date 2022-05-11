import 'package:http/http.dart';

class TwitchResponse {
  final int rateLimitLimit;
  final int rateLimitRemaining;
  final DateTime rateLimitReset;

  final Response response;

  TwitchResponse.fromResponse(this.response)
      : rateLimitLimit = int.parse(response.headers['ratelimit-limit']!),
        rateLimitRemaining =
            int.parse(response.headers['ratelimit-remaining']!),
        rateLimitReset = DateTime.parse(response.headers['ratelimit-reset']!);
}
