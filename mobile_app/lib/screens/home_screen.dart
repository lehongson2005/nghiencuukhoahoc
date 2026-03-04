import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'checkin_camera_screen.dart';
import 'face_register_screen.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  String _statusMessage = "Sẵn sàng điểm danh";
  bool _isLoading = false;
  List<dynamic> _myEvents = [];
  String? _selectedEventId;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        _user = jsonDecode(userJson);
      });
      _fetchMyEvents();
      
      // Auto-check face registration
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_user!['face_image_path'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bạn cần đăng ký khuôn mặt để bắt đầu điểm danh!"),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: "ĐĂNG KÝ NGAY", 
                onPressed: () {
                   // Navigate to face register is handled via BottomNav or custom call
                   // Here we just notify, let them use the 'Dashboard' button I added
                }
              ),
            )
          );
        }
      });
    }
  }

  Future<void> _fetchMyEvents() async {
    if (_user == null) return;
    
    final result = await _apiService.getMyEvents(_user!['id'].toString());
    if (mounted && result['status'] == true) {
      setState(() {
        _myEvents = result['data'];
        if (_myEvents.isNotEmpty && _selectedEventId == null) {
          _selectedEventId = _myEvents[0]['id'].toString();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: CustomScrollView(
          slivers: [
            // Slick Header
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Xin chào, ${_user?['name'] ?? 'Sinh viên'}!",
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Bắt đầu ngày mới với những sự kiện ý nghĩa",
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    _buildStatusCard(),
                    
                    SizedBox(height: 30),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Sự kiện của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        if (_myEvents.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text("${_myEvents.length} sự kiện", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                      ],
                    ),
                    SizedBox(height: 15),

                    _myEvents.isEmpty 
                      ? _buildEmptyEvents()
                      : Column(
                          children: [
                            _buildEventSelector(),
                            SizedBox(height: 40),
                            _buildCheckInAction(),
                          ],
                        ),
                    
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    bool hasFace = _user != null && _user!['face_image_path'] != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (!hasFace) {
               await Navigator.push(context, MaterialPageRoute(builder: (_) => FaceRegisterScreen()));
               _loadUserData();
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text("Dữ liệu khuôn mặt đã tồn tại. Liên hệ Admin để reset."),
                   behavior: SnackBarBehavior.floating,
                   backgroundColor: AppColors.textPrimary,
                 )
               );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (hasFace ? AppColors.accent : AppColors.error).withOpacity(0.1), 
                    shape: BoxShape.circle
                  ),
                  child: Icon(
                    hasFace ? Icons.verified_user_rounded : Icons.report_problem_rounded, 
                    color: hasFace ? AppColors.accent : AppColors.error, 
                    size: 28
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Trạng thái định danh", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text(
                        hasFace ? "Hệ thống sẵn sàng" : "Chưa đăng ký khuôn mặt", 
                        style: TextStyle(
                          color: AppColors.textPrimary, 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                ),
                if (!hasFace)
                  Icon(Icons.arrow_forward_ios_rounded, color: AppColors.error, size: 14)
                else
                  Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEvents() {
    return Container(
      padding: EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
            child: Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey.shade400),
          ),
          SizedBox(height: 20),
          Text("Trống", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text(
            "Bạn chưa đăng ký sự kiện nào.\nHãy chuyển sang tab Sự kiện để đăng ký nhé!", 
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5), 
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildEventSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chọn sự kiện điểm danh", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary.withOpacity(0.7))),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedEventId,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              items: _myEvents.map<DropdownMenuItem<String>>((ev) {
                return DropdownMenuItem<String>(
                  value: ev['id'].toString(),
                  child: Text(ev['title'] ?? 'Sự kiện', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedEventId = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInAction() {
    bool hasFace = _user != null && _user!['face_image_path'] != null;
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (hasFace ? AppColors.primary : AppColors.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasFace ? _statusMessage : "⚠️ Vui lòng đăng ký khuôn mặt trước", 
              style: TextStyle(
                color: hasFace ? AppColors.primary : AppColors.error, 
                fontSize: 14, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
          SizedBox(height: 30),
          _isLoading
            ? CircularProgressIndicator(color: AppColors.primary)
            : GestureDetector(
                onTap: hasFace ? _checkIn : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Bạn cần đăng ký khuôn mặt để điểm danh!"), 
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    )
                  );
                },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (hasFace ? AppColors.primary : Colors.grey).withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 5,
                      )
                    ],
                    gradient: hasFace 
                        ? AppColors.primaryGradient 
                        : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasFace ? Icons.qr_code_scanner_rounded : Icons.lock_person_rounded, 
                          color: Colors.white, 
                          size: 70
                        ),
                        SizedBox(height: 12),
                        Text(
                          hasFace ? "ĐIỂM DANH" : "BỊ KHÓA", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w900, 
                            fontSize: 15, 
                            letterSpacing: 2,
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
