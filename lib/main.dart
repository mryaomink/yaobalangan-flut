import 'package:flutter/material.dart';
import 'package:ihsan_balangan/auth/yao_login.dart';
import 'package:ihsan_balangan/auth/yao_register.dart';
import 'package:ihsan_balangan/screens/yao_attendance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ihsan Absensi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final token = snapshot.data!.getString('yaotoken');
            if (token != null) {
              return const YaoAttendance();
            }
          }
          return const YaoLogin();
        },
      ),
      routes: {
        '/login': (context) => const YaoLogin(),
        '/absen': (context) => const YaoAttendance(),
        '/register': (context) => const YaoRegister(),
      },
    );
  }
}
