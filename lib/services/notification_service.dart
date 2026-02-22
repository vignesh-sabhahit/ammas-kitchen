import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/services/database_service.dart';

/// Reminder interval options (days before expiry)
const Map<int, String> reminderOptions = {
  1: '1 day before',
  3: '3 days before',
  7: '1 week before',
  14: '2 weeks before',
  30: '1 month before',
  60: '2 months before',
};

/// Default reminder interval key in SharedPreferences
const String _kReminderDefault = 'reminder_default_days';

/// Default value if nothing is set
const int _kDefaultReminderDays = 7;

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
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// Get the global default reminder days from SharedPreferences
  Future<int> getGlobalReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kReminderDefault) ?? _kDefaultReminderDays;
  }

  /// Set the global default reminder days
  Future<void> setGlobalReminderDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderDefault, days);
  }

  /// Schedule expiry notifications for an item.
  /// Uses per-item reminderDaysBefore if set, otherwise global default.
  Future<void> scheduleExpiryNotification(InventoryItem item) async {
    if (item.id == null || item.expiryDate == null) return;

    // Cancel any existing notifications for this item first
    await cancelNotification(item.id!);

    final now = DateTime.now();
    final effectiveDays = item.reminderDaysBefore ?? await getGlobalReminderDays();

    // Schedule reminder notification (X days before expiry)
    final reminderDate = item.expiryDate!.subtract(Duration(days: effectiveDays));
    if (reminderDate.isAfter(now)) {
      final daysText = effectiveDays == 1
          ? 'tomorrow'
          : 'in $effectiveDays days';
      await _scheduleZoned(
        id: item.id! * 10,
        title: 'Amma, use it soon!',
        body: '${item.name} expires $daysText. Time to plan a dish with it!',
        scheduledDate: _atMorningTZ(reminderDate),
      );
    }

    // Always schedule expiry-day notification
    if (item.expiryDate!.isAfter(now)) {
      await _scheduleZoned(
        id: item.id! * 10 + 1,
        title: 'Expires today!',
        body: '${item.name} expires today. Check if it\'s still good to use.',
        scheduledDate: _atMorningTZ(item.expiryDate!),
      );
    }
  }

  /// Cancel all notifications for an item
  Future<void> cancelNotification(int itemId) async {
    await _notifications.cancel(itemId * 10);
    await _notifications.cancel(itemId * 10 + 1);
  }

  /// Reschedule ALL active item notifications (call when global default changes)
  Future<void> rescheduleAllNotifications() async {
    try {
      await _notifications.cancelAll();
      final items = await DatabaseService.instance.getActiveItems();
      for (final item in items) {
        if (item.expiryDate != null) {
          await scheduleExpiryNotification(item);
        }
      }
      debugPrint('Rescheduled notifications for ${items.length} items');
    } catch (e) {
      debugPrint('Reschedule all failed: $e');
    }
  }

  /// Convert a DateTime to TZDateTime at 8:00 AM
  tz.TZDateTime _atMorningTZ(DateTime date) {
    return tz.TZDateTime(tz.local, date.year, date.month, date.day, 8, 0);
  }

  /// Schedule a notification using zonedSchedule (survives app kill & reboot)
  Future<void> _scheduleZoned({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
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

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('zonedSchedule failed (id=$id): $e');
      // Fallback to Future.delayed for devices that don't support exact alarms
      final delay = scheduledDate.difference(tz.TZDateTime.now(tz.local));
      if (delay.isNegative) return;
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
    await _notifications.show(
        0, title, body, NotificationDetails(android: androidDetails));
  }
}
