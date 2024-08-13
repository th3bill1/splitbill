import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'package:splitbill/providers/shared_billsplit_provider.dart';
import 'package:splitbill/screens/billsplit_screen.dart';
import 'package:splitbill/providers/user_provider.dart';

class FriendProfileScreen extends ConsumerWidget {
  final User friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedSplits = ref.watch(sharedBillSplitsProvider(friend.id));
    final imageBytes =
        ref.watch(userProvider.notifier).downloadImage(friend.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.group_off_rounded,
              color: Colors.red,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Remove Friend'),
                    content: const Text(
                        'Are you sure you want to remove this friend?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await ref.read(userProvider.notifier).removeFriend(friend.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Friend removed')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Friend's Icon with FutureBuilder to load image correctly
            FutureBuilder<Uint8List?>(
              future: imageBytes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 50,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const CircleAvatar(
                    backgroundImage: AssetImage('assets/default_avatar.png'),
                    radius: 50,
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  return CircleAvatar(
                    backgroundImage: MemoryImage(snapshot.data!),
                    radius: 50,
                  );
                } else {
                  return const CircleAvatar(
                    backgroundImage: AssetImage('assets/default_avatar.png'),
                    radius: 50,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Friend's Nickname
            Text(
              friend.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Friend's Email
            Text(
              friend.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Shared SplitBills Section
            const Text(
              'Shared Bill Splits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sharedSplits.when(
                data: (billSplits) => ListView.builder(
                  itemCount: billSplits.length,
                  itemBuilder: (context, index) {
                    final split = billSplits[index];
                    return ListTile(
                      title: Text(split.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BillSplitScreen(billsplit: split),
                          ),
                        );
                      },
                    );
                  },
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => const Center(
                  child: Text('Error loading shared splits'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
