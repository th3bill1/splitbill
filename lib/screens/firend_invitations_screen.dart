import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class FriendInvitationsScreen extends ConsumerStatefulWidget {
  final String userId;

  const FriendInvitationsScreen({super.key, required this.userId});

  @override
  _FriendInvitationsScreenState createState() =>
      _FriendInvitationsScreenState();
}

class _FriendInvitationsScreenState
    extends ConsumerState<FriendInvitationsScreen> {
  @override
  Widget build(BuildContext context) {
    final invitations = ref.watch(friendInvitationsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Invitations'),
      ),
      body: invitations.when(
        data: (invitations) => ListView.builder(
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
                  final user = snapshot.data!;
                  return ListTile(
                    title: Text('Invitation from ${user.name}'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(userProvider.notifier)
                            .acceptFriendInvitation(invitation.id);
                        setState(() {
                          invitations.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invitation accepted')),
                        );
                      },
                      child: const Text('Accept'),
                    ),
                  );
                }
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Error loading invitations')),
      ),
    );
  }
}
