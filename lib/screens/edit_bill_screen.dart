import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/screens/billsplit_screen.dart';
import 'package:splitbill/widgets/bill_form.dart';
import 'package:splitbill/providers/bill_provider.dart';

class EditBillScreen extends ConsumerWidget {
  final BillSplit billsplit;
  final Bill bill;

  const EditBillScreen(
      {super.key, required this.billsplit, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              ref.read(billProvider.notifier).removeBill(bill, billsplit.id);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BillSplitScreen(billsplit: billsplit)));
            },
          ),
        ],
      ),
      body: BillForm(
        billsplitId: billsplit.id,
        bill: bill,
        onSubmit: (updatedBill) {
          ref.read(billProvider.notifier).updateBill(billsplit.id, updatedBill);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BillSplitScreen(billsplit: billsplit)));
        },
        submitButtonText: 'Save Bill',
      ),
    );
  }
}
