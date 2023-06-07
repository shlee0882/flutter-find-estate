class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
  });
}
