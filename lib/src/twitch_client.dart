import 'dart:convert';
import 'dart:core';

import 'exceptions/twitch_api_rate_limited_exception.dart';
import 'exceptions/twitch_not_found_exception.dart';
import 'twitch_constants.dart';
import 'twitch_response.dart';

import 'package:http/http.dart' as http;

/// Allow to connect to the twitch api using a [clientId] and a [appToken].
/// The [appToken] can be a appAccessToken or a userAccessToken or a OAuthAccessToken.
class TwitchClient {
  /// The client id used in the request.
  final String clientId;

  /// The access token used in the request.
  final String? appToken;

  /// The OAuth token used in the request.
  final String? userToken;

  TwitchClient(this.clientId, {this.appToken, this.userToken});

  /// Starts a commercial on a specified channel.
  /// [broadcasterId] is the channel ID to start the commercial on.
  /// Desired [length] of the commercial in seconds. Valid options are 30, 60, 90, 120, 150, 180.
  Future<TwitchResponse> startCommercial(
      String broadcasterId, int length) async {
    if (!commercialLengths.contains(length)) {
      throw ArgumentError(
          'Length must be one of ${commercialLengths.join(', ')}');
    }

    final url = Uri.parse(createUrl('/channels/commercial'));
    final body = {'broadcaster_id': broadcasterId, 'length': length.toString()};

    final response =
        await http.post(url, headers: _createHeaders(), body: body);

    return _handleResponse(response);
  }

