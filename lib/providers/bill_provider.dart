import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';

class BillNotifier extends StateNotifier<List<Bill>> {
  BillNotifier() : super([]);

  void addBill(Bill bill) {
    state = [...state, bill];
  }
}

final billProvider = StateNotifierProvider<BillNotifier, List<Bill>>((ref) {
  return BillNotifier();
});
