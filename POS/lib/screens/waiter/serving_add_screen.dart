import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';

class ServingAddScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;
  const ServingAddScreen({super.key, required this.reservation});

  @override
  State<ServingAddScreen> createState() => _ServingAddScreenState();
}

class _ServingAddScreenState extends State<ServingAddScreen> {
  List<dynamic> _foods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print("No token found!");
        return;
      }

      final url = Uri.parse('http://10.0.2.2:5000/api/foods/list');
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      print("🔹 Status code: ${res.statusCode}");
      print("🔹 Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _foods = data['data'] ?? []);
      } else {
        print("Failed to fetch foods");
      }
    } catch (e) {
      print("Error fetching foods: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addFood(String foodId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final url = Uri.parse(
          'http://10.0.2.2:5000/api/serve-sessions/${widget.reservation['_id']}/add-food');

      final res = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'foodId': foodId, 'quantity': 1}));

      print("Add Food Response: ${res.statusCode} | ${res.body}");

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Food added!")));
      } else {
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed')));
      }
    } catch (e) {
      print("Error adding food: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Food")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _foods.isEmpty
          ? const Center(child: Text("No foods available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _foods.length,
        itemBuilder: (context, index) {
          final food = _foods[index];
          final imageUrl = food['image'] != null
              ? 'http://10.0.2.2:5000/uploads/${food['image']}'
              : null;

          return Card(
            child: ListTile(
              leading: imageUrl != null
                  ? Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.fastfood),
              )
                  : const Icon(Icons.fastfood),
              title: Text(food['name'] ?? 'Unknown'),
              subtitle: Text("\$${food['price'] ?? 0}"),
              trailing: ElevatedButton(
                onPressed: () => _addFood(food['_id']),
                child: const Text("Add"),
              ),
            ),
          );
        },
      ),
    );
  }
}
