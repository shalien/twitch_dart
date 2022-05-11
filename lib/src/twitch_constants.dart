const apiBaseUrl = 'https://api.twitch.tv/helix/';

String createUrl(String path) => '$apiBaseUrl$path';

List<int> commercialLengths = [30, 60, 90, 120, 150, 180];
