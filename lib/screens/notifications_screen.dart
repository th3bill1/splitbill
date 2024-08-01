import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_invitation.dart';
import '../providers/user_provider.dart';
import 'package:splitbill/models/user.dart';
import 'package:splitbill/screens/firend_invitations_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final invitations = user != null
        ? ref.watch(friendInvitationsProvider(user.id))
        : const AsyncValue<List<FriendInvitation>>.loading();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: invitations.when(
        data: (invitations) {
          if (invitations.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          } else {
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                final invitation = invitations[index];
                return FutureBuilder<User?>(
                  future: ref
                      .read(firestoreServiceProvider)
                      .getUser(invitation.fromUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const ListTile(
                        title: Text('Error loading user data'),
                      );
                    } else {
                      return ListTile(
                        title: Text('You have a new friend invitation!'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendInvitationsScreen(userId: user!.id),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Error loading notifications')),
      ),
    );
  }
}
