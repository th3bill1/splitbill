import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitbill/models/user.dart';
import 'package:splitbill/models/billsplit.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final query =
        await _db.collection('users').where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return User.fromMap(query.docs.first.data());
    }
    return null;
  }

  Future<void> addUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(User user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> addFriend(String userId, String friendId) async {
    final userDoc = _db.collection('users').doc(userId);
    final friendDoc = _db.collection('users').doc(friendId);

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDoc);
      final friendSnapshot = await transaction.get(friendDoc);

      if (!userSnapshot.exists || !friendSnapshot.exists) {
        throw Exception("User or Friend does not exist!");
      }

      final user = User.fromMap(userSnapshot.data()!);
      final friend = User.fromMap(friendSnapshot.data()!);

      if (!user.friends.contains(friendId)) {
        user.friends.add(friendId);
        transaction.update(userDoc, {'friends': user.friends});
      }

      if (!friend.friends.contains(userId)) {
        friend.friends.add(userId);
        transaction.update(friendDoc, {'friends': friend.friends});
      }
    });
  }

  Stream<List<User>> getFriends(String userId) {
    return _db
        .collection('users')
        .where('friends', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    });
  }

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
