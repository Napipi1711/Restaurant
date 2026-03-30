import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  static Future<String?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users/login"),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode({ "email": email, "password": password }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("role", data["user"]["role"]);
        await prefs.setString("username", data["user"]["username"]);

        return data["user"]["role"];
      }
      return null;
    } catch (e) {
      print(" LOGIN ERROR: $e");
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return (token ?? '').isNotEmpty;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==== LẤY USER ID TỪ TOKEN ====
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return null;

    try {
      final payload = Jwt.parseJwt(token);
      return payload['id'];
    } catch (e) {
      print(" ERROR PARSING TOKEN: $e");
      return null;
    }
  }
}
