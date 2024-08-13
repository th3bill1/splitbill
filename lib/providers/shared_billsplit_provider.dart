import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/providers/user_provider.dart';
import '../models/billsplit.dart';

final sharedBillSplitsProvider =
    StreamProvider.family<List<BillSplit>, String>((ref, friendId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSharedBillSplits(friendId);
});
