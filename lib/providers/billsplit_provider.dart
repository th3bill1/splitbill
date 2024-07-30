import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/billsplit.dart';
import '../models/bill.dart';
import '../services/firestore_service.dart';

class BillSplitNotifier extends StateNotifier<List<BillSplit>> {
  final FirestoreService _firestoreService = FirestoreService();
  final String userId;

  BillSplitNotifier(this.userId) : super([]) {
    _firestoreService.getBillSplits(userId).listen((billSplits) {
      state = billSplits;
    });
  }

  Future<void> addBillSplit(BillSplit billsplit) async {
    await _firestoreService.addBillSplit(billsplit);
  }

  Future<void> updateBillSplit(BillSplit billsplit) async {
    await _firestoreService.updateBillSplit(billsplit);
  }

  Future<void> deleteBillSplit(String id) async {
    await _firestoreService.deleteBillSplit(id);
  }

  Future<void> addBillToBillSplit(String billsplitId, Bill bill) async {
    final billSplit = state.firstWhere((bs) => bs.id == billsplitId);
    final updatedBills = List<Bill>.from(billSplit.bills)..add(bill);
    final updatedBillSplit = BillSplit(
      id: billSplit.id,
      name: billSplit.name,
      bills: updatedBills,
      userId: billSplit.userId,
    );

    await updateBillSplit(updatedBillSplit);
  }
}

final billsplitProvider =
    StateNotifierProvider.family<BillSplitNotifier, List<BillSplit>, String>(
        (ref, userId) {
  return BillSplitNotifier(userId);
});
