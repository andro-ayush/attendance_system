import 'dart:io';
import 'package:attendence_system/Admin.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; 
import 'package:image/image.dart' as img;



class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {

  String? employeeEid;

  @override
  void initState() {
    super.initState();
    _loadEmployeeEid();
  }

  // Load the employee's eid from SharedPreferences
  Future<void> _loadEmployeeEid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeEid = prefs.getString('eid');
    });
  }

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Employee", style: TextStyle(color: Colors.white)),
          toolbarHeight: 60,
          backgroundColor: Color.fromARGB(255, 22, 150, 163),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MarkAttendancePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(ScreenWidth / 1.1, 50),
                    backgroundColor: Color.fromARGB(255, 242, 255, 227),
                    foregroundColor: Colors.black),
                child: Text("Mark Attendance"),
              ),
              SizedBox(height: 20),

              // View Records button with eid passed to the next page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewRecordsPage(eid: employeeEid ?? ''),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(ScreenWidth / 1.1, 50),
                    backgroundColor: Color.fromARGB(255, 242, 255, 227),
                    foregroundColor: Colors.black),
                child: Text("View Records"),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaveRequestPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(ScreenWidth / 1.1, 50),
                    backgroundColor: Color.fromARGB(255, 242, 255, 227),
                    foregroundColor: Colors.black),
                child: Text("Leave Request"),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


//Class of ViewrecordPage 

class ViewRecordsPage extends StatefulWidget {
  final String eid;

  // Constructor to accept eid
  const ViewRecordsPage({super.key, required this.eid});

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

  // Fetch records where eid matches
  Future<void> _fetchEmployees() async {
    final data = await dbHelper.getEmployeesByEid(widget.eid);  // Use the passed eid
    setState(() {
      employees = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Records", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 22, 150, 163),
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
                  ),
                );
              },
            ),
    );
  }
}



// Class of MarkAttendencepage
class MarkAttendancePage extends StatefulWidget {
  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  File? _faceImage;
  List<double>? _capturedEmbedding;
  String _message = "";
  Interpreter? _interpreter;

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

Future<void> _captureAndRecognizeFace() async {
  if (_interpreter == null) {
    print("Error: Model is still loading.");
    setState(() {
      _message = "Model is still loading. Please wait...";
    });
    return;
  }

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    setState(() {
      _faceImage = imageFile;
    });

    _capturedEmbedding = await _getFaceEmbedding(imageFile);

    if (_capturedEmbedding == null || _capturedEmbedding!.isEmpty) {
      setState(() {
        _message = "No face detected. Please try again.";
      });
      return; // Exit early to prevent app from getting stuck
    }

    await _verifyFace();
  }
}


Future<List<double>?> _getFaceEmbedding(File image) async {
  if (_interpreter == null) {
    print("Error: Model not loaded yet.");
    return null;
  }

  // Load image
  final rawImage = img.decodeImage(await image.readAsBytes());
  if (rawImage == null) {
    print("Error: Could not decode image.");
    return null;
  }

  // Resize image to (160x160)
  final inputImage = img.copyResize(rawImage, width: 160, height: 160);

  // Convert image to a 4D input tensor [1, 160, 160, 3]
  List<List<List<List<double>>>> inputTensor = [
    List.generate(160, (y) => 
      List.generate(160, (x) {
        final pixel = inputImage.getPixel(x, y);
        return [(pixel.r / 255.0), (pixel.g / 255.0), (pixel.b / 255.0)];
      })
    )
  ];

  // Output buffer (512D Face Embedding)
  final outputBuffer = List.generate(1, (i) => List.filled(512, 0.0));

  try {
    _interpreter!.run(inputTensor, outputBuffer);
  } catch (e) {
    print("Error running model: $e");
    return null;
  }

  return outputBuffer[0];  // Return the 512D embedding
}


Future<void> _verifyFace() async {
  if (_capturedEmbedding == null || _capturedEmbedding!.isEmpty) {
    setState(() {
      _message = "No face detected. Please try again.";
    });
    return;
  }

  List<Map<String, dynamic>> employees = await DatabaseHelper().getEmployees();

  bool isMatchFound = false;

  for (var employee in employees) {
    String rawData = employee['facedata'];
    print("Employee: ${employee['name']}");
    print("Raw Stored Embedding: $rawData");

    if (!rawData.contains(',')) {
      print("Error: Invalid stored embedding format!");
      continue; // Skip invalid data
    }

    List<double> storedEmbedding = rawData.split(',')
        .map((e) => double.tryParse(e) ?? 0.0)
        .toList();

    print("Parsed Embedding: $storedEmbedding");

    if (storedEmbedding.length != _capturedEmbedding!.length) {
      print("Error: Embedding length mismatch!");
      continue; // Skip mismatched embeddings
    }

    double distance = _calculateEuclideanDistance(_capturedEmbedding!, storedEmbedding);
    print("Distance: $distance");

    if (distance < 0.8) {  // Threshold for matching
      await DatabaseHelper().markAttendance(employee['eid']);
      setState(() {
        _message = "Attendance marked for ${employee['name']}";
      });
      isMatchFound = true;
      return;
    }
  }

  if (!isMatchFound) {
    setState(() {
      _message = "No match found!";
    });
  }
}

  double _calculateEuclideanDistance(List<double> a, List<double> b) {
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return sqrt(sum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance")),
      body: Column(
        children: [
          ElevatedButton(onPressed: _captureAndRecognizeFace, child: Text("Scan Face")),
          _faceImage != null ? Image.file(_faceImage!, height: 100) : Container(),
          Text(_message),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interpreter?.close(); // Safely close if initialized
    super.dispose();
  }
}




// Class of LeaveRequestPage

class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Leave Request", style: TextStyle(color: Colors.white)),
          toolbarHeight: 60,
          backgroundColor: Color.fromARGB(255, 22, 150, 163),
        ),
      ),
    );
  }
}
