import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/models/billsplit.dart';
import 'package:splitbill/providers/billsplit_provider.dart';
import 'package:splitbill/models/user.dart';
import 'package:splitbill/providers/user_provider.dart';
import 'package:splitbill/screens/billsplit_screen.dart';

class BillSplitDetailScreen extends ConsumerStatefulWidget {
  final BillSplit billSplit;

  const BillSplitDetailScreen({super.key, required this.billSplit});

  @override
  _BillSplitDetailScreenState createState() => _BillSplitDetailScreenState();
}

class _BillSplitDetailScreenState extends ConsumerState<BillSplitDetailScreen> {
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

  void _addParticipant({User? friend, String? participantName}) {
    if (friend != null &&
        !widget.billSplit.participantsIds.contains(friend.id)) {
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
    } else if (participantName != null) {
      final newParticipantNames =
          List<String>.from(widget.billSplit.participantNames)
            ..add(participantName);
      final updatedBillSplit =
          widget.billSplit.copyWith(participantNames: newParticipantNames);
      ref
          .read(billsplitProvider(widget.billSplit.ownerId).notifier)
          .updateBillSplit(updatedBillSplit);
      setState(() {
        widget.billSplit.participantNames = newParticipantNames;
      });
    }
  }

  void _deleteParticipant(String identifier) {
    if (widget.billSplit.participantsIds.contains(identifier)) {
      final updatedBillSplit =
          widget.billSplit.copyWithoutParticipant(identifier);
      ref
          .read(billsplitProvider(widget.billSplit.ownerId).notifier)
          .updateBillSplit(updatedBillSplit);
      setState(() {
        widget.billSplit.participantsIds.remove(identifier);
      });
    } else if (widget.billSplit.participantNames.contains(identifier)) {
      final newParticipantNames =
          List<String>.from(widget.billSplit.participantNames)
            ..remove(identifier);
      final updatedBillSplit =
          widget.billSplit.copyWith(participantNames: newParticipantNames);
      ref
          .read(billsplitProvider(widget.billSplit.ownerId).notifier)
          .updateBillSplit(updatedBillSplit);
      setState(() {
        widget.billSplit.participantNames.remove(identifier);
      });
    }
  }

  void _showAddParticipantDialog(BuildContext context) {
    final user = ref.watch(userProvider);
    final friends = user != null
        ? ref.watch(friendListProvider(user.id))
        : const AsyncValue<List<User>>.loading();

    showDialog(
      context: context,
      builder: (context) {
        String? participantName;

        return AlertDialog(
          title: const Text('Add Participant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<User?>(
                decoration: const InputDecoration(labelText: 'Select Friend'),
                value: friends.when(
                    data: (friends) {
                      return friends.first;
                    },
                    error: (error, stack) => null,
                    loading: () => null),
                items: [
                  ...friends.when(
                    data: (friends) {
                      return friends.map((friend) {
                        return DropdownMenuItem<User>(
                          value: friend,
                          child: Text(friend.name),
                        );
                      }).toList();
                    },
                    loading: () => [
                      const DropdownMenuItem<User>(
                        child: Text('Loading...'),
                      )
                    ],
                    error: (error, stack) => [
                      const DropdownMenuItem<User>(
                        child: Text('Error loading friends'),
                      )
                    ],
                  ),
                  const DropdownMenuItem<Null>(
                    value: null,
                    child: Text('Add friend without account'),
                  ),
                ],
                onChanged: (friend) {
                  if (friend != null) {
                    _addParticipant(friend: friend);
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Enter participant name'),
                          content: TextField(
                            onChanged: (value) {
                              participantName = value;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (participantName != null &&
                                    participantName!.isNotEmpty) {
                                  _addParticipant(
                                      participantName: participantName);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
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
              child: ListView.builder(
                itemCount: widget.billSplit.participantsIds.length +
                    widget.billSplit.participantNames.length,
                itemBuilder: (context, index) {
                  if (index < widget.billSplit.participantsIds.length) {
                    final participantId =
                        widget.billSplit.participantsIds[index];
                    final participant = friends.when(
                      data: (friends) => friends
                          .firstWhere((friend) => friend.id == participantId),
                      loading: () => null,
                      error: (error, stack) => null,
                    );

                    if (participant != null) {
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
                    } else {
                      return const ListTile(
                        title: Text('Participant not found'),
                      );
                    }
                  } else {
                    final nameIndex =
                        index - widget.billSplit.participantsIds.length;
                    final participantName =
                        widget.billSplit.participantNames[nameIndex];
                    return ListTile(
                      title: Text(participantName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteParticipant(participantName);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Participant removed')),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  var id = user?.id;
                  if (id != null) {
                    ref
                        .read(billsplitProvider(id).notifier)
                        .updateBillSplit(widget.billSplit);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillSplitScreen(
                        billsplit: widget.billSplit,
                      ),
                    ),
                  );
                },
                child: const Text('Go to BillSplit Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
