import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';

class EventDetailScreen extends StatefulWidget {
  final dynamic event;

  EventDetailScreen({required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isRegistered = false;
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
      _user = jsonDecode(userJson);
      _checkRegistrationStatus();
    }
  }

  Future<void> _checkRegistrationStatus() async {
    if (_user == null) return;
    
    setState(() => _isLoading = true);
    final result = await _apiService.getMyEvents(_user!['id'].toString());
    
    if (mounted && result['status'] == true) {
      List<dynamic> myEvents = result['data'];
      bool registered = myEvents.any((e) => e['id'].toString() == widget.event['id'].toString());
      setState(() {
        _isRegistered = registered;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (_user == null) return;

    setState(() => _isLoading = true);
    final result = await _apiService.registerForEvent(
      _user!['id'].toString(), 
      widget.event['id'].toString()
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['status'] == true) {
        setState(() => _isRegistered = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký tham gia thành công!"), backgroundColor: AppColors.accent)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Lỗi đăng ký"), backgroundColor: AppColors.error)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = widget.event['start_time'] ?? '';
    String formattedDate = "Chưa xác định";
    try {
      DateTime dt = DateTime.parse(dateStr);
      formattedDate = DateFormat('dd MMMM, yyyy - HH:mm').format(dt);
    } catch (_) {}

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: Center(
                  child: Icon(Icons.event, size: 100, color: Colors.white24),
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
                  Text(
                    widget.event['title'] ?? 'Sự kiện không tên',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 15),
                  _buildInfoRow(Icons.calendar_today, "Thời gian", formattedDate),
                  _buildInfoRow(Icons.location_on_outlined, "Địa điểm", widget.event['location'] ?? 'Chưa cập nhật'),
                  _buildInfoRow(Icons.people_outline, "Đối tượng", "Tất cả sinh viên"),
                  
                  Divider(height: 40),
                  
                  Text(
                    "Mô tả sự kiện",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.event['description'] ?? "Không có mô tả chi tiết cho sự kiện này.",
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                  ),
                  
                  SizedBox(height: 100), // Khoảng trống cho nút ở dưới
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, -5))],
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Container(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isRegistered ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRegistered ? Colors.grey.shade200 : AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade100,
                    disabledForegroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: _isRegistered ? 0 : 8,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    _isRegistered ? "ĐÃ ĐĂNG KÝ THAM GIA" : "ĐĂNG KÝ NGAY",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
