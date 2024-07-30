class Bill {
  String name;
  double amount;
  List<Person> people;
  String currency;

  Bill(
      {required this.name,
      required this.amount,
      required this.people,
      required this.currency});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'people': people.map((person) => person.toMap()).toList(),
      'currency': currency,
    };
  }

  static Bill fromMap(Map<String, dynamic> map) {
    return Bill(
      name: map['name'],
      amount: map['amount'],
      people:
          List<Person>.from(map['people'].map((item) => Person.fromMap(item))),
      currency: map['currency'],
    );
  }
}

class Person {
  String name;
  double amountPaid;

  Person({required this.name, required this.amountPaid});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amountPaid': amountPaid,
    };
  }

  static Person fromMap(Map<String, dynamic> map) {
    return Person(
      name: map['name'],
      amountPaid: map['amountPaid'],
    );
  }
}
