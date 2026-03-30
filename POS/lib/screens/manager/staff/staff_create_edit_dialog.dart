import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StaffCreateEditDialog extends StatefulWidget {
  final Map<String, dynamic>? staff;
  final VoidCallback onSaved;
  const StaffCreateEditDialog({super.key, this.staff, required this.onSaved});

  @override
  State<StaffCreateEditDialog> createState() => _StaffCreateEditDialogState();
}

class _StaffCreateEditDialogState extends State<StaffCreateEditDialog> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      usernameCtrl.text = widget.staff!['username'] ?? '';
      emailCtrl.text = widget.staff!['email'] ?? '';
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? '';
  }

  Future<void> saveStaff() async {
    final token = await getToken();
    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    try {
      if (widget.staff == null) {
        await http.post(
          Uri.parse('http://10.0.2.2:5000/api/staff/register'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            'role': 'waiter',
          }),
        );
      } else {
        await http.put(
          Uri.parse('http://10.0.2.2:5000/api/staff/${widget.staff!['_id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'username': username,
            'email': email,
          }),
        );
      }
    } catch (e) {
      debugPrint("❌ SAVE STAFF ERROR: $e");
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.staff == null ? 'Add Waiter' : 'Edit Waiter'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            if (widget.staff == null)
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: saveStaff, child: const Text('Save')),
      ],
    );
  }
}
