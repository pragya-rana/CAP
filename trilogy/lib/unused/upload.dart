import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/material.dart.';
//import io

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> uploadPdf(String fileName, File file) async {
    final reference = FirebaseStorage.instance
        .ref()
        .child("applications/" + fileName + ".pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadURL = await reference.getDownloadURL();

    return downloadURL;
  }

  Future<String?> pickFile() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["pdf", "docx"]);

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;

      File file = File(pickedFile.files[0].path!);

      final downloadUrl = await uploadPdf(fileName, file);

      //debug
      print("pdf do be pdfing: " + downloadUrl);

      await FirebaseFirestore.instance
          .collection('listings')
          .doc('u0jbBncYGCj1pR36sWJn')
          .collection('applications')
          .doc('ishita_mundra')
          .update({'applicationRef': downloadUrl});
      //store this through the set in the add event or listings page
      return downloadUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FloatingActionButton(
          child: const Icon(Icons.upload),
          onPressed: () async {
            pickFile();
            // Navigator.pop(context);
          }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
