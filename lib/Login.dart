import 'package:attendence_system/Admin.dart';
import 'package:attendence_system/Employee.dart';
import 'package:attendence_system/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final TextEditingController _usernamecontroller = TextEditingController();
final TextEditingController _passwordcontroller = TextEditingController();

String admin_username = "admin";
String admin_password = "admin";



// Save login data to SharedPreferences
Future<void> _saveLogin(String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('role', role);

  _usernamecontroller.clear();
  _passwordcontroller.clear();
}

// Save employee login with eid to SharedPreferences
Future<void> _saveEmployeeLogin(String eid, String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('role', role);
  await prefs.setString('eid', eid); 
  
 // Save the employee ID (eid)
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 150),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      // Username Field
                      Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width / 1.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 242, 255, 227),
                        ),
                        child: TextFormField(
                          controller: _usernamecontroller,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 20, top: 10),
                            hintText: "Username",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Password Field
                      Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width / 1.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 242, 255, 227),
                        ),
                        child: TextFormField(
                          obscureText: true,
                          controller: _passwordcontroller,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 10, left: 20),
                            hintText: "Password",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Eid Field (for employee to enter their ID)
                      
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.role == 'Admin' &&
                              _usernamecontroller.text == admin_username &&
                              _passwordcontroller.text == admin_password) {
                            await _saveLogin('Admin');
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => AdminPage()),
                                (route) => false);
                          } else if (widget.role == 'Employee') {
                            bool isValid = await DatabaseHelper().validateEmployee(
                                _usernamecontroller.text, _passwordcontroller.text);
                            if (isValid) {
  String eid = _usernamecontroller.text; // Get EID from the text field
  await _saveEmployeeLogin(eid, 'Employee') // Save the EID
      .then((_) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeePage(), // No need to pass eid explicitly
      ),
      (route) => false,
    );
  }).catchError((error) {
    // Handle error here
    print("Error saving EID: $error");
  });
}
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 22, 150, 163),
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Login"),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: Stack(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 450),
                          duration: Duration(seconds: 1),
                          curve: Curves.easeIn,
                          builder: (context, size, child) {
                            return Positioned(
                              bottom: -size / 3,
                              left: (ScreenWidth - size) / 2,
                              child: Container(
                                height: size,
                                width: size,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 34, 84, 121),
                                  borderRadius: BorderRadius.circular(size / 2),
                                ),
                              ),
                            );
                          },
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 350),
                          duration: Duration(seconds: 1),
                          curve: Curves.easeIn,
                          builder: (context, size, child) {
                            return Positioned(
                              bottom: -size / 2.5,
                              left: (ScreenWidth - size) / 2,
                              child: Container(
                                height: size,
                                width: size,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 140, 0),
                                  borderRadius: BorderRadius.circular(size / 2),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
