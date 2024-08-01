import 'package:alarmtest/notification_service.dart';
import 'package:alarmtest/second_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  tz.timeZoneDatabase;
  // android_alarm_manager
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Local Notifications'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final player = AudioPlayer();

  @override
  void initState() {
    NotificationService.init(initScheduled: true);
    listenNotification();
    player.onPlayerComplete.listen((event) {
      player.seek(const Duration(seconds: 0));
      player.resume();
    });
    super.initState();
  }

  void listenNotification() =>
      NotificationService.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SecondPage(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    player.setSource(AssetSource('audio/alarm.wav'));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                player.resume();
                NotificationService.showNotification(
                  id: 0,
                  title: "Fazr",
                  body: "Wake up for Fazr",
                  payload: "Fazr.abs",
                );
              },
              child: const Text(
                'Simple Notification',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                NotificationService.showScheduledNotification(
                  id: 0,
                  title: "Fazr",
                  body: "Wake up for Fazr",
                  scheduledDate: DateTime.now().add(
                    const Duration(seconds: 5),
                  ),
                  payload: "Fazr.abs",
                );

                const snackBar = SnackBar(
                  content: Text(
                    "Alarm Scheduled in 5 seconds",
                    style: TextStyle(fontSize: 24),
                  ),
                );

                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
              child: const Text(
                'Scheduled Notification',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await AndroidAlarmManager.oneShot(
                  const Duration(seconds: 5),
                  0,
                  showAlarm,
                );
              },
              child: const Text(
                'Stop Alarm',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showAlarm() {
    print("Alarm");
    NotificationService.showNotification(
      id: 0,
      title: "Fazr",
      body: "Wake up for Fazr",
      payload: "Fazr.abs",
    );
  }
}
