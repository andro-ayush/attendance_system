import 'dart:io';
import 'package:attendence_system/Usertype.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'database.dart';
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Admin", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        toolbarHeight: 60,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewRecordsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: Size(screenWidth / 1.1, 50),
                  //backgroundColor: Theme.of(context).colorScheme.tertiary,
                  //foregroundColor: Colors.white
                  ),
              child: Text("View Records",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MarkAttendencePage()),
                );
              },
             style: ElevatedButton.styleFrom(
                shadowColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: Size(screenWidth / 1.1, 50),
                  //backgroundColor: Theme.of(context).colorScheme.tertiary,
                  //foregroundColor: Colors.white
                  ),
              child: Text("Mark Attendance",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApproveLeavePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: Size(screenWidth / 1.1, 50),
                  //backgroundColor: Theme.of(context).colorScheme.tertiary,
                  //foregroundColor: Colors.white
                  ),
              child: Text("Approve Leave Requests",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterEmployeePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: Size(screenWidth / 1.1, 50),
                  //backgroundColor: Theme.of(context).colorScheme.tertiary,
                  //foregroundColor: Colors.white
                  ),
              child: Text("Register New Employee",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserType()),
                );
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: Size(screenWidth / 1.1, 50),
                  //backgroundColor: Theme.of(context).colorScheme.tertiary,
                  //foregroundColor: Colors.white
                  ),
              child: Text("Log out",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
          ],
        ),
      ),
    );
  }
}

//Class of register employee

class RegisterEmployeePage extends StatefulWidget {
  @override
  _RegisterEmployeePageState createState() => _RegisterEmployeePageState();
}

class _RegisterEmployeePageState extends State<RegisterEmployeePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _eidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _faceImage;
  List<double>? _faceEmbedding;
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

 Future<void> _loadModel() async {
  try {
    _interpreter = await Interpreter.fromAsset("assets/models/facenet.tflite");
    print("Model loaded successfully");
  } catch (e) {
    print("Failed to load model: $e");
  }
}

  Future<void> _captureFace() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _faceImage = imageFile;
      });

      _faceEmbedding = await _getFaceEmbedding(imageFile);

      if (_faceEmbedding == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Face recognition failed. Try again.")),
        );
      }
    }
  }

Future<List<double>?> _getFaceEmbedding(File image) async {
  final rawImage = img.decodeImage(await image.readAsBytes());
  if (rawImage == null) return null;

  final inputImage = img.copyResize(rawImage, width: 160, height: 160);
  final inputBuffer = List.generate(1, (i) => List.generate(160, (j) => 
    List.generate(160, (k) => List.generate(3, (l) => 0.0))));

  for (int y = 0; y < 160; y++) {
    for (int x = 0; x < 160; x++) {
      final pixel = inputImage.getPixel(x, y);
      inputBuffer[0][y][x][0] = pixel.r / 255.0;
      inputBuffer[0][y][x][1] = pixel.g / 255.0;
      inputBuffer[0][y][x][2] = pixel.b / 255.0;
    }
  }

  final outputBuffer = List.generate(1, (i) => List.filled(512, 0.0));

  // if (_interpreter == null) {
  //   print("Error: Interpreter not initialized!");
  //   return null;
  // }

  _interpreter.run(inputBuffer, outputBuffer);
  return outputBuffer[0]; // Returns a 512-dimensional embedding
}

  void _registerEmployee() async {
    if (_nameController.text.isNotEmpty && _eidController.text.isNotEmpty && _faceEmbedding != null) {
      await DatabaseHelper().insertEmployee({
        'name': _nameController.text.trim(),
        'eid': _eidController.text.trim(),
        'password': _passwordController.text.trim(),
        'attendance': 'Absent',
        'punchIn': '-',
        'faceData': _faceEmbedding!.join(','), // Store as a CSV string
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Employee Registered Successfully")),
      );

      _nameController.clear();
      _eidController.clear();
      _passwordController.clear();
      setState(() {
        _faceImage = null;
        _faceEmbedding = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and capture face")),
      );
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Register New Employee", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        toolbarHeight: 60,
      ),
      body: Column(
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: "Employee Name")),
          TextField(controller: _eidController, decoration: InputDecoration(labelText: "Employee ID")),
          TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password")),
          ElevatedButton(onPressed: _captureFace, child: Text("Capture Face",style: TextStyle(color: Theme.of(context).colorScheme.secondary),)),
          _faceImage != null ? Image.file(_faceImage!, height: 100) : Container(),
          ElevatedButton(onPressed: _registerEmployee, child: Text("Register",style: TextStyle(color: Theme.of(context).colorScheme.secondary),)),
        ],
      ),
    );
  }
}



//Class of Mark Attendence

class MarkAttendencePage extends StatefulWidget {
  @override
  _MarkAttendencePageState createState() => _MarkAttendencePageState();
}

class _MarkAttendencePageState extends State<MarkAttendencePage> {
  final TextEditingController _eidController = TextEditingController();
  String? _attendanceStatus;

void _markAttendance() async {
  final String eid = _eidController.text.trim();
  if (eid.isNotEmpty && _attendanceStatus != null) {
    // Update attendance in the database
    final dbHelper = DatabaseHelper();
    await dbHelper.updateEmployeeByEID(eid, {'attendance': _attendanceStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Marked $_attendanceStatus for EID: $eid")),
    );
    _eidController.clear();
    setState(() {
      _attendanceStatus = null;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter EID and select status")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Mark Attendance", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        toolbarHeight: 60,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eidController,
              decoration: const InputDecoration(labelText: "Employee ID"),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _attendanceStatus,
              hint: const Text("Select Status"),
              items: ["Present", "Absent"].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _attendanceStatus = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _markAttendance,
              child: Text("Mark Attendance",style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
          ],
        ),
      ),
    );
  }
}




//Class of ApproveLeavePage

class ApproveLeavePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Approve Leave Requests", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        toolbarHeight: 60,
      ),
      body: const Center(child: Text("Here you can approve leave requests")),
    );
  }
}



//Class of Viewrecordspage

class ViewRecordsPage extends StatefulWidget {
  @override
  _ViewRecordsPageState createState() => _ViewRecordsPageState();
}

class _ViewRecordsPageState extends State<ViewRecordsPage> {
  List<Map<String, dynamic>> employees = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final data = await dbHelper.getEmployees();
    setState(() {
      employees = data;
    });
  }

  void _deleteEmployee(int id) async {
    await dbHelper.deleteEmployee(id);
    _fetchEmployees();
  }

  void _editEmployee(int index) async {
    String currentStatus = employees[index]['attendance'];
    String? newStatus = currentStatus;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Attendance Status"),
        content: DropdownButton<String>(
          value: newStatus,
          items: ["Present", "Absent"].map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              newStatus = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (newStatus != null && newStatus != currentStatus) {
                await dbHelper.updateEmployee(
                  employees[index]['id'],
                  {'attendance': newStatus},
                );
                _fetchEmployees();
              }
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("View Records", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        toolbarHeight: 60,
      ),
      body: employees.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  child: ListTile(
                    title: Text("${employee['name']} (EID: ${employee['eid']})"),
                    subtitle: Text("Status: ${employee['attendance']} | Time: ${employee['punchIn'] ?? '-'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editEmployee(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEmployee(employee['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
