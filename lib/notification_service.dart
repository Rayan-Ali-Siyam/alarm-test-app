import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String>();

  static NotificationDetails _notificationDetails() {
    // final largeIconPath =
    // final styleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigpic), largeIcon: FilePathAndroidBitmap(largeIcon));
    const sound = "alarm.wav";
    return NotificationDetails(
      android: AndroidNotificationDetails(
        "channel id false",
        "channel Hello",
        channelDescription: "channel description",
        priority: Priority.max,
        importance: Importance.max,
        playSound: false,
        ongoing: true,
        additionalFlags: Int32List.fromList(<int>[2]),
        sound: RawResourceAndroidNotificationSound(sound.split(".").first),
        fullScreenIntent: true,
        // styleInformation: styleInformation,
      ),
      iOS: const IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iOS = IOSInitializationSettings();
    const initializationSettings =
        InitializationSettings(android: android, iOS: iOS);

    // When app is Closed!
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.payload!);
    }

    await _notifications.initialize(initializationSettings,
        onSelectNotification: (payload) {
      onNotifications.add(payload!);
    });

    if (initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        _notificationDetails(),
        payload: payload,
      );

  static Future<void> showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    tz.TZDateTime tzDateTime = tz.TZDateTime.from(scheduledDate, tz.UTC);
    _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      // _scheduleDaily(const Time(8)),
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.UTC);
    final scheduleDate = tz.TZDateTime(
      tz.UTC,
      now.year,
      now.month,
      now.day,
    );

    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }

  static tz.TZDateTime _scheduleWeeklyMethod(Time time,
      {required List<int> days}) {
    tz.TZDateTime scheduleDate = _scheduleDaily(time);

    while (!days.contains(scheduleDate.weekday)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  static void cancel(int id) => _notifications.cancel(id);

  static void cancelAll() => _notifications.cancelAll();
}
