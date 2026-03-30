import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReservationService {
  static const String baseUrl = "http://10.0.2.2:5000/api/reservations";

  static Future<List> listSeated({required String date}) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/waiter/seated?date=$date"),
      headers: { "Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      final transformed = data.map((r) => {
        "_id": r["_id"],
        "user": r["user"],
        "table": r["table"],
        "reservationDate": r["reservationDate"],
        "expectedArrivalTime": r["expectedArrivalTime"],
        "numberOfGuests": r["numberOfGuests"],
        "status": r["status"],
        "note": r["note"],
        "canClaim": r["canClaim"],       // check xem waiter đã claim chưa
        "mySessionId": r["mySessionId"]  // session id của waiter hiện tại
      }).toList();

      return transformed;
    } else {
      throw Exception("Failed to load reservations");
    }
  }



  // Claim / nhận bàn
  Future<Map<String, dynamic>?> startServing(String reservationId) async {
    final token = await AuthService.getToken();
    if (token == null) return null;

    final res = await http.post(
      Uri.parse("$baseUrl/serve/start"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"reservationId": reservationId}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print("Serving started: $data");
      return data['session']; // trả về session của waiter này
    } else {
      print("❌ Start Serving Failed: ${res.statusCode} - ${res.body}");
      return null;
    }
  }


  // Thêm món vào ServeSession
  static Future<Map<String, dynamic>> addFoodToSession(
      String sessionId,
      String foodId, {
        int quantity = 1,
      }) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/api/serve/$sessionId/add-food"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "foodId": foodId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      String errorMessage;
      try {
        errorMessage = jsonDecode(res.body)["message"];
      } catch (_) {
        errorMessage = res.body;
      }
      throw Exception(errorMessage);
    }
  }

  // Lấy chi tiết ServeSession
  static Future<Map<String, dynamic>> getServeSessionDetail(String sessionId) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse("http://10.0.2.2:5000/api/serve/$sessionId/detail"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      String errorMessage;
      try {
        errorMessage = jsonDecode(res.body)["message"];
      } catch (_) {
        errorMessage = res.body;
      }
      throw Exception(errorMessage);
    }
  }

  // Xóa món khỏi ServeSession
  static Future<Map<String, dynamic>> removeFoodFromSession(
      String sessionId,
      String foodId,
      ) async {
    final token = await AuthService.getToken();
    final res = await http.delete(
      Uri.parse("http://10.0.2.2:5000/api/serve/$sessionId/remove-food"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"foodId": foodId}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      String errorMessage;
      try {
        errorMessage = jsonDecode(res.body)["message"];
      } catch (_) {
        errorMessage = res.body;
      }
      throw Exception(errorMessage);
    }
  }

  // Cập nhật số lượng món trong ServeSession
  static Future<Map<String, dynamic>> updateFoodQuantity(
      String sessionId,
      String foodId,
      int quantity,
      ) async {
    final token = await AuthService.getToken();
    final res = await http.patch(
      Uri.parse("http://10.0.2.2:5000/api/serve/$sessionId/update-food"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "foodId": foodId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      String errorMessage;
      try {
        errorMessage = jsonDecode(res.body)["message"];
      } catch (_) {
        errorMessage = res.body;
      }
      throw Exception(errorMessage);
    }
  }

  // Checkout ServeSession
  static Future<Map<String, dynamic>> checkoutSession(String sessionId) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/api/serve/$sessionId/checkout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      String errorMessage;
      try {
        errorMessage = jsonDecode(res.body)["message"];
      } catch (_) {
        errorMessage = res.body;
      }
      throw Exception(errorMessage);
    }
  }
  static Future<Map<String, dynamic>> checkoutSessionDebug(String sessionId) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/serve/$sessionId/checkout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("🔹 Checkout statusCode: ${res.statusCode}");
    print("🔹 Checkout body: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      String errorMessage;
      try {
        errorMessage = jsonDecode(res.body)["message"];
      } catch (_) {
        errorMessage = res.body;
      }
      throw Exception(errorMessage);
    }
  }
}
