import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ServeService {
  static const String baseUrl = "http://10.0.2.2:5000/api/serve";


  static Future<Map<String, dynamic>> getSession(String sessionId) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/$sessionId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Không lấy được session: ${res.statusCode}");
    }
  }

  // Thêm món
  static Future<Map<String, dynamic>> addFood(String sessionId, String foodId) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/$sessionId/add-food"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"foodId": foodId, "quantity": 1}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['session'];
    } else {
      throw Exception("Thêm món lỗi: ${res.statusCode}");
    }
  }

  // Checkout
  static Future<Map<String, dynamic>> checkout(String sessionId) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/$sessionId/checkout"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['session'];
    } else {
      throw Exception("Checkout lỗi: ${res.statusCode}");
    }
  }
}
