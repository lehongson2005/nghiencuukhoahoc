import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = 'http://192.168.1.174:8080/api'; 

  Future<Map<String, dynamic>> login(String mssv, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'mssv': mssv, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        // Lưu user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['data']));
      }
      return data;
    } else {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {
          'status': false, 
          'message': 'Lỗi kết nối (${response.statusCode}): ${response.reasonPhrase}'
        };
      }
    }
  }

  Future<Map<String, dynamic>> registerFace(String userId, String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/face/register'));
    request.fields['user_id'] = userId;
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    request.headers.addAll({'Accept': 'application/json'});

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {
          'status': false, 
          'message': 'Lỗi đăng ký khuôn mặt (${response.statusCode})'
        };
      }
    }
  }

  Future<Map<String, dynamic>> checkIn(String userId, String eventId, double lat, double long, String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/checkin'));
    request.fields['user_id'] = userId;
    request.fields['event_id'] = eventId;
    request.fields['latitude'] = lat.toString();
    request.fields['longitude'] = long.toString();
    
    if (filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('evidence_image', filePath));
    }
    request.headers.addAll({'Accept': 'application/json'});

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {
          'status': false, 
          'message': 'Lỗi máy chủ (${response.statusCode}): ${response.reasonPhrase}'
        };
      }
    }
  }

  Future<Map<String, dynamic>> getEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'status': false, 'message': 'Không thể tải danh sách sự kiện'};
    }
  }

  Future<Map<String, dynamic>> getAttendanceHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/history/$userId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'status': false, 'message': 'Không thể tải lịch sử điểm danh'};
    }
  }

  // --- NEW: Quản lý Đăng ký Sự kiện ---

  Future<Map<String, dynamic>> getMyEvents(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/events'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'status': false, 'message': 'Không thể tải danh sách sự kiện của tôi'};
    }
  }

  Future<Map<String, dynamic>> registerForEvent(String userId, String eventId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'user_id': userId, 'event_id': eventId}),
    );

    return jsonDecode(response.body);
  }
}
