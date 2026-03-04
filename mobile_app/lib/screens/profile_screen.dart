import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import 'face_register_screen.dart';
import 'attendance_history_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = ApiService.baseUrl.replaceAll('/api', '');
    String? faceUrl = (_user != null && _user!['face_image_path'] != null) 
        ? "$baseUrl/${_user!['face_image_path']}" 
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Cá nhân", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(decoration: BoxDecoration(gradient: AppColors.primaryGradient)),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 4),
                    ),
                    child: ClipOval(
                      child: faceUrl != null
                        ? Image.network(faceUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, size: 50))
                        : Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(_user?['name'] ?? "Sinh viên", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("MSSV: ${_user?['mssv'] ?? 'N/A'}", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Danh sách tính năng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.face_retouching_natural,
                    title: "Đăng ký khuôn mặt",
                    subtitle: faceUrl != null ? "Đã xác thực ✅ (Liên hệ Admin để reset)" : "Chưa đăng ký",
                    onTap: faceUrl != null ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Khuôn mặt đã được đăng ký. Vui lòng liên hệ Admin để thay đổi."))
                      );
                    } : () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => FaceRegisterScreen()));
                      _loadUserData();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: "Lịch sử điểm danh",
                    subtitle: "Xem lại các sự kiện đã tham gia",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceHistoryScreen(userId: _user!['id'].toString())));
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: "Về ứng dụng",
                    subtitle: "Phiên bản 2.0.0",
                    onTap: () {},
                  ),
                  SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: "Đăng xuất",
                    subtitle: "Thoát khỏi tài khoản hiện tại",
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                    },
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor ?? AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor ?? AppColors.textPrimary)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
