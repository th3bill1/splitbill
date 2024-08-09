import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/models/user.dart';
import 'package:splitbill/providers/user_provider.dart';

class BillSplitDetailsScreen extends ConsumerStatefulWidget {
  final BillSplit billSplit;

  const BillSplitDetailsScreen({super.key, required this.billSplit});

  @override
  _BillSplitDetailsScreenState createState() => _BillSplitDetailsScreenState();
}

class _BillSplitDetailsScreenState
    extends ConsumerState<BillSplitDetailsScreen> {
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _currency = widget.billSplit.defaultCurrency;
  }

  void _updateCurrency(String? value) {
    if (value != null) {
      setState(() {
        _currency = value;
      });
      final updatedBillSplit =
          widget.billSplit.copyWith(defaultCurrency: _currency);
      ref
          .read(billsplitProvider(widget.billSplit.ownerId).notifier)
          .updateBillSplit(updatedBillSplit);
    }
  }

  void _addParticipant(User friend) {
    if (!widget.billSplit.participantsIds.contains(friend.id)) {
      final newParticipantsIds =
          List<String>.from(widget.billSplit.participantsIds)..add(friend.id);

      final updatedBillSplit =
          widget.billSplit.copyWith(participantsIds: newParticipantsIds);

      ref
          .read(billsplitProvider(widget.billSplit.ownerId).notifier)
          .updateBillSplit(updatedBillSplit);
      setState(() {
        widget.billSplit.participantsIds = newParticipantsIds;
      });
    }
  }

  void _deleteParticipant(String participantId) {
    final updatedBillSplit =
        widget.billSplit.copyWithoutParticipant(participantId);
    ref
        .read(billsplitProvider(widget.billSplit.ownerId).notifier)
        .updateBillSplit(updatedBillSplit);
    setState(() {
      widget.billSplit.participantsIds.remove(participantId);
    });
  }

  void _showAddParticipantDialog(BuildContext context) {
    final user = ref.watch(userProvider);
    final friends = user != null
        ? ref.watch(friendListProvider(user.id))
        : const AsyncValue<List<User>>.loading();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Participant'),
          content: friends.when(
            data: (friends) {
              return DropdownButtonFormField<User>(
                decoration: const InputDecoration(labelText: 'Select Friend'),
                items: friends.map((friend) {
                  return DropdownMenuItem<User>(
                    value: friend,
                    child: Text(friend.name),
                  );
                }).toList(),
                onChanged: (friend) {
                  if (friend != null) {
                    _addParticipant(friend);
                    Navigator.pop(context); // Close the dialog after adding
                  }
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const Text('Error loading friends'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final friends = user != null
        ? ref.watch(friendListProvider(user.id))
        : const AsyncValue<List<User>>.loading();
    final participantsIds = widget.billSplit.participantsIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BillSplit Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Default Currency', style: TextStyle(fontSize: 18)),
            ListTile(
              title: const Text('USD'),
              leading: Radio<String>(
                value: 'USD',
                groupValue: _currency,
                onChanged: _updateCurrency,
              ),
            ),
            ListTile(
              title: const Text('EUR'),
              leading: Radio<String>(
                value: 'EUR',
                groupValue: _currency,
                onChanged: _updateCurrency,
              ),
            ),
            ListTile(
              title: const Text('PLN'),
              leading: Radio<String>(
                value: 'PLN',
                groupValue: _currency,
                onChanged: _updateCurrency,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Participants', style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () {
                _showAddParticipantDialog(context);
              },
              child: const Text('Add Participant'),
            ),
            Expanded(
              child: participantsIds.isNotEmpty
                  ? friends.when(
                      data: (friends) => ListView.builder(
                        itemCount: participantsIds.length,
                        itemBuilder: (context, index) {
                          final participantId = participantsIds[index];
                          final participant = friends.firstWhere(
                              (friend) => friend.id == participantId);
                          return ListTile(
                            title: Text(participant.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteParticipant(participant.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Participant removed')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => const Center(
                          child: Text('Error loading participants')),
                    )
                  : const Center(child: Text('No participants added')),
            ),
          ],
        ),
      ),
    );
  }
}
