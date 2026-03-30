import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FoodService {
  final String baseUrl = "http://10.0.2.2:5000/api/foods";

  Future<List> fetchFoods() async {
    final res = await http.get(Uri.parse("$baseUrl/list"));
    final data = jsonDecode(res.body);
    if (data['success']) {
      return data['data'];
    }
    return [];
  }

  Future<bool> deleteFood(String id) async {
    final res = await http.post(Uri.parse("$baseUrl/remove"), body: {"id": id});
    final data = jsonDecode(res.body);
    return data['success'] ?? false;
  }

  Future<Map<String, dynamic>> uploadFood({
    required String name,
    required String desc,
    required String price,
    required String category,
    required XFile image,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/add"));
    request.fields['name'] = name;
    request.fields['description'] = desc;
    request.fields['price'] = price;
    request.fields['category'] = category;
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    return jsonDecode(respStr);
  }
}
