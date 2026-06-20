class MessageModel {
  final String? id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
