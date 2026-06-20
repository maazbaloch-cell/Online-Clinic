import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/notification_model.dart';
import 'services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = NotificationService();
  final _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.getNotificationsStream(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return GestureDetector(
                onTap: () {
                  _notificationService.markAsRead(notification.id);
                  if (notification.type == 'payment' && notification.data != null) {
                    context.push('/payment', extra: notification.data);
                  }
                },
                child: _NotificationTile(notification: notification),
              );
            },
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
          Icon(Icons.notifications_none_rounded, size: 80.sp, color: Colors.grey[300]),
          SizedBox(height: 15.h),
          Text("No Notifications", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.notifications_active_rounded;
    Color color = const Color(0xFF2D6CDF);

    if (notification.type == 'payment') {
      icon = Icons.receipt_long_rounded;
      color = Colors.green;
    } else if (notification.type == 'appointment') {
      icon = Icons.calendar_today_rounded;
      color = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text(notification.body, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
