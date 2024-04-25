import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trilogy/classes/icon_field.dart';
import 'package:trilogy/classes/icon_type.dart';
import 'package:trilogy/classes/listing.dart';
import 'package:trilogy/classes/partner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trilogy/all/pdf_viewer.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// This class is a widget that allows the user to submit their application for a particular listing.
class StudentSubmitApp extends StatefulWidget {
  final Listing listing;
  final GoogleSignInAccount user;
  const StudentSubmitApp({Key? key, required this.listing, required this.user})
      : super(key: key);

  @override
  State<StudentSubmitApp> createState() => _AdminPartnerInfoState();
}

class _AdminPartnerInfoState extends State<StudentSubmitApp> {
  String coverUrl = '';
  String businessApplicationUrl = '';
  String userApplicationUrl = '';
  String userResumeUrl = '';
  bool isUserApplicationPdfUploading = false;
  bool isUserResumePdfUploading = false;
  String grade = '';

  @override
  void initState() {
    getBusinessPdf();
    super.initState();
  }

  // Uses Firestore to get the grade of the user.
  Future<void> findApplicantGrade() async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.user.displayName!.split(' ').join('_').toLowerCase())
        .get();
    if (userSnapshot.exists) {
      setState(() {
        grade = userSnapshot.data()!['grade'];
      });
    }
  }

  // Gets the application pdf from Firebase Firestore.
  Future<void> getBusinessPdf() async {
    try {
      var applicationSnapshot = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.refName)
          .get();

      if (applicationSnapshot.exists) {
        setState(() {
          businessApplicationUrl =
              applicationSnapshot.data()!['applicationRef'];
        });
      } else {
        print('Snapshot does not exist.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Allows the user to upload their resume via the files on their device.
  Future<String> uploadResumePdf(String fileName, File file) async {
    final reference = FirebaseStorage.instance.ref().child("user_resume/" +
        widget.user.displayName!.split(' ').join('_').toLowerCase() +
        '/' +
        widget.listing.refName +
        '/' +
        fileName +
        ".pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadURL = await reference.getDownloadURL();

    return downloadURL;
  }

  // Allows the user to pick their file from the files on their device.
  Future<String?> pickResumeFile() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["pdf", "docx"]);

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;

      File file = File(pickedFile.files[0].path!);

      final downloadUrl = await uploadResumePdf(fileName, file);

      setState(() {
        userResumeUrl = downloadUrl;
        isUserResumePdfUploading = false;
      });
      print("pdf do be pdfing: " + downloadUrl);
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.refName)
          .collection('applications')
          .doc(widget.user.displayName!.split(' ').join('_').toLowerCase())
          .set({'resumeRef': downloadUrl}, SetOptions(merge: true));
      return downloadUrl;
    }
  }

  // Allows the user to pick their application file from the files on their device.
  Future<String?> pickApplicationFile() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["pdf", "docx"]);

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;

      File file = File(pickedFile.files[0].path!);

      final downloadUrl = await uploadApplicationPdf(fileName, file);

      setState(() {
        userApplicationUrl = downloadUrl;
        isUserApplicationPdfUploading = false;
      });
      print("pdf do be pdfing: " + downloadUrl);
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.refName)
          .collection('applications')
          .doc(widget.user.displayName!.split(' ').join('_').toLowerCase())
          .set({'applicationRef': downloadUrl}, SetOptions(merge: true));
      //store this through the set in the add event or listings page
      return downloadUrl;
    }
  }

  // The user's application is added to Firebase Storage.
  Future<String> uploadApplicationPdf(String fileName, File file) async {
    final reference = FirebaseStorage.instance.ref().child(
        "user_applications/" +
            widget.user.displayName!.split(' ').join('_').toLowerCase() +
            '/' +
            widget.listing.refName +
            '/' +
            fileName +
            ".pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadURL = await reference.getDownloadURL();

    return downloadURL;
  }

  // The pdfs can be downloaded once they have been uploaded.
  Future<void> downloadPdf(String downloadUrl) async {
    final Dio dio = Dio();
    print('in here?');

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String filePath = '$appDocPath/application.pdf';
      print('does this work ' + downloadUrl);

      await dio.download(downloadUrl, filePath,
          onReceiveProgress: (received, total) {});

      await Share.shareFiles([filePath]);
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  // This displays the actual layout of the submission page for the listing.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF8FDFF),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.listing.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Icon(Icons.business),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.listing.name,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.listing.location,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(Icons.business_center),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.listing.type,
                            style: TextStyle(color: Colors.black87),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(Icons.school),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.listing.gradeLevel,
                            style: TextStyle(color: Colors.black87),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_month),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Apply by ' +
                                DateFormat('MMMM dd, yyyy')
                                    .format(widget.listing.deadline),
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                          onTap: () async {
                            if (businessApplicationUrl.isNotEmpty) {
                              await getBusinessPdf();
                              // downloadPdf(businessApplicationUrl);
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return PDFViewer(
                                      pdfUrl: businessApplicationUrl,
                                      title: widget.listing.title +
                                          ' Application');
                                },
                              ));
                            } else {
                              // Handle case when URL is not available yet
                              // For example, display a message or disable the button
                              print('Could not download PDF');
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xff8FD694),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Download Application To Apply',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Title: ' + widget.listing.title,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        widget.listing.description,
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      isUserApplicationPdfUploading
                          ? CircularProgressIndicator(
                              color: Colors.grey,
                            )
                          : userApplicationUrl == ''
                              ? GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      isUserApplicationPdfUploading = true;
                                      pickApplicationFile();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 40,
                                              offset: Offset(1, 1))
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
                                          child: Row(
                                            children: [
                                              Text(
                                                'Upload Your Application',
                                                style: TextStyle(
                                                    color: Color(0xff8FD694),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.upload,
                                                color: Color(0xff8FD694),
                                              )
                                            ],
                                          )),
                                    ),
                                  ))
                              : GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      // downloadPdf(userApplicationUrl);
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return PDFViewer(
                                            pdfUrl: userApplicationUrl,
                                            title: 'Your Application',
                                          );
                                        },
                                      ));
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 40,
                                              offset: Offset(1, 1))
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.49,
                                          child: Row(
                                            children: [
                                              Text(
                                                'View Your Application',
                                                style: TextStyle(
                                                    color: Color(0xff8FD694),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.download,
                                                color: Color(0xff8FD694),
                                              )
                                            ],
                                          )),
                                    ),
                                  )),
                      SizedBox(
                        height: 10,
                      ),
                      isUserResumePdfUploading
                          ? CircularProgressIndicator(
                              color: Colors.grey,
                            )
                          : userResumeUrl == ''
                              ? GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      isUserResumePdfUploading = true;
                                    });
                                    pickResumeFile();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 40,
                                              offset: Offset(1, 1))
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.49,
                                          child: Row(
                                            children: [
                                              Text(
                                                'Upload Your Resume',
                                                style: TextStyle(
                                                    color: Color(0xff8FD694),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.upload,
                                                color: Color(0xff8FD694),
                                              )
                                            ],
                                          )),
                                    ),
                                  ))
                              : GestureDetector(
                                  onTap: () async {
                                    // downloadPdf(userResumeUrl);
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return PDFViewer(
                                          pdfUrl: userResumeUrl,
                                          title: 'Your Resume',
                                        );
                                      },
                                    ));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 40,
                                              offset: Offset(1, 1))
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
                                          child: Row(
                                            children: [
                                              Text(
                                                'View Your Resume',
                                                style: TextStyle(
                                                    color: Color(0xff8FD694),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.download,
                                                color: Color(0xff8FD694),
                                              )
                                            ],
                                          )),
                                    ),
                                  )),
                      SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                          onTap: () async {
                            await findApplicantGrade();
                            await FirebaseFirestore.instance
                                .collection('listings')
                                .doc(widget.listing.refName)
                                .collection('applications')
                                .doc(widget.user.displayName!
                                    .split(' ')
                                    .join('_')
                                    .toLowerCase())
                                .set({
                              'applicantEmail': widget.user.email,
                              'applicantName': widget.user.displayName,
                              'dateApplied': DateTime.now(),
                              'grade': grade,
                              'status': 'Undecided'
                            }, SetOptions(merge: true));
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                      'Congratulations on submitting your application!'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Yay!'))
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xff2C003F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )))
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
