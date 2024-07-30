import 'bill.dart';

class BillSplit {
  String id;
  String name;
  List<Bill> bills;
  String userId;

  BillSplit(
      {required this.id,
      required this.name,
      required this.bills,
      required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bills': bills.map((bill) => bill.toMap()).toList(),
      'userId': userId,
    };
  }

  static BillSplit fromMap(Map<String, dynamic> map) {
    return BillSplit(
      id: map['id'],
      name: map['name'],
      bills: List<Bill>.from(map['bills'].map((item) => Bill.fromMap(item))),
      userId: map['userId'],
    );
  }
}
