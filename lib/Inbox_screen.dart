import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/chat_service.dart';
import 'chat.dart';
import 'package:intl/intl.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatService _chatService = ChatService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    final chats = await _chatService.getRecentChats(_currentUserId);
    setState(() {
      _chats = chats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6CDF),
        elevation: 0,
        title: Text(
          "Messages",
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadChats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _chats.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    itemCount: _chats.length,
                    separatorBuilder: (context, index) => Divider(height: 1.h, indent: 70.w, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      return ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: chat['other_id'],
                                receiverName: chat['other_name'],
                              ),
                            ),
                          );
                          _loadChats(); // Refresh list when coming back
                        },
                        leading: CircleAvatar(
                          radius: 25.r,
                          backgroundColor: Colors.blue[50],
                          child: Text(
                            chat['other_name'][0],
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.sp),
                          ),
                        ),
                        title: Text(
                          chat['other_name'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          chat['last_message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                        ),
                        trailing: Text(
                          _formatTime(chat['time']),
                          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return DateFormat.Hm().format(date);
    }
    return DateFormat.MMMd().format(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No messages yet",
            style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
