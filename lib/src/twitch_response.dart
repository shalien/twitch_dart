import 'dart:convert';

import 'package:http/http.dart';

class TwitchResponse {
  final int rateLimitLimit;
  final int rateLimitRemaining;
  final DateTime rateLimitReset;

  final Response _response;
  late final Map<String, dynamic> headers = _response.headers;
  final dynamic data;

  bool get isSuccessful =>
      _response.statusCode == 200 || _response.statusCode == 204;

  TwitchResponse.fromResponse(this._response)
      : rateLimitLimit = int.parse(_response.headers['ratelimit-limit']!),
        rateLimitRemaining =
            int.parse(_response.headers['ratelimit-remaining']!),
        rateLimitReset = DateTime.parse(_response.headers['ratelimit-reset']!),
        data = json.decode(_response.body)['data'];
}
