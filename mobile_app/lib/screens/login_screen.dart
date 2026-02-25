import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import '../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    if (_mssvController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _apiService.login(
      _mssvController.text, 
      _passwordController.text
    );
    setState(() => _isLoading = false);

    if (result['status'] == true) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => HomeScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đăng nhập thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với Gradient
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.face_retouching_natural, size: 80, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    "Face Attendance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "Hệ thống điểm danh sinh viên",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            // Form đăng nhập
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _mssvController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Mã số sinh viên",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          ),
                        ),
                        Divider(),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Mật khẩu",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  _isLoading 
                  ? CircularProgressIndicator(color: AppColors.primary)
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _login,
                        child: Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
