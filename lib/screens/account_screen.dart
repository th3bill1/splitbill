import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import 'edit_account_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final imageBytes = ref.watch(userProvider.notifier).downloadImage(user!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditAccountScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                          backgroundImage:
                              AssetImage('assets/default_avatar.png'),
                          radius: 50,
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return CircleAvatar(
                          backgroundImage: MemoryImage(snapshot.data!),
                          radius: 50,
                        );
                      } else {
                        return const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/default_avatar.png'),
                          radius: 50,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Name: ${user.name}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Email: ${user.email}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
      ),
    );
  }
}
