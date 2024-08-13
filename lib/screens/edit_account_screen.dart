import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _image;
  Future<Uint8List?>? _imageBytesFuture;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _imageBytesFuture =
          ref.read(userProvider.notifier).downloadImage(user.id);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: FutureBuilder<Uint8List?>(
                  future: _imageBytesFuture,
                  builder: (context, snapshot) {
                    if (_image != null) {
                      return CircleAvatar(
                        backgroundImage: FileImage(_image!),
                        radius: 50,
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 50,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/default_avatar.png'),
                        radius: 50,
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return CircleAvatar(
                        backgroundImage: MemoryImage(snapshot.data!),
                        radius: 50,
                      );
                    } else {
                      return const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/default_avatar.png'),
                        radius: 50,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nickname';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = ref.read(userProvider);
                    if (user != null) {
                      if (_image != null) {
                        await ref
                            .read(userProvider.notifier)
                            .uploadImage(user.id, _image!.path);
                      }

                      final updatedUser = User(
                        id: user.id,
                        name: _nameController.text,
                        email: _emailController.text,
                        friends: user.friends,
                      );

                      await ref
                          .read(userProvider.notifier)
                          .updateUser(updatedUser);

                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
