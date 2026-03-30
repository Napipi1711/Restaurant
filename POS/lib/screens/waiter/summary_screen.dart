import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class WaiterSummaryScreen extends StatefulWidget {
  const WaiterSummaryScreen({super.key});

  @override
  State<WaiterSummaryScreen> createState() => _WaiterSummaryScreenState();
}

class _WaiterSummaryScreenState extends State<WaiterSummaryScreen> {
  bool loading = true;
  List<dynamic> summaries = [];

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() => loading = true);

    final token = await AuthService.getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/summary/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint("SUMMARY STATUS CODE: ${res.statusCode}");
    debugPrint("SUMMARY RAW BODY: ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['summaries'];

      debugPrint("SUMMARY PARSED LIST LENGTH: ${data.length}");
      debugPrint("SUMMARY FIRST ITEM: ${data.isNotEmpty ? data[0] : 'EMPTY'}");

      setState(() {
        summaries = data;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không lấy được summary")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Completed ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : summaries.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadSummaries,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: summaries.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = summaries[index];
            return _buildSummaryCard(s);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(dynamic s) {
    final table =
        s['reservation']?['table']?['tableNumber'] ?? 'Unknown';
    final total = s['totalAmount'] ?? 0;
    final status = s['status'] ?? 'active';

    final isApproved = status == 'approved';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor:
          isApproved ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          child: Icon(
            isApproved
                ? Icons.check_circle_outline
                : Icons.hourglass_bottom,
            color: isApproved ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          "Table: $table",
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          "Total: \$${total.toString()}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: isApproved ? Colors.green : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No completed orders yet",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
