import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';

class ServingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;
  const ServingDetailScreen({super.key, required this.reservation});

  @override
  State<ServingDetailScreen> createState() => _ServingDetailScreenState();
}

class _ServingDetailScreenState extends State<ServingDetailScreen> {
  Map<String, dynamic>? session;
  bool loading = true;

  final String baseUrl = "http://10.0.2.2:5000/api/serve-sessions";

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => loading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final res = await http.get(
        Uri.parse("$baseUrl/${widget.reservation['_id']}/detail"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("LOAD SESSION RESPONSE CODE: ${res.statusCode}");
      debugPrint("LOAD SESSION RESPONSE BODY: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => session = data['session']);

        if (session != null) {
          debugPrint("SESSION DATA LOADED: $session");
          debugPrint("SESSION ID: ${session!['_id']}");
          debugPrint("SESSION STATUS: ${session!['status']}");
          final items = session!['items'] ?? [];
          debugPrint("SESSION ITEMS COUNT: ${items.length}");

          final totalPrice = items.fold<num>(
            0,
                (sum, item) {
              final price = (item['price'] ?? 0) as num;
              final qty = (item['quantity'] ?? 0) as num;
              return sum + price * qty;
            },
          );
          debugPrint("SESSION TOTAL PRICE: $totalPrice");
        }
      }
    } catch (e) {
      debugPrint("LOAD SESSION ERROR: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _updateQuantity(String foodId, int quantity) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      await http.patch(
        Uri.parse("$baseUrl/${widget.reservation['_id']}/update-food"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'foodId': foodId,
          'quantity': quantity,
        }),
      );
      await _loadSession();
    } catch (e) {
      debugPrint("UPDATE ERROR: $e");
    }
  }

  Future<void> _deleteFood(String foodId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Food"),
        content: const Text("Remove this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final res = await http.delete(
        Uri.parse("$baseUrl/${widget.reservation['_id']}/remove-food"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'foodId': foodId}),
      );

      if (res.statusCode == 200) {
        await _loadSession();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delete failed")),
        );
      }
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
    }
  }

  Future<void> _checkout() async {
    if (session == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Checkout"),
        content: const Text("Confirm checkout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Checkout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      // gửi reservationId vì server route dùng :reservationId
      final reservationId = widget.reservation['_id'];

      debugPrint("CHECKOUT TOKEN: Bearer $token");
      debugPrint("CHECKOUT RESERVATION ID: $reservationId");

      final res = await http.post(
        Uri.parse("$baseUrl/$reservationId/checkout"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("CHECKOUT RESPONSE CODE: ${res.statusCode}");
      debugPrint("CHECKOUT RESPONSE BODY: ${res.body}");

      if (res.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Checkout failed: ${res.body}")),
        );
      }
    } catch (e) {
      debugPrint("CHECKOUT ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text("No session data")),
      );
    }

    final List items = session!['items'] ?? [];
    final total = items.fold<num>(0, (sum, item) {
      final price = (item['price'] ?? 0) as num;
      final qty = (item['quantity'] ?? 0) as num;
      return sum + price * qty;
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Serving Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("No food added"))
                  : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: item['food']?['image'] != null
                          ? Image.network(
                        "http://10.0.2.2:5000/uploads/${item['food']['image']}",
                        width: 50,
                        fit: BoxFit.cover,
                      )
                          : const SizedBox(width: 50),
                      title: Text(item['name'] ?? ''),
                      subtitle: Text(
                        "\$${item['price']} x ${item['quantity']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: item['quantity'] > 1
                                ? () {
                              setState(() {
                                item['quantity']--;
                              });
                              _updateQuantity(
                                item['food']['_id'],
                                item['quantity'],
                              );
                            }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                item['quantity']++;
                              });
                              _updateQuantity(
                                item['food']['_id'],
                                item['quantity'],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteFood(item['food']['_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Total: \$${total}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Checkout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
