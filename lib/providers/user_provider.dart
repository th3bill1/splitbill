import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(User(
            name: 'John',
            surname: 'Doe',
            email: 'john.doe@example.com',
            icon: 'assets/user_icon.png'));

  void updateUser(User user) {
    state = user;
  }

  void updateIcon(String iconPath) {
    state = User(
        name: state.name,
        surname: state.surname,
        email: state.email,
        icon: iconPath);
  }

  void updateDetails(
      {required String name, required String surname, required String email}) {
    state = User(name: name, surname: surname, email: email, icon: state.icon);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
