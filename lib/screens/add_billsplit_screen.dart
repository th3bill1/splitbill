import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/main.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import 'billsplit_details_screen.dart'; // Import the new screen

class AddBillSplitScreen extends ConsumerStatefulWidget {
  const AddBillSplitScreen({super.key});

  @override
  _AddBillSplitScreenState createState() => _AddBillSplitScreenState();
}

class _AddBillSplitScreenState extends ConsumerState<AddBillSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Uuid uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add BillSplit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'BillSplit Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newBillSplit = BillSplit(
                      id: uuid.v4(),
                      name: _nameController.text,
                      bills: [],
                      ownerId: user.uid,
                      defaultCurrency: ref.watch(currencyProvider),
                      participantsIds: List<String>.empty(),
                    );
                    ref
                        .read(billsplitProvider(user.uid).notifier)
                        .addBillSplit(newBillSplit);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BillSplitDetailsScreen(billSplit: newBillSplit),
                      ),
                    );
                  }
                },
                child: const Text('Add BillSplit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
