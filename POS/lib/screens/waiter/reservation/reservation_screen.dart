// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '/../../services/auth_service.dart';
// import 'reservation_serve.dart';
// import '/../../services/reservation_service.dart';
//
// class ReservationScreen extends StatefulWidget {
//   const ReservationScreen({super.key});
//
//   @override
//   State<ReservationScreen> createState() => _ReservationScreenState();
// }
//
// class _ReservationScreenState extends State<ReservationScreen> {
//   List reservations = [];
//   bool isLoading = true;
//   String? myId;
//
//   @override
//   void initState() {
//     super.initState();
//     initData();
//   }
//
//   Future<void> initData() async {
//     myId = await AuthService.getUserId();
//     await fetchSeatedReservations();
//   }
//
//   Future<void> fetchSeatedReservations() async {
//     setState(() => isLoading = true);
//     final token = await AuthService.getToken();
//     if (token == null) return;
//
//     final today = DateTime.now().toIso8601String().substring(0, 10);
//     final url = Uri.parse("http://10.0.2.2:5000/api/reservations/waiter/seated?date=$today");
//
//     try {
//       final res = await http.get(url, headers: {"Authorization": "Bearer $token"});
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         setState(() => reservations = data['reservations'] ?? []);
//       } else {
//         print("❌ Fetch Seated Failed: ${res.statusCode} - ${res.body}");
//       }
//     } catch (e) {
//       print("❌ Error fetching reservations: $e");
//     }
//
//     setState(() => isLoading = false);
//   }
//
//   Future<void> startServing(Map reservation) async {
//     try {
//       if (myId == null) throw "User not logged in";
//
//       // Kiểm tra waiter có trong danh sách assigned
//       final waiters = reservation['servedByWaiters'] as List? ?? [];
//       final isMyTurn = waiters.any((w) => w['_id'].toString() == myId);
//       if (!isMyTurn) throw "Bạn không được phân công phục vụ bàn này";
//
//       // Lấy session của waiter hiện tại
//       final sessions = reservation['servedBySessions'] as List? ?? [];
//       final mySession = sessions.firstWhere(
//             (s) => s['waiter'] == myId,
//         orElse: () => null,
//       );
//       if (mySession == null) throw "Không tìm thấy session phục vụ cho bạn";
//
//       final sessionId = mySession['_id'].toString();
//
//       if (!mounted) return;
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ReservationServeScreen(
//             sessionId: sessionId,
//             tableNumber: reservation['table']['tableNumber'].toString(),
//           ),
//         ),
//       );
//       await fetchSeatedReservations(); // refresh khi quay về
//     } catch (e) {
//       print("❌ Start Serving Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Bàn đang phục vụ")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : reservations.isEmpty
//           ? const Center(child: Text("Không có bàn đang seated hôm nay"))
//           : ListView.builder(
//         itemCount: reservations.length,
//         itemBuilder: (context, index) {
//           final r = reservations[index];
//           final waiters = r['servedByWaiters'] as List? ?? [];
//           final usernames = waiters.map((w) => w['username']).join(', ');
//
//           // Kiểm tra waiter hiện tại có thể phục vụ
//           final canServe = myId != null && waiters.any((w) => w['_id'].toString() == myId);
//
//           final reservationDate = DateTime.parse(r['reservationDate']);
//           final dateStr = "${reservationDate.day}/${reservationDate.month}/${reservationDate.year}";
//           final timeStr = r['expectedArrivalTime'] ?? '-';
//
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               title: Text("Bàn: ${r['table']['tableNumber']}"),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Khách: ${r['user']['username']}"),
//                   Text("Số lượng khách: ${r['numberOfGuests']}"),
//                   Text("Ngày đặt: $dateStr"),
//                   Text("Giờ đến: $timeStr"),
//                   Text("Ghi chú: ${r['note'] ?? '-'}"),
//                   Text("Nhân viên phục vụ: $usernames"),
//                 ],
//               ),
//               trailing: ElevatedButton(
//                 onPressed: canServe ? () => startServing(r) : null,
//                 child: const Text("Phục vụ"),
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchSeatedReservations,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }
