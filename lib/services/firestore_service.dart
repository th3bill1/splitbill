import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitbill/models/user.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/models/friend_invitation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:splitbill/models/bill.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> getUser(String userId) async {
    final querySnapshot =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return User.fromMap(doc.data());
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

  Future<User?> getUserByNickname(String nickname) async {
    final query =
        await _db.collection('users').where('name', isEqualTo: nickname).get();
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

  Future<void> removeFriend(String userId, String friendId) async {
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

      if (user.friends.contains(friendId)) {
        user.friends.remove(friendId);
        transaction.update(userDoc, {'friends': user.friends});
      }

      if (friend.friends.contains(userId)) {
        friend.friends.remove(userId);
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
    final ownerQuery = _db
        .collection('billsplits')
        .where('ownerId', isEqualTo: userId)
        .snapshots();
    final participantQuery = _db
        .collection('billsplits')
        .where('participantsIds', arrayContains: userId)
        .snapshots();
    return CombineLatestStream.list([ownerQuery, participantQuery])
        .map((snapshotList) {
      final ownerBillSplits = snapshotList[0]
          .docs
          .map((doc) => BillSplit.fromMap(doc.data()))
          .toList();
      final participantBillSplits = snapshotList[1]
          .docs
          .map((doc) => BillSplit.fromMap(doc.data()))
          .toList();
      final allBillSplits = {
        ...ownerBillSplits,
        ...participantBillSplits,
      }.toList();
      return allBillSplits;
    });
  }

  Future<void> sendFriendInvitation(String fromUserId, String toUserId) async {
    final invitation = FriendInvitation(
      id: _db.collection('friend_invitations').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
    );
    await _db
        .collection('friend_invitations')
        .doc(invitation.id)
        .set(invitation.toMap());
  }

  Future<void> acceptFriendInvitation(String invitationId) async {
    final doc =
        await _db.collection('friend_invitations').doc(invitationId).get();
    if (doc.exists) {
      final invitation = FriendInvitation.fromMap(doc.data()!);
      await addFriend(invitation.fromUserId, invitation.toUserId);
      await _db.collection('friend_invitations').doc(invitationId).delete();
    }
  }

  Stream<List<FriendInvitation>> getFriendInvitations(String userId) {
    return _db
        .collection('friend_invitations')
        .where('toUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendInvitation.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> addBillToBillSplit(String billsplitId, Bill bill) async {
    final billSplitDoc = _db.collection('billsplits').doc(billsplitId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(billSplitDoc);
      if (snapshot.exists) {
        final billSplit = BillSplit.fromMap(snapshot.data()!);
        billSplit.bills.add(bill);
        transaction.update(billSplitDoc,
            {'bills': billSplit.bills.map((b) => b.toMap()).toList()});
      } else {
        throw Exception("BillSplit not found");
      }
    });
  }

  Future<void> removeBillFromBillSplit(String billsplitId, Bill bill) async {
    final billSplitDoc = _db.collection('billsplits').doc(billsplitId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(billSplitDoc);
      if (snapshot.exists) {
        final billSplit = BillSplit.fromMap(snapshot.data()!);
        billSplit.bills
            .removeWhere((b) => b.name == bill.name && b.amount == bill.amount);
        transaction.update(billSplitDoc,
            {'bills': billSplit.bills.map((b) => b.toMap()).toList()});
      } else {
        throw Exception("BillSplit not found");
      }
    });
  }

  Future<void> updateBillInBillSplit(
      String billsplitId, Bill updatedBill) async {
    final billSplitDoc = _db.collection('billsplits').doc(billsplitId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(billSplitDoc);
      if (snapshot.exists) {
        final billSplit = BillSplit.fromMap(snapshot.data()!);
        final index = billSplit.bills.indexWhere((b) =>
            b.name == updatedBill.name && b.amount == updatedBill.amount);
        if (index != -1) {
          billSplit.bills[index] = updatedBill;
          transaction.update(billSplitDoc,
              {'bills': billSplit.bills.map((b) => b.toMap()).toList()});
        } else {
          throw Exception("Bill not found in BillSplit");
        }
      } else {
        throw Exception("BillSplit not found");
      }
    });
  }

  Stream<List<BillSplit>> getSharedBillSplits(String userId) {
    final ownerQuery = _db
        .collection('billsplits')
        .where('ownerId', isEqualTo: userId)
        .snapshots();
    final participantQuery = _db
        .collection('billsplits')
        .where('participantsIds', arrayContains: userId)
        .snapshots();
    return CombineLatestStream.list([ownerQuery, participantQuery])
        .map((snapshotList) {
      final ownerBillSplits = snapshotList[0]
          .docs
          .map((doc) => BillSplit.fromMap(doc.data()))
          .toList();
      final participantBillSplits = snapshotList[1]
          .docs
          .map((doc) => BillSplit.fromMap(doc.data()))
          .toList();
      return [...ownerBillSplits, ...participantBillSplits];
    });
  }
}
