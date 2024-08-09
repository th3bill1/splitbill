import 'bill.dart';

class BillSplit {
  String id;
  String name;
  List<Bill> bills;
  String ownerId;
  String defaultCurrency;
  List<String> participantsIds;

  BillSplit({
    required this.id,
    required this.name,
    required this.bills,
    required this.ownerId,
    required this.defaultCurrency,
    required this.participantsIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bills': bills.map((bill) => bill.toMap()).toList(),
      'ownerId': ownerId,
      'participantsIds': participantsIds.toList(),
    };
  }

  static BillSplit fromMap(Map<String, dynamic> map) {
    return BillSplit(
      id: map['id'],
      name: map['name'],
      bills: List<Bill>.from(map['bills'].map((item) => Bill.fromMap(item))),
      ownerId: map['ownerId'],
      defaultCurrency: map['defaultCurrency'],
      participantsIds: List<String>.from(map['participantsIds']),
    );
  }

  BillSplit copyWith(
      {String? id,
      String? name,
      List<Bill>? bills,
      String? ownerId,
      String? defaultCurrency,
      List<String>? participantsIds}) {
    return BillSplit(
      id: id ?? this.id,
      name: name ?? this.name,
      bills: bills ?? this.bills,
      ownerId: ownerId ?? this.ownerId,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      participantsIds: participantsIds ?? this.participantsIds,
    );
  }

  BillSplit copyWithoutParticipant(String participantIdToRemove) {
    return BillSplit(
      id: id,
      name: name,
      bills: bills,
      ownerId: ownerId,
      defaultCurrency: defaultCurrency,
      participantsIds: participantsIds
          .where((participantId) => participantId != participantIdToRemove)
          .toList(),
    );
  }
}
