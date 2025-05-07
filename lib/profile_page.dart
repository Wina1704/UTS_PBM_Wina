import 'package:flutter/material.dart';
import 'storage_service.dart';

class ProfilePage extends StatefulWidget {
  final Function(bool) toggleTheme;
  const ProfilePage({required this.toggleTheme, Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Wina Windari Kusdarniza';
  String _nim = '123456789';
  String _email = 'winawindari@gmail.com';
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final lines = await StorageService.readLines('profile.txt');
    if (lines.length >= 3) {
      setState(() {
        _name = lines[0];
        _nim = lines[1];
        _email = lines[2];
      });
    }
  }

  Future<void> _saveProfile() async {
    await StorageService.writeLines('profile.txt', [_name, _nim, _email]);
  }

  void _editField(String label, String current, Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Edit $label'),
            content: TextField(controller: ctrl),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  onSave(ctrl.text);
                  _saveProfile();
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      // Wrap body in SingleChildScrollView to avoid overflow in landscape
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  _name.isNotEmpty ? _name[0] : '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Nama'),
              subtitle: Text(_name),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => _editField(
                      'Nama',
                      _name,
                      (v) => setState(() => _name = v),
                    ),
              ),
            ),
            ListTile(
              title: const Text('NIM'),
              subtitle: Text(_nim),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => _editField(
                      'NIM',
                      _nim,
                      (v) => setState(() => _nim = v),
                    ),
              ),
            ),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(_email),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => _editField(
                      'Email',
                      _email,
                      (v) => setState(() => _email = v),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDark,
              onChanged: (v) {
                setState(() => _isDark = v);
                widget.toggleTheme(v);
              },
            ),
            const SizedBox(height: 300), // extra space to prevent overflow
          ],
        ),
      ),
    );
  }
}
