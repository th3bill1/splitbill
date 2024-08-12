import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/user_provider.dart';
import 'package:splitbill/screens/edit_bill_screen.dart';

class BillScreen extends ConsumerWidget {
  final Bill bill;
  final BillSplit billsplit;

  const BillScreen({super.key, required this.bill, required this.billsplit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payer = ref.watch(userByIdProvider(bill.payerId)).maybeWhen(
          data: (user) => user,
          orElse: () => null,
        );

    final splitters = bill.splittersIds.map((id) {
      return ref.watch(userByIdProvider(id));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(bill.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditBillScreen(bill: bill, billsplit: billsplit)));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill Name: ${bill.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Amount: ${bill.currency} ${bill.amount}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            payer != null
                ? Text('Paid by: ${payer.name}', style: const TextStyle(fontSize: 20))
                : const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('Split between:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            ...splitters.map((splitterProvider) {
              return splitterProvider.when(
                data: (splitter) =>
                    Text(splitter!.name, style: const TextStyle(fontSize: 18)),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const Text('Error loading user'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
