import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  // Ensure window can popup even when minimized
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Lab Timer',
      home: TimerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TimerScreen extends StatefulWidget {
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? hourlyTimer;

  @override
  void initState() {
    super.initState();

    // Show welcome popup immediately
    Future.delayed(const Duration(milliseconds: 500), () {
      _showWelcomePopup();
    });

    // Sync the hourly popup to real system time
    _scheduleNextHour();
  }

  // Schedules the popup exactly at 2:00, 3:00, 4:00 etc.
  void _scheduleNextHour() {
    DateTime now = DateTime.now();

    // Next top of the hour
    DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    Duration timeUntilNextHour = nextHour.difference(now);

    // First one-time timer that triggers at the exact hour
    Timer(timeUntilNextHour, () {
      _showHourlyPopup();

      // After hitting first hour, repeat every hour
      hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
        _showHourlyPopup();
      });
    });
  }

  @override
  void dispose() {
    hourlyTimer?.cancel();
    super.dispose();
  }

  Future<void> _showWelcomePopup() async {
    await _bringToFront();

    _showCustomDialog(
      title: "Welcome to the Social Media Lab",
      message: "Your 1-hour booking starts now.",
    );
  }

  Future<void> _showHourlyPopup() async {
    await _bringToFront();

    _showCustomDialog(
      title: "Social Media Lab Reminder",
      message:
          "Thank you for using this Lab.\n\n"
          "If you booked another hour, please ignore this.\n"
          "If not, kindly check if others are waiting to use the Lab.\n\n"
          "Thank you.",
    );
  }

  /// Bring window to the front even if minimized
  Future<void> _bringToFront() async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    await Future.delayed(const Duration(milliseconds: 500));
    await windowManager.setAlwaysOnTop(false);
  }

  /// Universal popup dialog UI
  void _showCustomDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to click OK
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Social Media Lab Timer Running...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showHourlyPopup,
              child: const Text("Test Popup"),
            ),
          ],
        ),
      ),
    );
  }
}
