import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import 'serving_detail.dart';
import 'serving_add_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  Future<List<dynamic>> _reservations = Future.value([]);
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final dayStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final url = Uri.parse(
        'http://10.0.2.2:5000/api/reservations/my-servings?date=$dayStr');

    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        // Lọc chỉ giữ những reservation có status == 'seated'
        final seatedReservations = (data is List ? data : [])
            .where((resv) => resv['status'] == 'seated')
            .toList();
        _reservations = Future.value(seatedReservations);
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blueAccent;
      case 'confirmed':
        return Colors.orange;
      case 'seated':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _startServing(String reservationId) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final url = Uri.parse('http://10.0.2.2:5000/api/serve-sessions/start');
    final res = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reservationId': reservationId}));

    if (res.statusCode == 201) {
      _loadReservations();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Serving started!")));
    } else {
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Seated Reservations")),
      body: FutureBuilder<List<dynamic>>(
        future: _reservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined,
                      size: 70, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("No seated reservations for today",
                      style: TextStyle(fontSize: 17, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final resv = reservations[index];
              final status = resv['status'] ?? 'unknown';
              final tableNumber =
                  resv['table']?['tableNumber']?.toString() ?? 'N/A';
              final reservationDate = DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(resv['reservationDate']));
              final arrivalTime = resv['expectedArrivalTime'] ?? '';
              final guests = resv['actualNumberOfGuests'] ??
                  resv['numberOfGuests'] ??
                  0;

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Table $tableNumber • $reservationDate $arrivalTime",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Guests: $guests"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServingDetailScreen(reservation: resv),
                                ),
                              );
                            },
                            child: const Text("Detail"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServingAddScreen(reservation: resv),
                                ),
                              );
                            },
                            child: const Text("Add Food"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
