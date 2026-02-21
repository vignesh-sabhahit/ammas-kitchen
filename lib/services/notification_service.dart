import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    // Request notification permission on Android 13+
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleExpiryNotification(InventoryItem item) async {
    if (item.id == null || item.expiryDate == null) return;

    final now = DateTime.now();

    // Schedule 3-day warning
    final threeDayBefore =
        item.expiryDate!.subtract(const Duration(days: 3));
    if (threeDayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: item.id! * 10,
        title: "Amma, use it soon!",
        body:
            "${item.name} expires in 3 days. Time to plan a dish with it!",
        scheduledDate: _atMorning(threeDayBefore),
      );
    }

    // Schedule expiry day notification
    if (item.expiryDate!.isAfter(now)) {
      await _scheduleNotification(
        id: item.id! * 10 + 1,
        title: "Expires today!",
        body:
            "${item.name} expires today. Check if it's still good to use.",
        scheduledDate: _atMorning(item.expiryDate!),
      );
    }
  }

  Future<void> cancelNotification(int itemId) async {
    await _notifications.cancel(itemId * 10);
    await _notifications.cancel(itemId * 10 + 1);
  }

  DateTime _atMorning(DateTime date) {
    return DateTime(date.year, date.month, date.day, 8, 0);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      'Expiry Alerts',
      channelDescription: 'Notifications for items about to expire',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    // Use show() for immediate or near-future notifications
    // For scheduled notifications we check if the date is in the future
    final now = DateTime.now();
    if (scheduledDate.isAfter(now)) {
      final delay = scheduledDate.difference(now);
      // For simplicity, use a delayed show approach
      // In production, you'd use zonedSchedule with timezone package
      Future.delayed(delay, () {
        _notifications.show(id, title, body, details);
      });
    }
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General',
      channelDescription: 'General notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _notifications.show(0, title, body, NotificationDetails(android: androidDetails));
  }
}
