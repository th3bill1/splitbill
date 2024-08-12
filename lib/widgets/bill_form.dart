import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/bill.dart';
import 'package:splitbill/models/user.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/providers/currency_provider.dart';
import 'package:splitbill/providers/user_provider.dart';

class BillForm extends ConsumerStatefulWidget {
  final String billsplitId;
  final Bill?
      bill; // If this is null, it's an Add form; otherwise, it's an Edit form.
  final void Function(Bill) onSubmit; // Callback for when the form is submitted
  final String submitButtonText;

  const BillForm({
    super.key,
    required this.billsplitId,
    this.bill,
    required this.onSubmit,
    required this.submitButtonText,
  });

  @override
  _BillFormState createState() => _BillFormState();
}

class _BillFormState extends ConsumerState<BillForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _currency;
  User? _selectedPayer;
  late Set<String> _selectedSplitters;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bill?.name ?? '');
    _amountController =
        TextEditingController(text: widget.bill?.amount.toString() ?? '');
    _currency = widget.bill?.currency ?? ref.read(currencyProvider);
    _selectedPayer = null;
    _selectedSplitters = widget.bill?.splittersIds.toSet() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final billSplit = ref
        .watch(billsplitProvider(user!.id))
        .firstWhere((split) => split.id == widget.billsplitId);

    final owner = ref.watch(userByIdProvider(billSplit.ownerId));
    final participants = billSplit.participantsIds.map((id) {
      return ref.watch(userByIdProvider(id));
    }).toList();

    return Form(
      key: _formKey,
      child: ListView(
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
          owner.when(
            data: (user) {
              return DropdownButtonFormField<User>(
                decoration: const InputDecoration(labelText: 'Who Paid'),
                value: _selectedPayer ??
                    (widget.bill != null && user!.id == widget.bill!.payerId
                        ? user
                        : null),
                items: [
                  if (user != null)
                    DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.name),
                    ),
                  ...participants.map((participant) {
                    return participant.when(
                      data: (user) => DropdownMenuItem<User>(
                        value: user,
                        child: Text(user!.name),
                      ),
                      loading: () => const DropdownMenuItem<User>(
                        child: Text('Loading...'),
                      ),
                      error: (error, stack) => const DropdownMenuItem<User>(
                        child: Text('Error loading user'),
                      ),
                    );
                  }),
                ],
                onChanged: (User? newValue) {
                  setState(() {
                    _selectedPayer = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select who paid';
                  }
                  return null;
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) =>
                const Text('Error loading owner information'),
          ),
          const SizedBox(height: 20),
          const Text('Who Splits the Bill', style: TextStyle(fontSize: 18)),
          CheckboxListTile(
            title: Text(user.name),
            value: _selectedSplitters.contains(user.id),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  _selectedSplitters.add(user.id);
                } else {
                  _selectedSplitters.remove(user.id);
                }
              });
            },
          ),
          ...participants.map((participant) {
            return participant.when(
              data: (user) => CheckboxListTile(
                title: Text(user!.name),
                value: _selectedSplitters.contains(user.id),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedSplitters.add(user.id);
                    } else {
                      _selectedSplitters.remove(user.id);
                    }
                  });
                },
              ),
              loading: () => const ListTile(
                title: Text('Loading...'),
              ),
              error: (error, stack) => const ListTile(
                title: Text('Error loading participant'),
              ),
            );
          }),
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
                final bill = Bill(
                  name: _nameController.text,
                  amount: double.parse(_amountController.text),
                  payerId: _selectedPayer!.id,
                  splittersIds: _selectedSplitters.toList(),
                  currency: _currency,
                );
                widget.onSubmit(bill);
                Navigator.pop(context);
              }
            },
            child: Text(widget.submitButtonText),
          ),
        ],
      ),
    );
  }
}
