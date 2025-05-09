import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill/screens/billsplit_list_screen.dart';
import 'package:splitbill/screens/friend_list_screen.dart';
import 'package:splitbill/screens/settings_screen.dart';
import 'package:splitbill/screens/account_screen.dart';
import 'package:splitbill/screens/login_screen.dart';
import '../providers/auth_provider.dart';
import 'package:splitbill/screens/notifications_screen.dart';
import '../models/friend_invitation.dart';
import '../providers/user_provider.dart';
import 'package:splitbill/widgets/badge.dart' as custom_badge;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const BillSplitListScreen(),
    const FriendListScreen(),
    const AccountScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final invitations = user != null
        ? ref.watch(friendInvitationsProvider(user.uid))
        : const AsyncValue<List<FriendInvitation>>.loading();

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Splitter'),
        actions: [
          invitations.when(
            data: (invitations) => IconButton(
              icon: invitations.isNotEmpty ? custom_badge.Badge(
                value: invitations.length.toString(),
                child: const Icon(Icons.notifications),
              ) : Container(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            loading: () => IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            error: (error, stack) => IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
    );
  }
}
