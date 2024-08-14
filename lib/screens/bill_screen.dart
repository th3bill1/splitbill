import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/user_provider.dart';
import 'package:splitbill/screens/edit_bill_screen.dart';
import 'package:splitbill/models/user.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillDetailCard(
              context,
              title: 'Bill Name',
              content: bill.name,
              icon: Icons.label,
            ),
            const SizedBox(height: 10),
            _buildBillDetailCard(
              context,
              title: 'Amount',
              content: '${bill.currency} ${bill.amount.toStringAsFixed(2)}',
              icon: Icons.monetization_on,
            ),
            const SizedBox(height: 10),
            payer != null
                ? _buildBillDetailCard(
                    context,
                    title: 'Paid by',
                    content: payer.name,
                    icon: Icons.person,
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 10),
            _buildSplittersCard(context, splitters),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          content,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSplittersCard(
      BuildContext context, List<AsyncValue<User?>> splitters) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split between:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...splitters.map((splitterProvider) {
              return splitterProvider.when(
                data: (splitter) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    splitter!.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                loading: () => const ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Loading...'),
                ),
                error: (error, stack) => const ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Error loading user'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
