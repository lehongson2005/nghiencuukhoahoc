import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'face_register_screen.dart';
import 'checkin_camera_screen.dart';
import '../constants/app_colors.dart';

import 'attendance_history_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  String _statusMessage = "Sẵn sàng điểm danh";
  bool _isLoading = false;
  List<dynamic> _events = [];
  String? _selectedEventId;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchEvents();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        _user = jsonDecode(userJson);
      });
    }
  }

  Future<void> _fetchEvents() async {
    if (_user == null) return;
    
    final result = await _apiService.getMyEvents(_user!['id'].toString());
    if (mounted && result['status'] == true) {
      setState(() {
        _events = result['data'];
        if (_events.isNotEmpty && _selectedEventId == null) {
          _selectedEventId = _events[0]['id'].toString();
        }
      });
    }
  }

  Future<void> _checkIn() async {
    if (_selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng chọn sự kiện")));
      return;
    }

    setState(() {
       _isLoading = true;
       _statusMessage = "Đang lấy vị trí GPS...";
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
            setState(() { _isLoading = false; _statusMessage = "Yêu cầu quyền GPS thất bại"; });
            return;
        }
      }
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      final imagePath = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => CheckInCameraScreen())
      );

      if (imagePath == null) {
        setState(() { _isLoading = false; _statusMessage = "Đã hủy chụp ảnh"; });
        return;
      }

      setState(() => _statusMessage = "Đang xác thực khuôn mặt...");
      
      final result = await _apiService.checkIn(
        _user!['id'].toString(), 
        _selectedEventId!, 
        position.latitude, 
        position.longitude, 
        imagePath
      );
      
      setState(() {
        _isLoading = false;
        if (result['status'] == true) {
          _statusMessage = "Điểm danh THÀNH CÔNG!";
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chúc mừng! Bạn đã điểm danh thành công."), backgroundColor: AppColors.accent));
        } else {
          _statusMessage = "Thất bại: ${result['message']}";
        }
      });

    } catch (e) {
      setState(() { _isLoading = false; _statusMessage = "Lỗi hệ thống: $e"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy URL ảnh từ server
    // Ví dụ: http://192.168.1.168:8080/storage/faces/xxx.jpg
    String baseUrl = ApiService.baseUrl.replaceAll('/api', '');
    String? faceUrl = (_user != null && _user!['face_image_path'] != null) 
        ? "$baseUrl/${_user!['face_image_path']}" 
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Profile
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                },
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh đại diện khuôn mặt
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: ClipOval(
                          child: faceUrl != null
                            ? Image.network(
                                faceUrl, 
                                fit: BoxFit.cover, 
                                errorBuilder: (_, __, ___) => Icon(Icons.person, size: 40, color: Colors.white),
                              )
                            : Container(color: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 45)),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user?['name'] ?? "Sinh viên",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "MSSV: ${_user?['mssv'] ?? 'N/A'}",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                              child: Text("Hệ thống điểm danh AI", style: TextStyle(color: Colors.white, fontSize: 12)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút Đăng ký khuôn mặt - Chỉ hiện nếu chưa đăng ký
                  if (faceUrl == null)
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => FaceRegisterScreen()));
                        _loadUserData(); 
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(colors: [Colors.indigo[400]!, Colors.indigo[800]!]),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.camera_front, color: Colors.white, size: 40),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Đăng ký nhận diện", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("Bạn cần đăng ký khuôn mặt để điểm danh", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ) else 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text("✅ Khuôn mặt đã được xác thực", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                    ),

                  SizedBox(height: 15),
                  
                  // Nút Lịch sử điểm danh
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceHistoryScreen(userId: _user!['id'].toString())));
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: AppColors.primary, size: 40),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Lịch sử điểm danh", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("Xem lại các sự kiện đã tham gia", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),
                  Text("Chọn sự kiện điểm danh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 15),

                  // Dropdown chọn sự kiện
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: _events.isEmpty
                      ? Padding(padding: EdgeInsets.all(15), child: Center(child: Text("Không có sự kiện khả dụng")))
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedEventId,
                            isExpanded: true,
                            items: _events.map<DropdownMenuItem<String>>((ev) {
                              return DropdownMenuItem<String>(
                                value: ev['id'].toString(),
                                child: Text(ev['title'] ?? 'Sự kiện', style: TextStyle(fontSize: 15)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedEventId = val),
                          ),
                        ),
                  ),

                  SizedBox(height: 50),
                  
                  // Nút điểm danh hình tròn cực đẹp - CHỈ HIỆN NẾU ĐÃ ĐĂNG KÝ
                  Center(
                    child: Column(
                      children: [
                        if (faceUrl == null)
                          Text("⚠️ Hãy đăng ký khuôn mặt trước khi điểm danh", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))
                        else
                          Text(_statusMessage, style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
                        
                        SizedBox(height: 25),
                        
                        _isLoading
                          ? CircularProgressIndicator(color: AppColors.primary)
                          : (faceUrl != null) 
                            ? GestureDetector(
                                onTap: _checkIn,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 25,
                                        spreadRadius: 8,
                                      )
                                    ],
                                    gradient: RadialGradient(
                                      colors: [AppColors.primaryLight, AppColors.primary],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.touch_app, color: Colors.white, size: 50),
                                        SizedBox(height: 5),
                                        Text("CHECK IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Icon(Icons.lock_person, size: 80, color: Colors.grey[300]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchEvents,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
