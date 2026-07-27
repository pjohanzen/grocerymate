import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/grocery_list.dart';
import 'local_storage_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  final String? actionId = notificationResponse.actionId;

  if (payload != null && actionId != null) {
    WidgetsFlutterBinding.ensureInitialized();
    await LocalStorageService.init();
    await NotificationService._initInternal(requestPermissions: false);
    final list = LocalStorageService.getList(payload);
    if (list != null) {
      DateTime snoozeTime;
      if (actionId == 'snooze_15m') {
        snoozeTime = DateTime.now().add(const Duration(minutes: 15));
      } else if (actionId == 'snooze_1h') {
        snoozeTime = DateTime.now().add(const Duration(hours: 1));
      } else if (actionId == 'snooze_tomorrow') {
        snoozeTime = DateTime.now().add(const Duration(days: 1));
      } else {
        return;
      }

      final updated = list.copyWith(
        reminderEnabled: true,
        reminderDateTime: snoozeTime,
      );
      await LocalStorageService.saveList(updated);
      await NotificationService.scheduleReminder(updated);
    }
  }
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _initInternal(requestPermissions: true);
  }

  static Future<void> _initInternal({required bool requestPermissions}) async {
    tz.initializeTimeZones();
    try {
      final dynamic timezone = await FlutterTimezone.getLocalTimezone();
      final String tzName = timezone is String ? timezone : (timezone.identifier as String);
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fallback if timezone couldn't be loaded
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        final payload = notificationResponse.payload;
        final actionId = notificationResponse.actionId;
        if (payload != null && actionId != null) {
          notificationTapBackground(notificationResponse);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (requestPermissions) {
      // Request permissions on Android 13+
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  static Future<void> scheduleReminder(GroceryList list) async {
    if (!list.reminderEnabled || list.reminderDateTime == null) {
      await cancelReminder(list.id);
      return;
    }

    final scheduledTime = list.reminderDateTime!;
    if (scheduledTime.isBefore(DateTime.now())) {
      // Don't schedule reminders in the past
      return;
    }

    final notificationId = list.id.hashCode;
    final budgetText = list.hasBudget ? '₱${list.budget!.toStringAsFixed(0)}' : 'your';

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: list.name,
      body: 'Your $budgetText grocery list is due now.',
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'grocery_mate_reminders',
          'Reminders',
          channelDescription: 'Reminders for grocery lists',
          importance: Importance.high,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'snooze_15m',
              'Snooze 15m',
              showsUserInterface: false,
            ),
            AndroidNotificationAction(
              'snooze_1h',
              'Snooze 1h',
              showsUserInterface: false,
            ),
            AndroidNotificationAction(
              'snooze_tomorrow',
              'Snooze Tomorrow',
              showsUserInterface: false,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: list.id,
    );
  }

  static Future<void> cancelReminder(String listId) async {
    await _notificationsPlugin.cancel(id: listId.hashCode);
  }
}
