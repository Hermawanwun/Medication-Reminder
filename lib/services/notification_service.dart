import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  Future<void> jadwalkanNotifikasi({
    required String id,
    required String title,
    required String body,
    required int jam,
    required int menit,
    List<int>? hari,
  }) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, now.day, jam, menit);

    final tzScheduledDate = tz.TZDateTime.from(
      scheduledDate.isBefore(now) ? scheduledDate.add(const Duration(days: 1)) : scheduledDate,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'obat_channel',
      'Pengingat Obat',
      channelDescription: 'Notifikasi pengingat minum obat',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (hari != null && hari.isNotEmpty) {
      await _plugin.periodicallyShow(
        int.parse(id.replaceAll(RegExp(r'[^0-9]'), '')),
        title,
        body,
        RepeatInterval.daily,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _plugin.zonedSchedule(
        int.parse(id.replaceAll(RegExp(r'[^0-9]'), '')),
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelNotifikasi(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelSemua() async {
    await _plugin.cancelAll();
  }
}
