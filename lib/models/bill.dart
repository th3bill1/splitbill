import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  String name;
  double amount;
  String payerId;
  List<String> splittersIds;
  String currency;
  DateTime creationDate;
  DateTime lastUpdateDate;

  Bill({
    required this.name,
    required this.amount,
    required this.payerId,
    required this.splittersIds,
    required this.currency,
    required this.creationDate,
    required this.lastUpdateDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'payerId': payerId,
      'splittersIds': splittersIds,
      'currency': currency,
      'creationDate': creationDate,
      'lastUpdateDate': lastUpdateDate,
    };
  }

  static Bill fromMap(Map<String, dynamic> map) {
    return Bill(
      name: map['name'],
      amount: map['amount'],
      payerId: map['payerId'],
      splittersIds: List<String>.from(map['splittersIds']),
      currency: map['currency'],
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      lastUpdateDate: (map['lastUpdateDate'] as Timestamp).toDate(),
    );
  }
}
