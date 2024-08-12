import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/widgets/bill_form.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/providers/user_provider.dart';

class AddBillScreen extends ConsumerWidget {
  final String billsplitId;

  const AddBillScreen({super.key, required this.billsplitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bill'),
      ),
      body: BillForm(
        billsplitId: billsplitId,
        onSubmit: (newBill) {
          ref
              .read(billsplitProvider(user!.id).notifier)
              .addBillToBillSplit(billsplitId, newBill);
        },
        submitButtonText: 'Add Bill',
      ),
    );
  }
}
