// import 'package:flutter/material.dart';
// import '/../../services/reservation_service.dart';
//
// class ReservationServeDetailScreen extends StatefulWidget {
//   final String sessionId;
//   final String tableNumber;
//
//   const ReservationServeDetailScreen({
//     super.key,
//     required this.sessionId,
//     required this.tableNumber,
//   });
//
//   @override
//   State<ReservationServeDetailScreen> createState() => _ReservationServeDetailScreenState();
// }
//
// class _ReservationServeDetailScreenState extends State<ReservationServeDetailScreen> {
//   Map<String, dynamic> session = {};
//   bool loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSessionDetail();
//   }
//
//   Future<void> fetchSessionDetail() async {
//     setState(() => loading = true);
//     try {
//       final data = await ReservationService.getServeSessionDetail(widget.sessionId);
//       setState(() {
//         session = data['session'] ?? {};
//         loading = false;
//       });
//       print("✅ Fetched session: ${session['items']?.length ?? 0} items");
//     } catch (e) {
//       print("❌ Error fetching session detail: $e");
//       setState(() => loading = false);
//     }
//   }
//
//   Future<void> updateQuantity(String foodId, int quantity) async {
//     try {
//       await ReservationService.updateFoodQuantity(widget.sessionId, foodId, quantity);
//       await fetchSessionDetail();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi cập nhật: $e")));
//     }
//   }
//
//   Future<void> removeFood(String foodId) async {
//     try {
//       await ReservationService.removeFoodFromSession(widget.sessionId, foodId);
//       await fetchSessionDetail();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi xoá món: $e")));
//     }
//   }
//
//   double getTotalPrice() {
//     if (session['items'] == null) return 0;
//     double total = 0;
//     for (var item in session['items']) {
//       final price = double.tryParse(item['price'].toString()) ?? 0;
//       final quantity = item['quantity'] ?? 0;
//       total += price * quantity;
//     }
//     return total;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chi tiết Bàn ${widget.tableNumber}")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : session['items'] == null || session['items'].isEmpty
//           ? const Center(child: Text("Chưa có món nào"))
//           : Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: session['items'].length,
//               itemBuilder: (context, index) {
//                 final item = session['items'][index];
//                 final foodId = item['food']?['_id']?.toString() ?? item['food'].toString();
//                 final name = item['name'] ?? "?";
//                 final price = double.tryParse(item['price'].toString()) ?? 0;
//                 final quantity = item['quantity'] ?? 0;
//
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//                   child: ListTile(
//                     title: Text(name),
//                     subtitle: Text("Giá: $price"),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.remove),
//                           onPressed: quantity > 1
//                               ? () => updateQuantity(foodId, quantity - 1)
//                               : () => removeFood(foodId),
//                         ),
//                         Text(quantity.toString()),
//                         IconButton(
//                           icon: const Icon(Icons.add),
//                           onPressed: () => updateQuantity(foodId, quantity + 1),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => removeFood(foodId),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.grey[200],
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text("Tổng tiền: ${getTotalPrice()}"),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
