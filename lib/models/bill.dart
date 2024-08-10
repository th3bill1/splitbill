class Bill {
  String name;
  double amount;
  String payerId;
  List<String> splittersIds;
  String currency;

  Bill({
    required this.name,
    required this.amount,
    required this.payerId,
    required this.splittersIds,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'payerId': payerId,
      'splittersIds': splittersIds,
      'currency': currency,
    };
  }

  static Bill fromMap(Map<String, dynamic> map) {
    return Bill(
      name: map['name'],
      amount: map['amount'],
      payerId: map['payerId'],
      splittersIds: List<String>.from(map['splittersIds']),
      currency: map['currency'],
    );
  }
}
