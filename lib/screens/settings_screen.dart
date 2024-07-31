import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_provider.dart';
import '../providers/auth_provider.dart'; // Import the auth provider
import 'login_screen.dart'; // Import the login screen

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Theme', style: TextStyle(fontSize: 18)),
            ListTile(
              title: const Text('Light'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).state = value;
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Dark'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).state = value;
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('System Default'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).state = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Default Currency', style: TextStyle(fontSize: 18)),
            ListTile(
              title: const Text('USD'),
              leading: Radio<String>(
                value: 'USD',
                groupValue: currency,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).state = value;
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('EUR'),
              leading: Radio<String>(
                value: 'EUR',
                groupValue: currency,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).state = value;
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('PLN'),
              leading: Radio<String>(
                value: 'PLN',
                groupValue: currency,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).state = value;
                  }
                },
              ),
            ),
            const Spacer(), // Pushes the sign-out button to the bottom
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
