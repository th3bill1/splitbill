import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/screens/billsplit_details_screen.dart';
import 'add_bill_screen.dart';
import '../providers/auth_provider.dart';
import 'package:splitbill/screens/bill_screen.dart';

class BillSplitScreen extends ConsumerWidget {
  final BillSplit billsplit;

  const BillSplitScreen({super.key, required this.billsplit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bill Split Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final currentBillSplit = ref
        .watch(billsplitProvider(user.uid))
        .firstWhere((b) => b.id == billsplit.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentBillSplit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BillSplitDetailsScreen(billSplit: currentBillSplit)),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: currentBillSplit.bills.length,
        itemBuilder: (context, index) {
          final bill = currentBillSplit.bills[index];
          return ListTile(
            title: Text(bill.name),
            subtitle: Text('Total: ${bill.currency} ${bill.amount}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BillScreen(bill: bill, billsplit: currentBillSplit)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddBillScreen(billsplitId: currentBillSplit.id)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
