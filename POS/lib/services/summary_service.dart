import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SummaryService {
  static const String baseUrl = "http://10.0.2.2:5000/api/summary";

  // Lấy danh sách summary đã submit
  static Future<List<dynamic>?> getSubmittedSummaries() async {
    final token = await AuthService.getToken();
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/submitted"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["summaries"];
      } else {
        print(" GET SUBMITTED ERROR: ${res.body}");
        return null;
      }
    } catch (e) {
      print(" GET SUBMITTED EXCEPTION: $e");
      return null;
    }
  }

  // Approve một summary theo ID
  static Future<bool> approveSummary(String summaryId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse("$baseUrl/approve/$summaryId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        print(" APPROVE SUMMARY ERROR: ${res.body}");
        return false;
      }
    } catch (e) {
      print(" APPROVE SUMMARY EXCEPTION: $e");
      return false;
    }
  }
}
