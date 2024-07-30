import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';

class AddBillSplitScreen extends ConsumerStatefulWidget {
  const AddBillSplitScreen({super.key});

  @override
  _AddBillSplitScreenState createState() => _AddBillSplitScreenState();
}

class _AddBillSplitScreenState extends ConsumerState<AddBillSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Uuid uuid = const Uuid(); // Define the Uuid object

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
                      id: uuid.v4(), // Generate a unique ID for the bill split
                      name: _nameController.text,
                      bills: [],
                      userId: user.uid, // Assign the current user's UID
                    );
                    ref
                        .read(billsplitProvider(user.uid).notifier)
                        .addBillSplit(newBillSplit);
                    Navigator.pop(context);
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
