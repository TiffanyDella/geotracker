import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  Timer? _timer;
  final List<String> _coordinates = [];

  @override
  void initState() {
    super.initState();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin!.show(
      0,
      'Geo Tracker',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _startTracking() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    if (status == LocationPermission.always || status == LocationPermission.whileInUse) {
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        String log = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}, Time: ${DateTime.now()}';
        setState(() {
          _coordinates.add(log);
        });
        _showNotification('New location recorded!');
      });
      _showNotification('Tracking started!');
    } else {
      print('Location permission denied');
    }
  }

  void _stopTracking() {
    _timer?.cancel();
    _showNotification('Tracking stopped!');
  }

  void _clearHistory() {
    setState(() {
      _coordinates.clear();
    });
    _showNotification('History cleared!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geo Tracker')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _startTracking();
                    },
                    child: Text('Start Tracking'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _stopTracking();
                    },
                    child: Text('Stop Tracking'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _clearHistory();
                    },
                    child: Text('Clear History'),
                  ),
                ],
              ),
            ),
          ),
          // ListView для отображения истории координат
          Container(
            height: 200, // Задайте желаемую высоту для списка
            child: ListView.builder(
              itemCount: _coordinates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_coordinates[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
