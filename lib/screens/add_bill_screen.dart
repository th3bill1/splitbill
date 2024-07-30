import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/providers/currency_provider.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  final String billsplitId;

  const AddBillScreen({super.key, required this.billsplitId});

  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final List<Person> _people = [];
  late String _currency;

  @override
  void initState() {
    super.initState();
    _currency =
        ref.read(currencyProvider); // Set default currency from settings
  }

  void _addPerson() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Participant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount Paid'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _people.add(
                    Person(
                      name: nameController.text,
                      amountPaid: double.parse(amountController.text),
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Bill Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Participants', style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: _addPerson,
                child: const Text('Add Participant'),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _people.length,
                itemBuilder: (context, index) {
                  final person = _people[index];
                  return ListTile(
                    title: Text(person.name),
                    subtitle: Text('Amount Paid: ${person.amountPaid}'),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Currency', style: TextStyle(fontSize: 18)),
              ListTile(
                title: const Text('USD'),
                leading: Radio<String>(
                  value: 'USD',
                  groupValue: _currency,
                  onChanged: (String? value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('EUR'),
                leading: Radio<String>(
                  value: 'EUR',
                  groupValue: _currency,
                  onChanged: (String? value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('PLN'),
                leading: Radio<String>(
                  value: 'PLN',
                  groupValue: _currency,
                  onChanged: (String? value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newBill = Bill(
                      name: _nameController.text,
                      amount: double.parse(_amountController.text),
                      people: _people,
                      currency: _currency,
                    );
                    ref
                        .read(billsplitProvider(widget.billsplitId).notifier)
                        .addBillToBillSplit(widget.billsplitId, newBill);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
