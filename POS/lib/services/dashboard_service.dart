import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DashboardService {
  static const String baseUrl = "http://10.0.2.2:5000/api/dashboard";


  static Future<Map<String, double>?> getRevenueSummary() async {
    final token = await AuthService.getToken();
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/revenue-summary"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          "today": (data["today"] as num).toDouble(),
          "week": (data["week"] as num).toDouble(),
          "month": (data["month"] as num).toDouble(),
        };
      } else {
        print(" GET REVENUE SUMMARY ERROR: ${res.body}");
        return null;
      }
    } catch (e) {
      print(" GET REVENUE SUMMARY EXCEPTION: $e");
      return null;
    }
  }
}
