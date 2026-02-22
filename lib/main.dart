import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:ammas_kitchen/providers/inventory_provider.dart';
import 'package:ammas_kitchen/screens/home_screen.dart';
import 'package:ammas_kitchen/services/database_service.dart';
import 'package:ammas_kitchen/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for scheduled notifications
  tz.initializeTimeZones();
  try {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tzlib.setLocalLocation(tzlib.getLocation(timeZoneName));
  } catch (_) {
    tzlib.setLocalLocation(tzlib.getLocation('Asia/Kolkata'));
  }

  await DatabaseService.instance.database;
  await NotificationService.instance.init();
  runApp(const AmmasKitchenApp());
}

class AmmasKitchenApp extends StatelessWidget {
  const AmmasKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider()..loadItems(),
      child: MaterialApp(
        title: "Amma's Kitchen",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
