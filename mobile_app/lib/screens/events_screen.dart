import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getEvents();
      if (mounted && result['status'] == true) {
        setState(() {
          _allEvents = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Sự kiện", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(decoration: BoxDecoration(gradient: AppColors.primaryGradient)),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
              ? Padding(padding: EdgeInsets.only(top: 100), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: _allEvents.isEmpty
                      ? Padding(padding: EdgeInsets.only(top: 100), child: Center(child: Text("Hiện không có sự kiện nào", style: TextStyle(color: AppColors.textSecondary))))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(20),
                          itemCount: _allEvents.length,
                          itemBuilder: (context, index) {
                            return _buildEventCard(_allEvents[index]);
                          },
                        ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    String dateStr = event['start_time'] ?? '';
    String formattedDate = "Chưa xác định";
    try {
      DateTime dt = DateTime.parse(dateStr);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {}

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
            ).then((_) => _fetchData());
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.local_activity_rounded, size: 50, color: AppColors.primary.withOpacity(0.4)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("Sắp diễn ra", style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      event['title'] ?? 'Sự kiện không tên',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text(formattedDate, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text(event['location'] ?? 'Địa điểm chưa cập nhật', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
