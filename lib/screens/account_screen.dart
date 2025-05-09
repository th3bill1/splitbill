import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/billsplit_provider.dart';
import 'edit_account_screen.dart';
import '../models/bill.dart';
import 'package:splitbill/screens/billsplit_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final imageBytes = ref.watch(userProvider.notifier).downloadImage(user!.id);
    final billSplits = ref.watch(billsplitProvider(user.id));

    List<Bill> recentBills =
        billSplits.expand((billSplit) => billSplit.bills).toList();
    recentBills.sort((a, b) => b.lastUpdateDate.compareTo(a.lastUpdateDate));

    recentBills = recentBills.take(5).toList();

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text(
              'Recent Bills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: recentBills.isEmpty
                  ? const Center(
                      child: Text(
                        'No recent bills available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: recentBills.length,
                      itemBuilder: (context, index) {
                        final bill = recentBills[index];
                        return ListTile(
                          title: Text(bill.name),
                          subtitle:
                              Text('Amount: ${bill.currency} ${bill.amount}'),
                          trailing: Text(
                            '${bill.lastUpdateDate.toLocal()}'.split(' ')[0],
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            final billsplit = billSplits.firstWhere(
                                (element) => element.bills.contains(bill));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BillSplitScreen(billsplit: billsplit)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
