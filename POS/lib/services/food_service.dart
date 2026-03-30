import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FoodService {
  static const String baseUrl = "http://10.0.2.2:5000/api/foods";

  // Lấy danh sách food
  static Future<List> listFood() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/list"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body); // body là Map<String, dynamic>
      return List.from(body['data'] ?? []); // lấy data là List
    } else {
      throw Exception("Lỗi khi lấy danh sách món ăn");
    }
  }
}
