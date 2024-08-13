import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/friend_invitation.dart';
import '../providers/user_provider.dart';
import 'package:splitbill/widgets/badge.dart' as custom_badge;
import 'package:splitbill/screens/firend_invitations_screen.dart';
import 'package:splitbill/screens/add_friend_screen.dart';
import 'friend_profile_screen.dart';

class FriendListScreen extends ConsumerWidget {
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final friends = user != null
        ? ref.watch(friendListProvider(user.id))
        : const AsyncValue<List<User>>.loading();
    final invitations = user != null
        ? ref.watch(friendInvitationsProvider(user.id))
        : const AsyncValue<List<FriendInvitation>>.loading();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend List'),
        actions: [
          invitations.when(
            data: (invitations) => invitations.isNotEmpty
                ? IconButton(
                    icon: custom_badge.Badge(
                      value: invitations.length.toString(),
                      child: const Icon(Icons.people_rounded),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FriendInvitationsScreen(userId: user!.id),
                        ),
                      );
                    },
                  )
                : Container(),
            loading: () => Container(),
            error: (error, stack) => Container(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddFriendScreen()),
              );
            },
          ),
        ],
      ),
      body: friends.when(
        data: (friends) => ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return ListTile(
              title: Text(friend.name),
              subtitle: Text(friend.email),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FriendProfileScreen(friend: friend)),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Error loading friends')),
      ),
    );
  }
}
