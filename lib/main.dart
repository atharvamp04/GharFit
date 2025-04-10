import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async main
  await Supabase.initialize(
    url: 'https://wxsqztlugugutqxibcoe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind4c3F6dGx1Z3VndXRxeGliY29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyODQxODQsImV4cCI6MjA1OTg2MDE4NH0.EnWMm9H_1yS8AYW53nlOmN0tVXN4uZ2d0EDlhuXYxj0',
  );
  runApp(MyApp());
}

// Define MyApp since it was missing before
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real Estate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}
