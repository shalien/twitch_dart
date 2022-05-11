import 'dart:convert';

import 'package:http/http.dart';
import 'package:twitch_dart/src/exceptions/twitch_api_rate_limited_exception.dart';
import 'package:twitch_dart/src/exceptions/twitch_not_found_exception.dart';
import 'package:twitch_dart/src/twitch_constants.dart';

import 'twitch_client.dart';

abstract class TwitchClientBase implements TwitchClient {
  @override
  String get clientId => _clientId;
  @override
  String get clientSecret => _clientSecret;
  @override
  String get token => _token;

  final Client _client;

  @override
  Client get client => _client;

  final String _clientId;
  final String _clientSecret;
  final String _token;

  TwitchClientBase(
      this._clientId, this._clientSecret, this._token, this._client);

  Future<void> startCommercial(String broadcasterId, int length) async {
    if (!commercialLengths.contains(length)) {
      throw ArgumentError(
          'Length must be one of ${commercialLengths.join(', ')}');
    }

    final url = Uri.parse(createUrl('/channels/commercial'));
    final body = {'broadcaster_id': broadcasterId, 'length': length.toString()};

    final response =
        await _client.post(url, headers: _createHeaders(), body: body);

    switch (response.statusCode) {
      case 200:
        print(json.decode(response.body));
        break;
      case 429:
        break;
    }
  }

  /// Gets information about one or more specified Twitch users.
  /// Users are identified by optional user [ids] and/or [logins] name.
  /// If neither a user ID nor a login name is specified, the user is looked up by Bearer token.
  /// [ids] User ID. Multiple user IDs can be specified. Limit: 100.
  /// [logins] User login name. Multiple user logins can be specified. Limit: 100.
  ///
  /// Note: The limit of 100 IDs and login names is the total limit.
  /// You can request, for example, 50 of each or 100 of one of them.
  /// You cannot request 100 of both.
  @override
  Future<List<Map<String, dynamic>>> getUsers(
      {List<String>? ids, List<String>? logins}) async {
    if (ids == null && logins == null) {
      throw ArgumentError('Either ids or logins must be specified');
    }

    if (ids != null && ids.length > 100) {
      throw ArgumentError('Maximum number of users is 100');
    }

    if (logins != null && logins.length > 100) {
      throw ArgumentError('Maximum number of users is 100');
    }

    if (ids != null && logins != null && ids.length + logins.length > 100) {
      throw ArgumentError('Maximum number of users is 100');
    }

    final param = [
      ...ids != null ? ids.map((e) => 'id=$e').toList() : [],
      ...logins != null ? logins.map((e) => 'login=$e').toList() : [],
    ];

    final url = Uri.parse(createUrl('users?${param.join('&')}'));

    final response = await _client.get(url, headers: _createHeaders());

    switch (response.statusCode) {
      case 200:
        final List<Map<String, dynamic>> data = [
          ...json.decode(response.body)['data']
        ];

        return data;
      case 404:
        throw TwitchNotFoundException('User not found');
      case 429:
        throw TwitchApiRateLimitedException('Rate limited');
      default:
        throw Exception(
            'Get Users ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Map<String, String> _createHeaders() => {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
