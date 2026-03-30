import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List orders = [];
  bool loading = true;
  int countdown = 0;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> fetchOrders() async {
    setState(() => loading = true);
    final token = await AuthService.getToken();
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/orders"),
        headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      );
      if (res.statusCode == 200) {
        setState(() {
          orders = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void showFoodCountdown(String customerName) {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    countdownTimer?.cancel();
    countdown = 5;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => countdown--);

      if (countdown > 0) {
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            elevation: 2,
            backgroundColor: Colors.orange.shade50,
            leading: const Icon(Icons.timer, color: Colors.orange),
            content: Text("Preparing food for $customerName... $countdown s"),
            actions: [const SizedBox()],
          ),
        );
      } else {
        timer.cancel();
        ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            backgroundColor: Colors.green,
            content: Text("🍽️ Food is ready for $customerName!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(), child: const Text("DISMISS", style: TextStyle(color: Colors.white)))
            ],
          ),
        );
      }
    });
  }

  Future<void> updateStatus(String orderId, String status, String customerName) async {
    final token = await AuthService.getToken();
    final res = await http.put(
      Uri.parse("http://10.0.2.2:5000/api/orders/$orderId/status"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    );

    if (res.statusCode == 200) {
      if (status == 'confirmed') showFoodCountdown(customerName);
      fetchOrders();
    }
  }

  void showCancelDialog(String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Order?"),
        content: const Text("This action will notify the customer and cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Keep Order")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              updateStatus(orderId, 'cancelled', '');
            },
            child: const Text("Confirm Cancel"),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'delivering': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Orders Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final status = order['status'];
            final color = getStatusColor(status);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Header của Card
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(Icons.person, color: color, size: 20),
                    ),
                    title: Text(order['customer']['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(formatDate(order['createdAt']), style: const TextStyle(fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Divider(height: 1),
                  // Nội dung
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text("\$${order['totalAmount']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          ],
                        ),
                        _buildActionUI(order),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionUI(order) {
    final status = order['status'];
    final id = order['_id'];
    final name = order['customer']['username'];

    if (status == 'completed') return const Icon(Icons.check_circle, color: Colors.green, size: 30);
    if (status == 'cancelled') return const Icon(Icons.cancel, color: Colors.red, size: 30);

    return Row(
      children: [
        if (status == 'pending' || status == 'confirmed')
          IconButton(
            onPressed: () => showCancelDialog(id),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        const SizedBox(width: 8),
        _buildMainButton(status, id, name),
      ],
    );
  }

  Widget _buildMainButton(String status, String id, String name) {
    String label = "";
    IconData icon = Icons.check;
    Color btnColor = Colors.blue;

    if (status == 'pending') { label = "Confirm"; icon = Icons.thumb_up_alt_outlined; btnColor = Colors.blue; }
    else if (status == 'confirmed') { label = "Deliver"; icon = Icons.delivery_dining; btnColor = Colors.purple; }
    else if (status == 'delivering') { label = "Finish"; icon = Icons.done_all; btnColor = Colors.green; }
    else return const SizedBox();

    return ElevatedButton.icon(
      onPressed: () => updateStatus(id, _getNextStatus(status), name),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  String _getNextStatus(String current) {
    if (current == 'pending') return 'confirmed';
    if (current == 'confirmed') return 'delivering';
    return 'completed';
  }
}