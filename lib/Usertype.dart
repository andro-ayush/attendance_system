import 'package:flutter/material.dart';

class UserType extends StatefulWidget {
  const UserType({super.key});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  @override
  Widget build(BuildContext context)
   {

double ScreenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top:150),
            child: Text(
                "Select User Type",
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold),
                ),
          ),
    
          
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button 1
                  ElevatedButton(onPressed: () { 
                  Navigator.pushNamed(context, '/login',arguments: 'Admin');},
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(ScreenWidth/1.1,50),
                    backgroundColor: Color.fromARGB(255, 242, 255, 227)
                  ),           
                  child: Text("Admin")),
              
                  SizedBox(height: 20,),
              
                  // Button 2
                  ElevatedButton(onPressed: () { 
                    Navigator.pushNamed(context, '/login',arguments: 'Employee');},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(ScreenWidth/1.1,50),
                      backgroundColor: Color.fromARGB(255, 242, 255, 227)
                    ),
                    child: Text("Employee")),
                ],
              ),
            ),
          ),
    
    
          Stack(
      children: [
    // Bottom Circle Blue
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
              color: Color.fromARGB(255, 172, 241, 240),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        );
      },
    ),
    
    // Bottom Circle Orange
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
              color: Color.fromARGB(255, 22, 150, 163),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        );
      },
    ),
      ],
    )
    
        ],
      ),
    );
  }
}







