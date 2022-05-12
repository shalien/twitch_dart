/// Twitch api url
const apiBaseUrl = 'https://api.twitch.tv/helix/';

/// Format the url
String createUrl(String path) => '$apiBaseUrl$path';

/// Allow commercial time
List<int> commercialLengths = [30, 60, 90, 120, 150, 180];

/// Allowed periods
List<String> periods = ['day', 'week', 'month', 'year', 'all'];

List<String> sortCustomRewardRedemption = ['OLDEST', 'NEWEST'];

List<String> statusCustomRewardRedemption = [
  'UNFULFILLED',
  'FULFILLED',
  'CANCELED'
];

List<int> nonModeratorChatDelayDurations = [2, 4, 6];
