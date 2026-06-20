class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  final String type;
  final dynamic data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    required this.type,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      time: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'general',
      data: json['data'],
    );
  }
}
