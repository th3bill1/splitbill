import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/providers/user_provider.dart';
import 'package:splitbill/screens/billsplit_details_screen.dart';
import 'add_bill_screen.dart';
import '../providers/auth_provider.dart';
import 'package:splitbill/screens/bill_screen.dart';
import 'dart:math';

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
          const Text(
            'Participant Balances',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          _buildParticipantBalances(ref, currentBillSplit),
          const SizedBox(height: 16.0),
          const Text(
            'Payment Instructions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          _buildPaymentInstructions(ref, currentBillSplit),
          const SizedBox(height: 16.0),
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
    final participants = [billSplit.ownerId] + billSplit.participantsIds;
    final balances = calculateBalances(billSplit);
    return Column(
      children: participants.map((participantId) {
        return ListTile(
          title: Text(_getUserName(ref, participantId)),
          subtitle: Text('Balance: \$${balances[participantId]}'),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentInstructions(WidgetRef ref, BillSplit billSplit) {
    final balances = calculateBalances(billSplit);
    final transactions = settleDebts(balances);
    return Column(
      children: transactions.map((transaction) {
        return ListTile(
          title: Text(_getUserName(ref, transaction['from'])),
          subtitle: Text(
              'Pay \$${transaction['amount']} to ${_getUserName(ref, transaction['to'])}'),
        );
      }).toList(),
    );
  }

  String _getUserName(WidgetRef ref, String userId) {
    final user = ref.watch(userByIdProvider(userId)).maybeWhen(
          data: (user) => user?.name ?? 'Unknown',
          orElse: () => 'Unknown',
        );
    return user;
  }

  List<Map<String, dynamic>> settleDebts(Map<String, double> balances) {
    List<MapEntry<String, double>> balanceEntries = balances.entries.toList();
    balanceEntries.sort((a, b) => a.value.compareTo(b.value));

    List<Map<String, dynamic>> transactions = [];
    int i = 0;
    int j = balanceEntries.length - 1;

    while (i < j) {
      var debtor = balanceEntries[i];
      var creditor = balanceEntries[j];

      double payment = min((-debtor.value).abs(), creditor.value);

      transactions.add({
        'from': debtor.key,
        'to': creditor.key,
        'amount': payment,
      });

      balanceEntries[i] = MapEntry(debtor.key, debtor.value + payment);
      balanceEntries[j] = MapEntry(creditor.key, creditor.value - payment);

      if (balanceEntries[i].value == 0) i++;
      if (balanceEntries[j].value == 0) j--;
    }

    return transactions;
  }

  Map<String, double> calculateBalances(BillSplit billSplit) {
    final participants = [billSplit.ownerId] + billsplit.participantsIds;
    final balances = Map<String, double>.fromIterables(
        participants, List.filled(participants.length, 0.0));
    for (var participant in participants) {
      for (var bill in billSplit.bills) {
        if (bill.payerId == participant) {
          double amount = bill.amount / bill.splittersIds.length;
          balances[participant] = balances[participant]! + amount;
        } else if (bill.splittersIds.contains(participant)) {
          double amount = bill.amount / bill.splittersIds.length;
          balances[participant] = balances[participant]! - amount;
        }
      }
    }
    return balances;
  }
}
