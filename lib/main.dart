import 'package:attendence_system/Admin.dart';
import 'package:attendence_system/Employee.dart';
import 'package:attendence_system/Login.dart';
import 'package:attendence_system/Usertype.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getString('role');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: isLoggedIn ? (role == 'Admin' ? '/admin' : '/employee') : '/',
    routes: {
      '/': (context) => UserType(), // Or a role selector
      '/login': (context) => LoginPage(role: ModalRoute.of(context)!.settings.arguments as String),
      '/admin': (context) => AdminPage(),
      '/employee': (context) => EmployeePage(),
    },
  ));
}