  /// Gets a URL that Extension developers can use to download analytics reports (CSV files) for their Extensions. The URL is valid for 5 minutes.
  /// If you specify a future date, the response will be “Report Not Found For Date Range.”
  /// If you leave both [startedAt] and [endedAt] blank, the API returns the most recent date of data.
  /// [after] is the cursor for the next page of results. This applies only to queries without [extensionId].
  ///
  Future<TwitchResponse> getExtensionAnalytics(
      {String? after,
      DateTime? endedAt,
      String? extensionId,
      int first = 20,
      DateTime? startedAt,
      String type = 'overview_v2'}) async {
    if (endedAt != null && startedAt == null) {
      throw ArgumentError('If endedAt is set, startedAt must be set too');
    } else if (endedAt == null && startedAt != null) {
      throw ArgumentError('If startedAt is set, endedAt must be set too');
    }

    final params = <String, String>{
      'first': (first > 100 ? 100 : first).toString(),
      'type': type,
    };

    if (extensionId != null) {
      params['extension_id'] = extensionId;
    } else {
      /// Starting date/time for returned reports, in RFC3339 format
      /// with the hours, minutes, and seconds zeroed out and the UTC timezone: YYYY-MM-DDT00:00:00Z
      /// This must be on or after January 31, 2018.
      if (startedAt != null) {
        if (startedAt.isBefore(DateTime(2018, 1, 31))) {
          throw ArgumentError('startedAt must be on or after January 31, 2018');
        }

        params['started_at'] =
            DateTime(startedAt.year, startedAt.month, startedAt.day, 0, 0, 0)
                .toUtc()
                .toIso8601String();
      }

      /// Ending date/time for returned reports, in RFC3339 format
      /// with the hours, minutes, and seconds zeroed out and the UTC timezone: YYYY-MM-DDT00:00:00Z
      if (endedAt != null) {
        params['ended_at'] =
            DateTime(endedAt.year, endedAt.month, endedAt.day, 0, 0, 0)
                .toUtc()
                .toIso8601String();
      }

      /// This applies only to queries without [extensionId].
      if (after != null) {
        params['after'] = after;
      }
    }

    final url = Uri.parse(createUrl('/analytics/extensions?') +
        params.entries.map((e) => '${e.key}=${e.value}').join('&'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets a URL that game developers can use to download analytics reports (CSV files) for their games.
  /// The URL is valid for 5 minutes.
  /// [after] Cursor for forward pagination: tells the server where to start fetching the next set of results, in a multi-page response. This applies only to queries without [gameId].
  /// [first] Number of objects to return. Maximum: 100. Default: 20.
  /// [gameId] The ID of the game to get analytics for.
  /// [startedAt] Starting date/time for returned reports, in RFC3339 format
  /// with the hours, minutes, and seconds zeroed out and the UTC timezone: YYYY-MM-DDT00:00:00Z
  /// [endedAt] Ending date/time for returned reports, in RFC3339 format
  /// with the hours, minutes, and seconds zeroed out and the UTC timezone: YYYY-MM-DDT00:00:00Z
  Future<TwitchResponse> getGameAnalytics(
      {String? after,
      DateTime? endedAt,
      String? gameId,
      int first = 20,
      DateTime? startedAt,
      String type = 'overview_v2'}) async {
    if (endedAt != null && startedAt == null) {
      throw ArgumentError('If endedAt is set, startedAt must be set too');
    } else if (endedAt == null && startedAt != null) {
      throw ArgumentError('If startedAt is set, endedAt must be set too');
    }

    final params = <String, String>{
      'first': (first > 100 ? 100 : first).toString(),
      'type': type,
    };

    if (gameId != null) {
      params['game_id'] = gameId;
    } else {
      /// Starting date/time for returned reports, in RFC3339 format
      /// with the hours, minutes, and seconds zeroed out and the UTC timezone: YYYY-MM-DDT00:00:00Z
      /// This must be on or after January 31, 2018.
      if (startedAt != null) {
        if (startedAt.isBefore(DateTime(2018, 1, 31))) {
          throw ArgumentError('startedAt must be on or after January 31, 2018');
        }

        params['started_at'] =
            DateTime(startedAt.year, startedAt.month, startedAt.day, 0, 0, 0)
                .toUtc()
                .toIso8601String();
      }

      /// Ending date/time for returned reports, in RFC3339 format
      /// with the hours, minutes, and seconds zeroed out and the UTC timezone: YYYY-MM-DDT00:00:00Z
      if (endedAt != null) {
        params['ended_at'] =
            DateTime(endedAt.year, endedAt.month, endedAt.day, 0, 0, 0)
                .toUtc()
                .toIso8601String();
      }

      /// This applies only to queries without [extensionId].
      if (after != null) {
        params['after'] = after;
      }
    }

    final url = Uri.parse(createUrl('/analytics/games?') +
        params.entries.map((e) => '${e.key}=${e.value}').join('&'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets a ranked list of Bits leaderboard information for an authorized broadcaster.
  Future<TwitchResponse> getBitsLeaderboard(
      {int count = 10,
      String period = 'all',
      DateTime? startedAt,
      String? userId}) async {
    if (!periods.contains(period.toLowerCase())) {
      throw ArgumentError('Invalid period: $period');
    }

    final params = <String, String>{
      'count': (count > 100 ? 100 : count).toString(),
      'period': period.toLowerCase(),
    };

    if (startedAt != null) {
      params['started_at'] =
          DateTime(startedAt.year, startedAt.month, startedAt.day, 0, 0, 0)
              .toUtc()
              .toIso8601String();
    }

    if (userId != null) {
      params['user_id'] = userId;
    }

    final url = Uri.parse(createUrl('/bits/leaderboard?') +
        params.entries.map((e) => '${e.key}=${e.value}').join('&'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Retrieves the list of available Cheermotes, animated emotes to which viewers can assign Bits, to cheer in chat. Cheermotes returned are available throughout Twitch, in all Bits-enabled channels.
  /// [broadcasterId] The broadcaster's ID.
  Future<TwitchResponse> getCheermotes({String? broadcasterId}) async {
    final params = <String, String>{
      ...broadcasterId != null ? {'broadcaster_id': broadcasterId} : {},
    };

    final url = Uri.parse(createUrl('/bits/cheermotes?') +
        params.entries.map((e) => '${e.key}=${e.value}').join('&'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets the list of Extension transactions for a given Extension.
  /// This allows Extension back-end servers to fetch a list of transactions that have occurred for their Extension across all of Twitch.
  /// A transaction is a record of a user exchanging Bits for an in-Extension digital good.
  Future<TwitchResponse> getExtensionTransactions({String? extensionId}) async {
    final params = <String, String>{
      ...extensionId != null ? {'extension_id': extensionId} : {},
    };

    final url = Uri.parse(createUrl('/extensions/transactions?') +
        params.entries.map((e) => '${e.key}=${e.value}').join('&'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets channel information for users.
  /// [broadcasterIds] A list of broadcaster ids (maximum 100, will be truncated otherwise).
  Future<TwitchResponse> getChannelInformation(
      List<String> broadcasterIds) async {
    if (broadcasterIds.isEmpty) {
      throw ArgumentError('broadcasterIds must not be empty');
    }

    if (broadcasterIds.length > 100) {
      broadcasterIds = broadcasterIds.sublist(0, 100);
    }

    final url = Uri.parse(createUrl(
        '/channels?${broadcasterIds.map((e) => 'broadcaster_id=$e').join('&')}'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Modifies channel information for users.
  /// [broadcasterId] The broadcaster's ID.
  /// [gameId] 	The current game ID being played on the channel. Use “0” or “” (an empty string) to unset the game.
  /// [broadcasterLanguage] The language of the channel. A language value must be either the ISO 639-1 two-letter code for a supported stream language or “other”.
  /// [title] The title of the stream. Value must not be an empty string.
  /// [delay] 	Stream delay in seconds. Stream delay is a Twitch Partner feature; trying to set this value for other account types will return a 400 error.
  Future<TwitchResponse> modifyChannelInformation(
    String broadcasterId, {
    String? gameId,
    String? broadcasterLanguage,
    String? title,
    int? delay,
  }) async {
    if (gameId != null &&
        broadcasterLanguage != null &&
        title != null &&
        delay != null) {
      throw ArgumentError(
          'At least one of gameId, broadcasterLanguage, title, delay should be set');
    }

    final params = <String, String>{
      ...gameId != null ? {'game_id': gameId} : {},
      ...broadcasterLanguage != null
          ? {'broadcaster_language': broadcasterLanguage}
          : {},
      ...title != null ? {'title': title} : {},
      ...delay != null ? {'delay': delay.toString()} : {},
    };

    if (params.isEmpty) {
      throw ArgumentError(
          'At least one of gameId, broadcasterLanguage, title, delay should be set');
    }

    final url =
        Uri.parse(createUrl('/channels/?broadcaster_id=$broadcasterId?'));

    final response = await http.patch(url,
        headers: _createHeaders(), body: json.encode(params));

    return _handleResponse(response);
  }

  /// Gets a list of users who have editor permissions for a specific channel.
  Future<TwitchResponse> getChannelEditors(String broadcasterId) async {
    final url =
        Uri.parse(createUrl('/channels/editors?broadcaster_id=$broadcasterId'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Create a Custom Reward on a channel
  /// [broadcasterId] The broadcaster's ID.
  /// [title] The title of the reward.
  /// [cost] The cost of the reward.
  /// [prompt] The prompt for the viewer when redeeming the reward.
  /// [isEnabled] Is the reward currently enabled, if false the reward won’t show up to viewers.
  /// [backgroundColor] Custom background color for the reward. Format: Hex with # prefix. Example: #00E5CB.
  /// [isUserInputRequired] Does the user need to enter information when redeeming the reward.
  /// [isMaxPerStreamEnabled] Whether a maximum per stream is enabled.
  /// [maxPerStream] The maximum number per stream if enabled.
  /// [isMaxPerUserPerStreamEnabled] Whether a maximum per user per stream is enabled.
  /// [maxPerUserPerStream] The maximum number per user per stream if enabled.
  /// [isGlobalCooldownEnabled] Whether a cooldown is enabled
  /// [globalCooldownSeconds] The cooldown in seconds if enabled.
  /// [shouldRedemptionSkipRequestQueue] Should redemptions be set to FULFILLED status immediately when redeemed and skip the request queue instead of the normal UNFULFILLED status.
  Future<TwitchResponse> createCustomReward(
    String broadcasterId,
    String title,
    int cost, {
    String? prompt,
    bool? isEnabled = true,
    String? backgroundColor,
    bool? isUserInputRequired = false,
    bool? isMaxPerStreamEnabled = false,
    int? maxPerStream,
    bool? isMaxPerUserPerStreamEnabled = false,
    int? maxPerUserPerStream,
    bool? isGlobalCooldownEnabled = false,
    int? globalCooldownSeconds,
    bool? shouldRedemptionSkipRequestQueue = false,
  }) async {
    final url = Uri.parse(createUrl(
        '/channels_points/custom_rewards?broadcaster_id=$broadcasterId'));

    if (backgroundColor != null) {
      if (!backgroundColor.startsWith('#}')) {
        throw ArgumentError(
            'backgroundColor must be a hex string starting with #');
      }
    }

    if (isMaxPerStreamEnabled != null &&
        isMaxPerStreamEnabled &&
        maxPerStream == null) {
      throw ArgumentError(
          'maxPerStream must be set if isMaxPerStreamEnabled is true');
    }

    if (isMaxPerUserPerStreamEnabled != null &&
        isMaxPerUserPerStreamEnabled &&
        maxPerUserPerStream == null) {
      throw ArgumentError(
          'maxPerUserPerStream must be set if isMaxPerUserPerStreamEnabled is true');
    }

    if (isGlobalCooldownEnabled != null &&
        isGlobalCooldownEnabled &&
        globalCooldownSeconds == null) {
      throw ArgumentError(
          'globalCooldownSeconds must be set if isGlobalCountdownEnabled is true');
    }

    final params = <String, String>{
      'title': title,
      'cost': cost.toString(),
      ...prompt != null ? {'prompt': prompt} : {},
      ...isEnabled != null ? {'is_enabled': isEnabled.toString()} : {},
      ...backgroundColor != null ? {'background_color': backgroundColor} : {},
      ...isUserInputRequired != null
          ? {'is_user_input_required': isUserInputRequired.toString()}
          : {},
      ...isMaxPerStreamEnabled != null
          ? {'is_max_per_stream_enabled': isMaxPerStreamEnabled.toString()}
          : {},
      ...maxPerStream != null
          ? {'max_per_stream': maxPerStream.toString()}
          : {},
      ...isMaxPerUserPerStreamEnabled != null
          ? {
              'is_max_per_user_per_stream_enabled':
                  isMaxPerUserPerStreamEnabled.toString()
            }
          : {},
      ...maxPerUserPerStream != null
          ? {'max_per_user_per_stream': maxPerUserPerStream.toString()}
          : {},
      ...isGlobalCooldownEnabled != null
          ? {'is_global_countdown_enabled': isGlobalCooldownEnabled.toString()}
          : {},
      ...globalCooldownSeconds != null
          ? {'global_cooldown_seconds': globalCooldownSeconds.toString()}
          : {},
      ...shouldRedemptionSkipRequestQueue != null
          ? {
              'should_redemption_skip_request_queue':
                  shouldRedemptionSkipRequestQueue.toString()
            }
          : {},
    };

    final response = await http.post(url,
        headers: _createHeaders(), body: json.encode(params));

    return _handleResponse(response);
  }

  /// Deletes a Custom Reward on a channel.
  /// The Custom Reward specified by id must have been created by the [clientId] attached to the OAuth token in order to be deleted
  /// [broadcasterId] The broadcaster's ID.
  /// [id] The ID of the Custom Reward to delete.
  Future<TwitchResponse> deleteCustomReward(
      String broadcasterId, String id) async {
    final url = Uri.parse(createUrl(
        '/channels_points/custom_rewards?broadcaster_id=$broadcasterId&id=$id'));

    final response = await http.delete(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Returns a list of Custom Reward objects for the Custom Rewards on a channel.
  /// [broadcasterId] The broadcaster's ID.
  /// [id] When used, this parameter filters the results and only returns reward objects for the Custom Rewards with matching ID. Maximum: 50
  /// [onlyManageableRewards] When set to true, only returns custom rewards that the calling [clientId] can manage.
  Future<TwitchResponse> getCustomReward(String broadcasterId,
      {String? id, bool? onlyManageableRewards = true}) async {
    final params = <String, String>{
      ...id != null ? {'id': id} : {},
      ...onlyManageableRewards != null
          ? {'only_manageable_rewards': onlyManageableRewards.toString()}
          : {},
    };

    final url = Uri.parse(createUrl(
        '/channels_points/custom_rewards?broadcaster_id=$broadcasterId${params.isNotEmpty ? '&${params.keys.join('&')}=${params.values.join('&')}' : ''}'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Returns Custom Reward Redemption objects for a Custom Reward on a channel that was created by the same [clientId].
  /// Developers only have access to get and update redemptions for the rewards created programmatically by the same [clientId].
  /// [broadcasterId] The broadcaster's ID.
  /// [rewardId] When [id] is not provided, this parameter returns paginated Custom Reward Redemption objects for redemptions of the Custom Reward with ID [rewardId].
  /// [id] When used, this param filters the results and only returns Custom Reward Redemption objects for the redemptions with matching ID. Maximum: 50
  /// [status] When id is not provided, this param is required and filters the paginated Custom Reward Redemption objects for redemptions with the matching status. Can be one of `UNFULFILLED`, `FULFILLED` or `CANCELED`
  /// [sort] Sort order of redemptions returned when getting the paginated Custom Reward Redemption objects for a reward. One of: `OLDEST`, `NEWEST`.
  /// [after] Cursor for forward pagination: tells the server where to start fetching the next set of results, in a multi-page response. This applies only to queries without ID. If an ID is specified, it supersedes any cursor/offset combinations. The cursor value specified here is from the pagination response field of a prior query.
  /// [first] Number of results to be returned when getting the paginated Custom Reward Redemption objects for a reward. Limit: 50. Default: 20.
  Future<TwitchResponse> getCustomRewardRedemption(
      String broadcasterId, String rewardId,
      {String? id,
      String? status,
      String? sort = 'OLDEST',
      String? after,
      int? first = 20}) async {
    if (status != null &&
        !statusCustomRewardRedemption.contains(status.toUpperCase())) {
      throw ArgumentError(
          'status must be one of UNFULFILLED, FULFILLED or CANCELED');
    }

    if (sort != null &&
        !sortCustomRewardRedemption.contains(sort.toUpperCase())) {
      throw ArgumentError('sort must be one of OLDEST, NEWEST');
    }

    if (first != null && first > 50) {
      first = 50;
    }

    final params = <String, String>{
      ...id != null ? {'id': id} : {},
      ...status != null ? {'status': status} : {},
      ...sort != null ? {'sort': sort} : {},
      ...after != null ? {'after': after} : {},
      ...first != null ? {'first': first.toString()} : {},
    };

    final url = Uri.parse(createUrl(
        '/channels_points/custom_rewardsredemptions?broadcaster_id=$broadcasterId${params.isNotEmpty ? '&${params.keys.join('&')}=${params.values.join('&')}' : ''}'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Updates a Custom Reward created on a channel.
  /// The Custom Reward specified by [id] must have been created by the [clientId] attached to the user OAuth token.
  /// [broadcasterId] The broadcaster's ID.
  /// [id] The ID of the Custom Reward to update.
  /// [title] The title of the reward.
  /// [cost] The cost of the reward.
  /// [prompt] The prompt for the viewer when redeeming the reward.
  /// [isEnabled] Is the reward currently enabled, if false the reward won’t show up to viewers.
  /// [backgroundColor] Custom background color for the reward. Format: Hex with # prefix. Example: #00E5CB.
  /// [isUserInputRequired] Does the user need to enter information when redeeming the reward.
  /// [isMaxPerStreamEnabled] Whether a maximum per stream is enabled.
  /// [maxPerStream] The maximum number per stream if enabled.
  /// [isMaxPerUserPerStreamEnabled] Whether a maximum per user per stream is enabled.
  /// [maxPerUserPerStream] The maximum number per user per stream if enabled.
  /// [isGlobalCooldownEnabled] Whether a cooldown is enabled
  /// [globalCooldownSeconds] The cooldown in seconds if enabled.
  /// [isPaused] Is the reward currently paused, if true viewers cannot redeem
  /// [shouldRedemptionSkipRequestQueue] Should redemptions be set to FULFILLED status immediately when redeemed and skip the request queue instead of the normal UNFULFILLED status.
  Future<TwitchResponse> updateCustomReward(
    String broadcasterId,
    String id, {
    String? title,
    int? cost,
    String? prompt,
    bool? isEnabled = true,
    String? backgroundColor,
    bool? isUserInputRequired = false,
    bool? isMaxPerStreamEnabled = false,
    int? maxPerStream,
    bool? isMaxPerUserPerStreamEnabled = false,
    int? maxPerUserPerStream,
    bool? isGlobalCooldownEnabled = false,
    int? globalCooldownSeconds,
    bool? isPaused,
    bool? shouldRedemptionSkipRequestQueue = false,
  }) async {
    if (backgroundColor != null) {
      if (!backgroundColor.startsWith('#}')) {
        throw ArgumentError(
            'backgroundColor must be a hex string starting with #');
      }
    }

    if (isMaxPerStreamEnabled != null &&
        isMaxPerStreamEnabled &&
        maxPerStream == null) {
      throw ArgumentError(
          'maxPerStream must be set if isMaxPerStreamEnabled is true');
    }

    if (isMaxPerUserPerStreamEnabled != null &&
        isMaxPerUserPerStreamEnabled &&
        maxPerUserPerStream == null) {
      throw ArgumentError(
          'maxPerUserPerStream must be set if isMaxPerUserPerStreamEnabled is true');
    }

    if (isGlobalCooldownEnabled != null &&
        isGlobalCooldownEnabled &&
        globalCooldownSeconds == null) {
      throw ArgumentError(
          'globalCooldownSeconds must be set if isGlobalCountdownEnabled is true');
    }

    final params = <String, String>{
      ...title != null ? {'title': title} : {},
      ...cost != null ? {'cost': cost.toString()} : {},
      ...prompt != null ? {'prompt': prompt} : {},
      ...isEnabled != null ? {'is_enabled': isEnabled.toString()} : {},
      ...backgroundColor != null ? {'background_color': backgroundColor} : {},
      ...isUserInputRequired != null
          ? {'is_user_input_required': isUserInputRequired.toString()}
          : {},
      ...isMaxPerStreamEnabled != null
          ? {'is_max_per_stream_enabled': isMaxPerStreamEnabled.toString()}
          : {},
      ...maxPerStream != null
          ? {'max_per_stream': maxPerStream.toString()}
          : {},
      ...isMaxPerUserPerStreamEnabled != null
          ? {
              'is_max_per_user_per_stream_enabled':
                  isMaxPerUserPerStreamEnabled.toString()
            }
          : {},
      ...maxPerUserPerStream != null
          ? {'max_per_user_per_stream': maxPerUserPerStream.toString()}
          : {},
      ...isGlobalCooldownEnabled != null
          ? {'is_global_countdown_enabled': isGlobalCooldownEnabled.toString()}
          : {},
      ...globalCooldownSeconds != null
          ? {'global_cooldown_seconds': globalCooldownSeconds.toString()}
          : {},
      ...isPaused != null ? {'is_paused': isPaused.toString()} : {},
      ...shouldRedemptionSkipRequestQueue != null
          ? {
              'should_redemption_skip_request_queue':
                  shouldRedemptionSkipRequestQueue.toString()
            }
          : {},
    };

    final url = Uri.parse(createUrl(
        '/channels_points/custom_rewards?broadcaster_id=$broadcasterId&id=$id'));

    final response = await http.put(url,
        headers: _createHeaders(), body: json.encode(params));

    return _handleResponse(response);
  }

  /// Updates the status of Custom Reward Redemption objects on a channel that are in the UNFULFILLED status.
  /// [id] ID of the Custom Reward Redemption to update, must match a Custom Reward Redemption on [broadcasterId]’s channel. Maximum: 50.
  /// [broadcasterId] The broadcaster's ID.
  /// [rewardId] ID of the Custom Reward the redemptions to be updated are for.
  /// [status] The status to set the redemptions to.
  ///
  Future<TwitchResponse> updateCustomRewardRedemptions(
      String id, String broadcasterId, String rewardId, String status) async {
    if (!statusCustomRewardRedemption.contains(status)) {
      throw ArgumentError(
          'status must be one of ${statusCustomRewardRedemption.join(', ')}');
    }

    final url = Uri.parse(createUrl(
        '/channel_points/custom_rewards/redemptions?broadcaster_id=$broadcasterId&id=$id&reward_id=$rewardId'));

    final response = await http.put(url,
        headers: _createHeaders(), body: json.encode({'status': status}));

    return _handleResponse(response);
  }

  /// Updates the status of Custom Reward Redemption objects on a channel that are in the UNFULFILLED status.
  /// [id] ID of the Custom Reward Redemption to update, must match a Custom Reward Redemption on [broadcasterId]’s channel. Maximum: 50.
  /// [broadcasterId] The broadcaster's ID.
  /// [rewardId] ID of the Custom Reward the redemptions to be updated are for.
  /// [status] The status to set the redemptions to.
  Future<TwitchResponse> updateRedemptionStatus(
      String id, String rewardId, String status) async {
    if (!statusCustomRewardRedemption.contains(status)) {
      throw ArgumentError(
          'status must be one of ${statusCustomRewardRedemption.join(', ')}');
    }

    final url = Uri.parse(createUrl(
        '/channel_points/custom_rewards/redemptions?broadcaster_id=$id&reward_id=$rewardId'));

    final response = await http.put(url,
        headers: _createHeaders(), body: json.encode({'status': status}));

    return _handleResponse(response);
  }

  /// Gets all emotes that the specified Twitch channel created.
  /// Broadcasters create these custom emotes for users who subscribe to or follow the channel, or cheer Bits in the channel’s chat window.
  /// NOTE: With the exception of custom follower emotes, users may use custom emotes in any Twitch chat.
  /// [broadcasterId] The broadcaster's ID.
  Future<TwitchResponse> getChannelEmotes(String broadcasterId) async {
    final url =
        Uri.parse(createUrl('/chat/emotes?broadcaster_id=$broadcasterId'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets all [global emotes](https://www.twitch.tv/creatorcamp/en/learn-the-basics/emotes/).
  /// Global emotes are Twitch-created emoticons that users can use in any Twitch chat.
  Future<TwitchResponse> getGlobalEmotes() async {
    final url = Uri.parse(createUrl('/emotes/global'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets emotes for one or more specified emote sets.
  /// An emote set groups emotes that have a similar context. For example, Twitch places all the subscriber emotes that a broadcaster uploads for their channel in the same emote set.
  /// [emoteSetIds] An ID that identifies the emote set. Include the parameter for each emote set you want to get. Maximum 25 or will be truncated.
  Future<TwitchResponse> getEmoteSets(List<String> emoteSetIds) async {
    if (emoteSetIds.isEmpty) {
      throw ArgumentError('emoteSetIds must not be empty');
    }

    if (emoteSetIds.length > 25) {
      emoteSetIds = emoteSetIds.sublist(0, 25);
    }

    final url = Uri.parse(createUrl(
        '/chat/emotes/set/?ids=${emoteSetIds.map((id) => 'emote_set_id=$id').join('&')}'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets a list of custom chat badges that can be used in chat for the specified channel.
  /// This includes subscriber badges and Bit badges.
  /// [broadcasterId] The broadcaster's ID.
  Future<TwitchResponse> getChannelChatBadges(String broadcasterId) async {
    final url =
        Uri.parse(createUrl('/chat/badges?broadcaster_id=$broadcasterId'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets a list of chat badges that can be used in chat for any channel.
  Future<TwitchResponse> getGlobalChatBadges() async {
    final url = Uri.parse(createUrl('/chat/badges/global'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Gets the broadcaster’s chat settings.
  /// [broadcasterId] The broadcaster's ID.
  /// [moderatorId] Required only to access the non_moderator_chat_delay or non_moderator_chat_delay_duration settings.
  /// The ID of a user that has permission to moderate the broadcaster’s chat room. This ID must match the user ID associated with the user OAuth token.
  /// If the broadcaster wants to get their own settings (instead of having the moderator do it), set this parameter to the broadcaster’s ID, too.
  Future<TwitchResponse> getChatSettings(
      String broadcasterId, String moderatorId) async {
    final url = Uri.parse(createUrl(
        '/chat/settings?broadcaster_id=$broadcasterId&moderator_id=$moderatorId'));

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Updates the broadcaster’s chat settings.
  /// [broadcasterId] The broadcaster's ID.
  /// [moderatorId] The ID of a user that has permission to moderate the broadcaster’s chat room. This ID must match the user ID associated with the user OAuth token.
  /// If the broadcaster wants to update their own settings (instead of having the moderator do it), set this parameter to the broadcaster’s ID, too.
  /// [emoteMode] A Boolean value that determines whether chat messages must contain only emotes.
  /// [followerMode] 	A Boolean value that determines whether the broadcaster restricts the chat room to followers only, based on how long they’ve followed.
  /// [followerModeDuration] The length of time, in minutes, that the followers must have followed the broadcaster to participate in the chat room
  /// [nonModeratorChatDelay] A Boolean value that determines whether the broadcaster adds a short delay before chat messages appear in the chat room. This gives chat moderators and bots a chance to remove them before viewers can see the message.
  /// [nonModeratorChatDelayDuration] The length of time, in seconds, that the broadcaster adds a short delay before chat messages appear in the chat room. This gives chat moderators and bots a chance to remove them before viewers can see the message.
  /// [slowMode] A Boolean value that determines whether the broadcaster limits how often users in the chat room are allowed to send messages.
  /// [slowModeWaitTime]The amount of time, in seconds, that users need to wait between sending messages.
  /// [subscriberMode] A Boolean value that determines whether only users that subscribe to the broadcaster’s channel can talk in the chat room.
  /// [uniqueChatMode] A Boolean value that determines whether the broadcaster requires users to post only unique messages in the chat room.
  Future<TwitchResponse> updateChatSettings(
      String broadcasterId, String moderatorId,
      {bool? emoteMode = false,
      bool? followerMode = true,
      int? followerModeDuration = 0,
      bool? nonModeratorChatDelay = false,
      int? nonModeratorChatDelayDuration = 2,
      bool? slowMode = false,
      int? slowModeWaitTime = 30,
      bool? subscriberMode = false,
      bool? uniqueChatMode = false}) async {
    final url = Uri.parse(createUrl(
        '/chat/settings?broadcaster_id=$broadcasterId&moderator_id=$moderatorId'));

    if (nonModeratorChatDelayDuration != null &&
        !nonModeratorChatDelayDurations
            .contains(nonModeratorChatDelayDuration)) {
      throw ArgumentError(
          'nonModeratorChatDelayDuration must be one of: ${nonModeratorChatDelayDurations.join(', ')}');
    }

    if (slowModeWaitTime != null) {
      if (slowModeWaitTime < 3 || slowModeWaitTime > 120) {
        throw ArgumentError('slowModeWaitTime must be between 3 and 120');
      }
    }

    final params = {
      ...?emoteMode != null ? {'emote_mode': emoteMode} : null,
      ...?followerMode != null ? {'follower_mode': followerMode} : null,
      ...?followerModeDuration != null
          ? {'follower_mode_duration': followerModeDuration}
          : null,
      ...?nonModeratorChatDelay != null
          ? {'non_moderator_chat_delay': nonModeratorChatDelay}
          : null,
      ...?nonModeratorChatDelayDuration != null
          ? {'non_moderator_chat_delay_duration': nonModeratorChatDelayDuration}
          : null,
      ...?slowMode != null ? {'slow_mode': slowMode} : null,
      ...?slowModeWaitTime != null
          ? {'slow_mode_wait_time': slowModeWaitTime}
          : null,
      ...?subscriberMode != null ? {'subscriber_mode': subscriberMode} : null,
      ...?uniqueChatMode != null ? {'unique_chat_mode': uniqueChatMode} : null,
    };

    final response = await http.patch(url,
        headers: _createHeaders(), body: json.encode(params));

    return _handleResponse(response);
  }

  /// Creates a clip programmatically.
  /// This returns both an ID and an edit URL for the new clip.
  /// [broadcasterId] The broadcaster's ID.
  /// [hasDelay] If false, the clip is captured from the live stream when the API is called
  Future<TwitchResponse> createClip(String broadcasterId,
      {bool? hasDelay = false}) async {
    final url = Uri.parse(
        createUrl('/clips?broacaster_id=$broadcasterId&has_delay=$hasDelay'));

    final response = await http.post(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  Future<TwitchResponse> getClip(
      String broadcasterId, String gameId, List<String> ids,
      {String? after,
      String? before,
      DateTime? endedAt,
      int? first,
      DateTime? startedAt}) async {}

  /// Gets information about one or more specified Twitch users.
  /// Users are identified by optional user [ids] and/or [logins] name.
  /// If neither a user ID nor a login name is specified, the user is looked up by Bearer token.
  /// [ids] User ID. Multiple user IDs can be specified. Limit: 100.
  /// [logins] User login name. Multiple user logins can be specified. Limit: 100.
  ///
  /// Note: The limit of 100 IDs and login names is the total limit.
  /// You can request, for example, 50 of each or 100 of one of them.
  /// You cannot request 100 of both.
  Future<TwitchResponse> getUsers(
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

    final response = await http.get(url, headers: _createHeaders());

    return _handleResponse(response);
  }

  /// Create the headers for the request.
  Map<String, String> _createHeaders() => {
        'Client-ID': clientId,
        'Authorization': 'Bearer $appToken',
        'Content-Type': 'application/json',
      };

  /// Handle response error resolution
  Future<TwitchResponse> _handleResponse(http.Response response) async {
    switch (response.statusCode) {
      case 200:
      case 204:
        return TwitchResponse.fromResponse(response);
      case 400:
        throw Exception('Bad Request');
      case 401:
        throw Exception('Unauthorized');
      case 403:
        throw Exception('Forbidden');
      case 429:
        throw TwitchApiRateLimitedException(response);
      case 404:
        throw TwitchNotFoundException(response);
      case 500:
        throw Exception('Internal Server Error');
      default:
        throw Exception('Unexpected status code: ${response.statusCode}');
    }
  }
}
