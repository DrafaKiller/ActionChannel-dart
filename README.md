[![Pub.dev package](https://img.shields.io/badge/pub.dev-action__channel-blue)](https://pub.dev/packages/action_channel)
[![GitHub repository](https://img.shields.io/badge/GitHub-ActionChannel--dart-blue?logo=github)](https://github.com/DrafaKiller/ActionChannel-dart)

# Action Channel

Communication channel, that bundles a sink and a stream. Wrapper with convenient functionalities.

Essentially it is a wrapper that acts as a sink and a stream, with additional logic.

## Features

- Allows the input/sink type to be different from the output/stream type, simplifying the entry point.
- Handling of "replies", allowing it to be used as a request-response channel.
- Run actions when receiving certain data.

## Getting Started 

```
dart pub add action_channel
```

And import the package:

```dart
import 'package:action_channel/action_channel.dart';
```

## Usage

Create a channel using a sink and a stream.

You may specify an action to be executed using the data returned in the `.on()` method.

```dart
final channel = Channel(
  sink, stream,
  action: (String data) => print('Action using "$data"')
);
```

### Listening for data

Listen to the channel with `.on()`, this will enable you to run an action with the returning data, like a "reply".

```dart
final subscription = channel.on((data) {
  print('Data received "$data"');
  return 'New action!';
});

subscription.cancel();

// Output:
// Data received "Hello!"
// Action using "New action!"
```

You can also use `.once()` to listen to the channel only once.

> **Note:** 
> The channel can be used just like a stream, with `.listen()`.

### Channel Controller

Create a channel using `ChannelController`, creating a channel that handles the sink and stream, by itself.
Abstracting the sink and stream creation.

A controller needs a function that transforms the input/sink data type into the output/stream data type.

It's recommended to use the `Channel.controller()` factory, which automatically creates a `ChannelController`.

```dart
final channel = Channel<int, User, void>.controller(
  (int id) => User(id),
);
```

In addition, it offers callbacks and the ability to append and prepend them.

```dart
final channel = Channel<int, User, void>.controller(
  (int id) => User(id),
  
  onAdded: (int id) => print('User $id added'),
  onData: (User user) => print('User with id "${ user.id }" received'),
  onListen: (subscription) => print('Channel listened'),
  onClose: () => print('Channel closed'),
);
```

## Example

<details>
  <summary>User Channel <code>(/example/main.dart)</code></summary>
    
  ```dart
  import 'package:action_channel/action_channel.dart'; 

  final users = <User>{
    User(1, 'John'),
    User(2, 'Tom', muted: true),
    User(3, 'Alex'),
  };

  void main() {
    final channel = Channel<int, User, String>.controller(
      (id) => users.firstWhere((user) => user.id == id),
      action: (message, user, channel) => user.say(message),
    );

    channel.where((user) => !user.muted).on((user) => 'Hello!');

    channel.once((data) {
      print('First user: ${ data.name }');
      return null;
    });

    channel.add(1);
    channel.add(2);
    channel.add(3);
  }

  /* -= Models =- */

  class User {
    final int id;
    final String name;
    final bool muted;

    User(this.id, this.name, { this.muted = false });

    void say(String message) => print('User $id says "$message"');
  }
  ```
</details>

## Contributing

Contributions are welcome! Please open an [issue](https://github.com/DrafaKiller/ActionChannel-dart/issues) or [pull request](https://github.com/DrafaKiller/ActionChannel-dart/pulls) if you find a bug or have a feature request.
