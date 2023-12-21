import 'package:flutter/material.dart';
import 'package:trilogy/admin_approvals.dart';
import 'package:trilogy/admin_find_partnerships.dart';
import 'package:trilogy/admin_partner_info.dart';
import 'package:trilogy/admin_settings.dart';

// rishitha, ishita, testing testing
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AdminSettings());
  }
}
