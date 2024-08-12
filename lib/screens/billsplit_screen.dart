import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/providers/user_provider.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Overview Section
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: const Text('Total Spent'),
              subtitle: Text(
                  '${currentBillSplit.defaultCurrency} ${_calculateTotalAmount(currentBillSplit)}'),
              trailing: Text('${currentBillSplit.bills.length} Bills'),
            ),
          ),
          const SizedBox(height: 16.0),

          // Detailed Breakdown
          const Text(
            'Participant Balances',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          _buildParticipantBalances(ref, currentBillSplit),
          const SizedBox(height: 16.0),

          // Payment Instructions
          const Text(
            'Payment Instructions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          _buildPaymentInstructions(ref, currentBillSplit),
          const SizedBox(height: 16.0),

          // Bills List
          const Text(
            'Bills',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          ...currentBillSplit.bills.map((bill) => ListTile(
                title: Text(bill.name),
                subtitle: Text('Paid by: ${_getUserName(ref, bill.payerId)}'),
                trailing: Text('${bill.currency} ${bill.amount}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BillScreen(
                            bill: bill, billsplit: currentBillSplit)),
                  );
                },
              )),
        ],
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

  double _calculateTotalAmount(BillSplit billSplit) {
    return billSplit.bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  Widget _buildParticipantBalances(WidgetRef ref, BillSplit billSplit) {
    // Here you would calculate the net balance for each participant.
    // This is just a placeholder.
    return Column(
      children: billSplit.participantsIds.map((participantId) {
        return ListTile(
          title: Text(_getUserName(ref, participantId)),
          subtitle: const Text('Balance: \$XX.XX'), // Placeholder balance
        );
      }).toList(),
    );
  }

  Widget _buildPaymentInstructions(WidgetRef ref, BillSplit billSplit) {
    // This is where you would calculate and display who owes whom.
    // This is just a placeholder.
    return Column(
      children: [
        ListTile(
          title: Text(
              '${_getUserName(ref, 'userId1')} should pay ${_getUserName(ref, 'userId2')}'),
          trailing: const Text('\$XX.XX'),
        ),
        // More payment instructions...
      ],
    );
  }

  String _getUserName(WidgetRef ref, String userId) {
    final user = ref.watch(userByIdProvider(userId)).maybeWhen(
          data: (user) => user?.name ?? 'Unknown',
          orElse: () => 'Unknown',
        );
    return user;
  }
}
