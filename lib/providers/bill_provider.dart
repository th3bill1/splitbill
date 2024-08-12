import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';
import 'package:splitbill/providers/user_provider.dart';
import 'package:splitbill/services/firestore_service.dart';

class BillNotifier extends StateNotifier<List<Bill>> {
  final FirestoreService firestoreService;

  BillNotifier(this.firestoreService) : super([]);

  void addBill(Bill bill, String billsplitId) async {
    state = [...state, bill];
    await firestoreService.addBillToBillSplit(billsplitId, bill);
  }

  void removeBill(Bill bill, String billsplitId) async {
    state = state.where((b) => b != bill).toList();
    await firestoreService.removeBillFromBillSplit(billsplitId, bill);
  }

  void updateBill(String billsplitId, updatedBill) async {
    await firestoreService.updateBillInBillSplit(billsplitId, updatedBill);
  }
}

final billProvider = StateNotifierProvider<BillNotifier, List<Bill>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return BillNotifier(firestoreService);
});
