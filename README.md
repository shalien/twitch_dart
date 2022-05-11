
A twitch API wrapper for Dart

## Features

The purpose of this package is to wrap the Twitch API to be able to easily use it inside any dart based project .

Currently it can be used on dart:io and dart:html.

## Getting started

run :

```sh
    dart pub add twitch_dart
```

## Usage

```dart

import 'package:twitch_dart/twitch_dart.dart';

/// Create a client 
/// See [https://dev.twitch.tv/docs/api](https://dev.twitch.tv/docs/api) to learn how to get client id / secret and token
final client = TwitchClient('clientId', 'clientSecret', 'token');

/// Get list of users (channnels) by login name
final users = await client.getUsers(logins: ['shalien']);

/// Print the list of users's display name and id
for(final user in users) {
    print('${user.displayName} - ${user.id}');
}

```

## Additional information

This package is in pre-release anything can be changed, broken without warning

## Disclaimer
The name `Twitch` is the property of Twitch, Inc.
This package is not affiliated with Twitch, Inc.
