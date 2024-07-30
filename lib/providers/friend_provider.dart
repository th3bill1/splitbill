import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';

class FriendNotifier extends StateNotifier<List<Friend>> {
  FriendNotifier() : super([]);

  void addFriend(Friend friend) {
    state = [...state, friend];
  }

  void removeFriend(Friend friend) {
    state = state.where((f) => f != friend).toList();
  }
}

final friendProvider =
    StateNotifierProvider<FriendNotifier, List<Friend>>((ref) {
  return FriendNotifier();
});
