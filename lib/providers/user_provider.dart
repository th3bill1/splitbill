import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/providers/auth_provider.dart';
import '../models/user.dart';
import '../models/friend_invitation.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref);
});

final userByIdProvider =
    FutureProvider.family<User?, String>((ref, userId) async {
  return ref.read(firestoreServiceProvider).getUser(userId);
});

const Uuid uuid = Uuid();

class UserNotifier extends StateNotifier<User?> {
  final Ref _ref;
  UserNotifier(this._ref) : super(null);
  final storageRef = FirebaseStorage.instance.ref();

  Future<void> loadUser(String userId) async {
    final user = await _ref.read(firestoreServiceProvider).getUser(userId);
    state = user;
  }

  Future<void> addUser(String email, String name) async {
    var id = _ref.read(authProvider)?.uid;
    if (id == null) throw Exception('Invalid id');
    User user = User(id: id, email: email, name: name, friends: []);
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

  Future<void> removeFriend(String friendId) async {
    if (state != null) {
      await _ref
          .read(firestoreServiceProvider)
          .removeFriend(state!.id, friendId);
      await loadUser(state!.id);
    }
  }

  Future<void> sendFriendInvitation(String friendName) async {
    final friend =
        await _ref.read(firestoreServiceProvider).getUserByNickname(friendName);
    if (friend != null && state != null) {
      await _ref
          .read(firestoreServiceProvider)
          .sendFriendInvitation(state!.id, friend.id);
    } else {
      final friend =
          await _ref.read(firestoreServiceProvider).getUserByEmail(friendName);
      if (friend != null && state != null) {
        await _ref
            .read(firestoreServiceProvider)
            .sendFriendInvitation(state!.id, friend.id);
      } else {
        throw Exception('Friend not found or user not authenticated');
      }
    }
  }

  Future<void> acceptFriendInvitation(String invitationId) async {
    await _ref
        .read(firestoreServiceProvider)
        .acceptFriendInvitation(invitationId);
    final userId = _ref.read(authProvider)?.uid;
    if (userId != null) {
      await loadUser(userId);
    }
  }

  void setUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  Future<void> uploadImage(String userId, String imagePath) async {
    final ref = storageRef.child('user_icons/$userId');
    File file = File(imagePath);
    await ref.putFile(file);
  }

  Future<Uint8List?> downloadImage(String userId) async {
    try {
      final ref = storageRef.child('user_icons/$userId');
      final data = await ref.getData();
      return data;
    } catch (e) {
      return null;
    }
  }
}

final friendListProvider =
    StreamProvider.family<List<User>, String>((ref, userId) {
  return ref.read(firestoreServiceProvider).getFriends(userId);
});

final friendInvitationsProvider =
    StreamProvider.family<List<FriendInvitation>, String>((ref, userId) {
  return ref.read(firestoreServiceProvider).getFriendInvitations(userId);
});
