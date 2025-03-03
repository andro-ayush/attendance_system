import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:attendence_system/Admin.dart';
import 'package:attendence_system/Employee.dart';
import 'package:attendence_system/Login.dart';
import 'package:attendence_system/Usertype.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getString('role');

  runApp(MyApp(isLoggedIn: isLoggedIn, role: role));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({super.key, required this.isLoggedIn, this.role});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ColorScheme? _lightColorScheme;
  ColorScheme? _darkColorScheme;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        _lightColorScheme = lightDynamic ?? defaultLightColorScheme;
        _darkColorScheme = darkDynamic ?? defaultDarkColorScheme;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: _lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: _darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          initialRoute: getInitialRoute(),
          routes: {
            '/': (context) => const UserType(),
            '/login': (context) {
              final roleArg = ModalRoute.of(context)?.settings.arguments as String?;
              return LoginPage(role: roleArg ?? '');
            },
            '/admin': (context) => const AdminPage(),
            '/employee': (context) => const EmployeePage(),
          },
        );
      },
    );
  }

  String getInitialRoute() {
    if (widget.isLoggedIn) {
      if (widget.role == 'Admin') {
        return '/admin';
      } else if (widget.role == 'Employee') {
        return '/employee';
      }
    }
    return '/';
  }
}

// Default fallback themes (for Android 11 and below)
final ColorScheme defaultLightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
final ColorScheme defaultDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);
