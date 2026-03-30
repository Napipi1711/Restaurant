import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List discounts = [];
  bool loading = true;
  String? token;

  final String baseUrl = 'http://10.0.2.2:5000/api/discounts';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    print(' [DEBUG] Loaded token: $token');
    await fetchDiscounts();
  }

  Future<void> fetchDiscounts() async {
    setState(() => loading = true);
    print(' [DEBUG] fetchDiscounts called');

    if (token == null) {
      print(' [ERROR] No token found');
      setState(() => loading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(' [DEBUG] fetchDiscounts response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          discounts = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load discounts: ${response.body}')),
        );
      }
    } catch (e) {
      print(' [ERROR] fetchDiscounts: $e');
      setState(() => loading = false);
    }
  }

  void _deleteDiscount(String? id) async {
    if (token == null || id == null || id.isEmpty) return;
    print(' [DEBUG] deleteDiscount called with id: $id');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(' [DEBUG] deleteDiscount response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchDiscounts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete failed')),
        );
      }
    } catch (e) {
      print(' [ERROR] deleteDiscount: $e');
    }
  }

  void _showAddEditDialog({Map? discount}) {
    if (token == null) return;

    final codeController = TextEditingController(text: discount?['code'] ?? '');
    final descController = TextEditingController(text: discount?['description'] ?? '');
    final valueController = TextEditingController(text: discount?['value']?.toString() ?? '');
    final minOrderController = TextEditingController(text: discount?['minOrderAmount']?.toString() ?? '');
    final usageLimitController = TextEditingController(text: discount?['usageLimit']?.toString() ?? '');
    String type = discount?['discountType'] ?? 'percentage';
    DateTime? expireAt = discount?['expireAt'] != null ? DateTime.tryParse(discount!['expireAt']) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(discount == null ? 'Add Discount' : 'Edit Discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Code')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minOrderController,
                  decoration: const InputDecoration(labelText: 'Min Order Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: usageLimitController,
                  decoration: const InputDecoration(labelText: 'Usage Limit'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Discount Type'),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                  ],
                  onChanged: (v) {
                    if (v != null) setStateDialog(() => type = v);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Expire At: '),
                    Text(expireAt?.toLocal().toString().split(' ')[0] ?? 'None'),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: expireAt ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setStateDialog(() => expireAt = picked);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                final desc = descController.text.trim();
                final value = double.tryParse(valueController.text.trim()) ?? 0;
                final minOrder = double.tryParse(minOrderController.text.trim()) ?? 0;
                final usageLimit = int.tryParse(usageLimitController.text.trim()) ?? 1;

                if (code.isEmpty || desc.isEmpty || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                try {
                  if (discount == null) {

                    print(' [DEBUG] Adding discount: $code');
                    final res = await http.post(
                      Uri.parse(baseUrl),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: json.encode({
                        'code': code,
                        'description': desc,
                        'value': value,
                        'discountType': type,
                        'minOrderAmount': minOrder,
                        'usageLimit': usageLimit,
                        'expireAt': expireAt?.toIso8601String(),
                      }),
                    );
                    print('[DEBUG] Add response: ${res.statusCode} - ${res.body}');
                  } else {

                    print(' [DEBUG] Editing discount: ${discount?['_id']}');
                    final res = await http.put(
                      Uri.parse('$baseUrl/${discount?['_id']}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: json.encode({
                        'code': code,
                        'description': desc,
                        'value': value,
                        'discountType': type,
                        'minOrderAmount': minOrder,
                        'usageLimit': usageLimit,
                        'expireAt': expireAt?.toIso8601String(),
                      }),
                    );
                    print(' [DEBUG] Edit response: ${res.statusCode} - ${res.body}');
                  }
                  Navigator.pop(context);
                  fetchDiscounts();
                } catch (e) {
                  print(' [ERROR] Add/Edit discount: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discount Management'), backgroundColor: Colors.orange),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchDiscounts,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: discounts.length,
          itemBuilder: (context, index) {
            final discount = discounts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(discount?['code'] ?? ''),
                subtitle: Text(
                  '${discount?['description'] ?? ''} - ${discount?['value'] ?? 0} ${discount?['discountType'] ?? ''}\n'
                      'MinOrder: ${discount?['minOrderAmount'] ?? 0}, UsageLimit: ${discount?['usageLimit'] ?? 1}, Used: ${discount?['usedCount'] ?? 0}\n'
                      'Active: ${discount?['active'] ?? false}, ExpireAt: ${discount?['expireAt'] ?? 'None'}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddEditDialog(discount: discount),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDiscount(discount?['_id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
