import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String userId;
  AttendanceHistoryScreen({required this.userId});

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final result = await _apiService.getAttendanceHistory(widget.userId);
    if (mounted && result['status'] == true) {
      setState(() {
        _history = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Lịch sử Điểm danh"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _history.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  child: ListView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      final event = item['event'];
                      final DateTime time = DateTime.parse(item['checkin_time']);
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_circle, color: AppColors.accent),
                          ),
                          title: Text(
                            event?['title'] ?? "Sự kiện",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                "Thời gian: ${DateFormat('HH:mm - dd/MM/yyyy').format(time)}",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              Text(
                                "Trạng thái: ${item['status'] == 'success' ? 'Thành công' : 'Thất bại'}",
                                style: TextStyle(
                                  color: item['status'] == 'success' ? AppColors.accent : AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text("Chưa có lịch sử điểm danh", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
