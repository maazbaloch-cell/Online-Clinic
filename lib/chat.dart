import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/message_model.dart';
import 'services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverImage;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
      try {
        final message = MessageModel(
          senderId: _currentUserId,
          receiverId: widget.receiverId,
          content: text,
          createdAt: DateTime.now(),
        );
        await _chatService.sendMessage(message);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending message: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6CDF),
        title: Text(widget.receiverName, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessagesStream(_currentUserId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: false,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId;
                    return _ChatBubble(
                      text: msg.content,
                      isMe: isMe,
                      time: "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF2D6CDF)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _ChatBubble({required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF2D6CDF) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ),
          Text(time, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}
