import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List reservations = [];
  List waiters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservations();
    fetchWaiters();
  }

  Future<void> fetchReservations() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse("http://10.0.2.2:5000/api/reservations"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      setState(() {
        reservations = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      print("Failed to fetch reservations: ${res.body}");
    }
  }

  Future<void> fetchWaiters() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse("http://10.0.2.2:5000/api/staff?role=waiter"), // sửa từ /api/users → /api/staff
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      setState(() {
        waiters = jsonDecode(res.body); // [{_id, username}, ...]
      });
    } else {
      print("Failed to fetch waiters: ${res.body}");
    }
  }


  Future<void> confirmReservation(String reservationId) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final res = await http.put(
      Uri.parse("http://10.0.2.2:5000/api/reservations/$reservationId/confirm"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      fetchReservations();
    } else {
      print("Failed to confirm reservation: ${res.body}");
    }
  }

  Future<void> seatReservation(
      String reservationId, int actualGuests, List<String> waiterIds) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    final res = await http.patch(
      Uri.parse("http://10.0.2.2:5000/api/reservations/$reservationId/seat"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "actualNumberOfGuests": actualGuests,
        "waiterIds": waiterIds
      }),
    );

    if (res.statusCode == 200) {
      fetchReservations();
    } else {
      print("Failed to seat reservation: ${res.body}");
    }
  }

  void _showSeatDialog(Map reservation) async {
    List<String> selectedWaiters = [];
    int actualGuests = reservation['numberOfGuests'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Seat Reservation"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Reservation: Table ${reservation['table']['tableNumber']}"),
                SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Actual number of guests",
                  ),
                  onChanged: (val) {
                    setStateDialog(() {
                      actualGuests = int.tryParse(val) ?? reservation['numberOfGuests'];
                    });
                  },
                ),
                SizedBox(height: 10),
                waiters.isEmpty
                    ? Text("No waiters available")
                    : Column(
                  children: waiters.map((w) {
                    return CheckboxListTile(
                      title: Text(w['username']),
                      value: selectedWaiters.contains(w['_id']),
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val == true)
                            selectedWaiters.add(w['_id']);
                          else
                            selectedWaiters.remove(w['_id']);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 5),
                Text(
                  "Select 1-3 waiters to serve",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                seatReservation(reservation['_id'], actualGuests, selectedWaiters);
                Navigator.pop(context);
              },
              child: Text("Seat"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservations")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final r = reservations[index];
          List<Widget> actionButtons = [];

          if (r['status'] == 'pending') {
            actionButtons.add(
              ElevatedButton(
                onPressed: () => confirmReservation(r['_id']),
                child: Text("Confirm"),
              ),
            );
          }

          if (r['status'] == 'confirmed') {
            actionButtons.add(
              ElevatedButton(
                onPressed: () => _showSeatDialog(r),
                child: Text("Seat"),
              ),
            );
          }

          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text("Table: ${r['table']?['tableNumber'] ?? 'Unknown'}"),
              subtitle: Text(
                  "Status: ${r['status']} | Guests: ${r['numberOfGuests']} | Actual: ${r['actualNumberOfGuests'] ?? '-'}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: actionButtons,
              ),
            ),
          );
        },
      ),
    );
  }
}
