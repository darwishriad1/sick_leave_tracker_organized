import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/leave_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Ensure that the Flutter binding is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SickLeaveTrackerApp());
}

class SickLeaveTrackerApp extends StatelessWidget {
  const SickLeaveTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LeaveProvider(),
      child: MaterialApp(
        title: 'Sick Leave Tracker',
        // Set the application to use Arabic language and RTL direction
        locale: const Locale('ar', 'AE'),
        supportedLocales: const [
          Locale('ar', 'AE'), // Arabic
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // Set text direction to RTL for the entire app
          fontFamily: 'Arial', // You might want to use a font that supports Arabic well
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
