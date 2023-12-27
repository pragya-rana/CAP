import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(UploadResume());
}

class UploadResume extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: UploadResumePage(),
    );
  }
}

class UploadResumePage extends StatefulWidget {
  @override
  _UploadResumePageState createState() => _UploadResumePageState();
}

class _UploadResumePageState extends State<UploadResumePage> {
  String? _resumePath;

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _resumePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Resume'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickResume,
              child: Text('Select Resume (PDF)'),
            ),
            SizedBox(height: 20),
            if (_resumePath != null)
              Text(
                'Resume Path: $_resumePath',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Process uploaded resume and form data
                if (_resumePath != null) {
                  // Process the resume file
                  print('Resume uploaded: $_resumePath');

                  // Fetch other form data
                  // You can get data from TextFormFields here
                } else {
                  // Show an error if no resume is uploaded
                  print('Please upload a resume!');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
