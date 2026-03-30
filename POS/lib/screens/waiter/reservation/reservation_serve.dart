// import 'package:flutter/material.dart';
// import '/../../services/food_service.dart';
// import '/../../services/reservation_service.dart';
//
// class ReservationServeScreen extends StatefulWidget {
//   final String sessionId;
//   final String tableNumber;
//
//   const ReservationServeScreen({
//     super.key,
//     required this.sessionId,
//     required this.tableNumber,
//   });
//
//   @override
//   State<ReservationServeScreen> createState() => _ReservationServeScreenState();
// }
//
// class _ReservationServeScreenState extends State<ReservationServeScreen> {
//   List foods = [];
//   bool loading = true;
//   Map<String, int> quantities = {}; // lưu số lượng món đã thêm
//
//   @override
//   void initState() {
//     super.initState();
//     fetchFoods();
//   }
//
//   Future<void> fetchFoods() async {
//     setState(() => loading = true);
//     try {
//       final data = await FoodService.listFood();
//       setState(() {
//         foods = data;
//         loading = false;
//       });
//       print("✅ Fetched ${data.length} foods");
//     } catch (e) {
//       print("❌ Error fetching foods: $e");
//       setState(() => loading = false);
//     }
//   }
//
//   Future<void> addFood(dynamic foodId) async {
//     final safeFoodId = foodId?.toString();
//     if (safeFoodId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Không thể thêm món: id null")),
//       );
//       return;
//     }
//
//     try {
//       final res = await ReservationService.addFoodToSession(
//         widget.sessionId,
//         safeFoodId,
//         quantity: 1,
//       );
//
//       // Cập nhật local quantities
//       setState(() {
//         quantities[safeFoodId] = (quantities[safeFoodId] ?? 0) + 1;
//       });
//
//       print("✅ Added food: $res");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Thêm món thành công!")),
//       );
//     } catch (e) {
//       print("❌ Error adding food: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi: ${e.toString()}")),
//       );
//     }
//   }
//
//   double calculateTotal(Map session) {
//     // fold trả về double để tránh lỗi num->int
//     return (session['items'] as List<dynamic>).fold(
//         0.0, (sum, item) => sum + (item['price'] as num).toDouble() * (item['quantity'] as num).toDouble());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Bàn ${widget.tableNumber} - Phục vụ")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : foods.isEmpty
//           ? const Center(child: Text("Không có món nào"))
//           : ListView.builder(
//         itemCount: foods.length,
//         itemBuilder: (context, index) {
//           final f = foods[index];
//           final name = f['name'] ?? "?";
//           final price = f['price']?.toStringAsFixed(0) ?? "?";
//           final foodId = f['_id'];
//           final qty = quantities[foodId.toString()] ?? 0;
//
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//             child: ListTile(
//               title: Text(name),
//               subtitle: Text("Giá: $price x $qty"),
//               trailing: ElevatedButton(
//                 onPressed: () => addFood(foodId),
//                 child: const Text("Thêm"),
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchFoods,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }
