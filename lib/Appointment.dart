import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'doctor_model.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorAppointmentScreen({super.key, required this.doctor});

  @override
  State<DoctorAppointmentScreen> createState() => _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '09:00AM - 10:00AM';

  final List<String> timeSlots = [
    '09:00AM - 10:00AM',
    '10:00AM - 11:00AM',
    '11:00AM - 12:00PM',
    '12:00PM - 01:00PM',
    '01:00PM - 02:00PM',
    '02:00PM - 03:00PM',
    '03:00PM - 04:00PM',
    '04:00PM - 05:00PM',
    '05:00PM - 06:00PM',
    '06:00PM - 07:00PM',
  ];

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: Stack(
        children: [
          Container(
            height: 260.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _roundIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTopDoctorCard(doctor),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: _buildBottomSheet(doctor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 36.h,
        width: 36.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildTopDoctorCard(Doctor doctor) {
    final displayName = 'Dr. ${doctor.fullName}';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 70.h,
            width: 70.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: doctor.imagePath != null
                  ? DecorationImage(
                image: AssetImage(doctor.imagePath!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: doctor.imagePath == null
                ? Icon(Icons.person, size: 40.sp, color: Colors.grey.shade400)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  doctor.specialty.toLowerCase(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _roundSmallIcon(
                      icon: Icons.phone,
                      onTap: () {},
                    ),
                    SizedBox(width: 8.w),
                    _roundSmallIcon(
                      icon: Icons.chat_bubble_outline,
                      onTap: () {},
                    ),
                    SizedBox(width: 8.w),
                    _roundSmallIcon(
                      icon: Icons.videocam_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundSmallIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 32.h,
        width: 32.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 18.sp, color: Colors.blue),
      ),
    );
  }

  Widget _buildBottomSheet(Doctor doctor) {
    final monthName = _monthName(_selectedDate.month);

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Doctor',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    doctor.qualification,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Working Time',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    doctor.workingTime,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        '$monthName  ${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _openCalendar,
                        child: Text(
                          'open calendar',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _buildWeekDaysRow(),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 52.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        return _timeChip(timeSlots[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Make an appointment',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekDaysRow() {
    final start = _selectedDate;
    final days = List.generate(5, (i) {
      final date = DateTime(start.year, start.month, start.day + i);
      return date;
    });
    return days.map((date) {
      final isSelected = date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;
      final weekday = _weekdayShort(date.weekday);
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: _dayChip(date.day.toString(), weekday, isSelected),
      );
    }).toList();
  }

  Future<void> _openCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _monthName(int m) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[m - 1];
  }

  String _weekdayShort(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[w - 1];
  }

  Widget _dayChip(String day, String label, bool selected) {
    return Container(
      width: 52.w,
      height: 64.h,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2196F3) : const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: selected ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String timeSlot) {
    final selected = _selectedTime == timeSlot;

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTime = timeSlot;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF3E0) : const Color(0xFFF5F7FB),
            borderRadius: BorderRadius.circular(16.r),
            border: selected
                ? Border.all(color: const Color(0xFFFFB74D), width: 1.w)
                : null,
          ),
          child: Center(
            child: Text(
              timeSlot,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: selected ? const Color(0xFFFF8F00) : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}