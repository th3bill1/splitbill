import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/screens/add_billsplit_screen.dart';
import 'package:splitbill/screens/billsplit_detail_screen.dart';
import '../providers/auth_provider.dart';

class BillSplitListScreen extends ConsumerWidget {
  const BillSplitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final billSplits = ref.watch(billsplitProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BillSplits'),
      ),
      body: ListView.builder(
        itemCount: billSplits.length,
        itemBuilder: (context, index) {
          final billsplit = billSplits[index];
          return ListTile(
            title: Text(billsplit.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BillSplitDetailScreen(billsplit: billsplit)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBillSplitScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
