import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'staff_create_edit_dialog.dart';
import 'staff_confirm_dialog.dart';

class CheckOnStaffScreen extends StatefulWidget {
  const CheckOnStaffScreen({super.key});

  @override
  State<CheckOnStaffScreen> createState() => _CheckOnStaffScreenState();
}

class _CheckOnStaffScreenState extends State<CheckOnStaffScreen> {
  final String baseUrl = "http://10.0.2.2:5000/api/staff";
  List<dynamic> waiters = [];
  List<dynamic> filteredWaiters = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchWaiters();
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? '';
  }

  Future<void> fetchWaiters() async {
    setState(() => loading = true);
    try {
      final token = await getToken();
      final res = await http.get(Uri.parse(baseUrl), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        waiters = data.where((u) => (u['role']?.toString().toLowerCase() ?? '') == 'waiter').toList();
        applySearchFilter();
      }
    } catch (e) {
      debugPrint("❌ FETCH ERROR: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void applySearchFilter() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredWaiters = [...waiters];
      } else {
        filteredWaiters = waiters.where((w) {
          final username = w['username']?.toString().toLowerCase() ?? '';
          final email = w['email']?.toString().toLowerCase() ?? '';
          return username.contains(searchQuery.toLowerCase()) || email.contains(searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> toggleActive(Map<String, dynamic> waiter) async {
    final token = await getToken();
    try {
      await http.put(Uri.parse('$baseUrl/${waiter['_id']}'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: jsonEncode({'active': !(waiter['active'] ?? true)}));
      fetchWaiters();
    } catch (e) {
      debugPrint("❌ TOGGLE ACTIVE ERROR: $e");
    }
  }

  Future<void> deleteWaiter(String id) async {
    final token = await getToken();
    try {
      await http.delete(Uri.parse('$baseUrl/$id'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
    } catch (e) {
      debugPrint("❌ DELETE WAITER ERROR: $e");
    }
    fetchWaiters();
  }

  Widget buildWaiterCard(Map<String, dynamic> waiter) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade300,
          child: Text((waiter['username']?[0] ?? '?').toUpperCase(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(waiter['username'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(waiter['email'] ?? ''),
            const SizedBox(height: 2),
            Text(
              'Status: ${waiter['active'] == true ? 'Active' : 'Inactive'}',
              style: TextStyle(color: waiter['active'] == true ? Colors.green : Colors.red),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: Icon(waiter['active'] == true ? Icons.toggle_on : Icons.toggle_off,
                  color: waiter['active'] == true ? Colors.green : Colors.grey, size: 30),
              onPressed: () => toggleActive(waiter),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => StaffCreateEditDialog(staff: waiter, onSaved: fetchWaiters),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ConfirmDialog(
                  title: 'Delete Waiter',
                  content: 'Are you sure you want to delete this waiter?',
                  onConfirm: () => deleteWaiter(waiter['_id']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => StaffCreateEditDialog(onSaved: fetchWaiters),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Waiter'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Search waiters',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              searchQuery = val;
              applySearchFilter();
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredWaiters.isEmpty
                ? const Center(child: Text('No waiters found'))
                : ListView.builder(
              itemCount: filteredWaiters.length,
              itemBuilder: (_, index) => buildWaiterCard(filteredWaiters[index]),
            ),
          ),
        ],
      ),
    );
  }
}
