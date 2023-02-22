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