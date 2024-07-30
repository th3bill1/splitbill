import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<User?> {
  final Ref _ref;
  UserNotifier(this._ref) : super(null);

  Future<void> loadUser(String userId) async {
    final user = await _ref.read(firestoreServiceProvider).getUser(userId);
    state = user;
  }

  Future<void> addUser(User user) async {
    await _ref.read(firestoreServiceProvider).addUser(user);
    state = user;
  }

  Future<void> updateUser(User user) async {
    await _ref.read(firestoreServiceProvider).updateUser(user);
    state = user;
  }

  Future<void> addFriend(String friendId) async {
    if (state != null) {
      await _ref.read(firestoreServiceProvider).addFriend(state!.id, friendId);
      await loadUser(state!.id);
    }
  }
}

final friendListProvider =
    StreamProvider.family<List<User>, String>((ref, userId) {
  return ref.read(firestoreServiceProvider).getFriends(userId);
});
