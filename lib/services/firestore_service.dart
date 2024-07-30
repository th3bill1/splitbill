import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/billsplit.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addBillSplit(BillSplit billsplit) async {
    await _db.collection('billsplits').doc(billsplit.id).set(billsplit.toMap());
  }

  Future<void> updateBillSplit(BillSplit billsplit) async {
    await _db
        .collection('billsplits')
        .doc(billsplit.id)
        .update(billsplit.toMap());
  }

  Future<void> deleteBillSplit(String id) async {
    await _db.collection('billsplits').doc(id).delete();
  }

  Stream<List<BillSplit>> getBillSplits(String userId) {
    return _db
        .collection('billsplits')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BillSplit.fromMap(doc.data());
      }).toList();
    });
  }
}
