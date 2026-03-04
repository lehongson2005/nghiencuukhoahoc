import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import 'event_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _allEvents = [];
  List<dynamic> _filteredEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _apiService.getEvents();
      setState(() {
        _allEvents = events['data'] ?? [];
        _filterEventsByDate();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching events: $e");
    }
  }

  void _filterEventsByDate() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        if (event['start_time'] == null) return false;
        DateTime eventDate = DateTime.parse(event['start_time']);
        return eventDate.year == _selectedDate.year &&
               eventDate.month == _selectedDate.month &&
               eventDate.day == _selectedDate.day;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom Calendar Header
          _buildHeader(),
          
          // Date Selector (Horizontal)
          _buildDateSelector(),
          
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filteredEvents.isEmpty
                ? _buildEmptyState()
                : _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM, yyyy').format(_selectedDate),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              SizedBox(height: 4),
              Text(
                "Lịch sự kiện",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          onSurface: AppColors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                    _filterEventsByDate();
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show 2 weeks
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index - 3)); // Start from 3 days ago
          bool isSelected = date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
          bool isToday = date.year == DateTime.now().year &&
                         date.month == DateTime.now().month &&
                         date.day == DateTime.now().day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _filterEventsByDate();
              });
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))
                ] : [],
                border: !isSelected && isToday ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.event_note_rounded, size: 50, color: Colors.grey.shade300),
          ),
          SizedBox(height: 20),
          Text(
            "Không có sự kiện nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            "Ngày này chưa có hoạt động nào diễn ra",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.school_rounded, color: AppColors.primary),
            ),
            title: Text(
              event['title'] ?? 'Tên sự kiện',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(event['start_time'] ?? 'Chưa xác định', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    SizedBox(width: 12),
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(event['location'] ?? 'Tại trường', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
              );
            },
          ),
        );
      },
    );
  }
}
