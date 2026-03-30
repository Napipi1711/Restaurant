import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'table_create.dart';
import 'table_detail.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List tables = [];
  final String baseUrl = "http://10.0.2.2:5000/api/tables";

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/list"));
      final data = jsonDecode(res.body);
      if (data['success']) setState(() => tables = data['data']);
    } catch (e) {
      print("Error fetching tables: $e");
    }
  }

  Future<void> addTable(Map<String, dynamic> tableData) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(tableData));
      final data = jsonDecode(res.body);
      if (data['success']) fetchTables();
    } catch (e) {}
  }

  Future<void> updateTableStatus(String id, String status) async {
    try {
      final res = await http.put(Uri.parse("$baseUrl/update/$id"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"status": status}));
      final data = jsonDecode(res.body);
      if (data['success']) fetchTables();
    } catch (e) {}
  }

  Future<void> deleteTable(String id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/remove/$id"));
      final data = jsonDecode(res.body);
      if (data['success']) fetchTables();
    } catch (e) {}
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "available":
        return Colors.green[300]!;
      case "unavailable":
        return Colors.grey[400]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => TableDetailDialog(
                table: table,
                onUpdateStatus: updateTableStatus,
                onDelete: deleteTable,
              ),
            ),
            child: Card(
              color: getStatusColor(table['status']),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  "Table ${table['tableNumber']}",
                  style: const TextStyle(
                      fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => TableCreateDialog(onAdd: addTable),
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
        tooltip: "Add Table",
      ),
    );
  }
}
