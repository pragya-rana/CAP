import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:trilogy/classes/applicant.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trilogy/all/pdf_viewer.dart';

// This class is a widget that allows the business to a view the applicants of a listing.
class BusinessViewApplications extends StatefulWidget {
  const BusinessViewApplications(
      {super.key, required this.listingRef, required this.listingTitle});

  final String listingRef;
  final String listingTitle;

  @override
  State<BusinessViewApplications> createState() =>
      _BusinessViewApplicationsState();
}

class _BusinessViewApplicationsState extends State<BusinessViewApplications> {
  // This builds the actual layout of the page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18, top: 10),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applications For ' + widget.listingTitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Applicants',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('listings')
                          .doc(widget.listingRef)
                          .collection('applications')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Text('No applications found');
                        } else {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              String name = snapshot.data?.docs[index]
                                  ['applicantName'] as String;
                              String dateSubmitted = DateFormat('MMM d, yyyy')
                                  .format(snapshot
                                      .data?.docs[index]['dateApplied']
                                      .toDate());
                              String timeSubmitted = DateFormat('h:mm a')
                                  .format(snapshot
                                      .data?.docs[index]['dateApplied']
                                      .toDate());
                              String grade =
                                  snapshot.data?.docs[index]['grade'] as String;
                              String status = snapshot.data?.docs[index]
                                  ['status'] as String;
                              String applicationRef = snapshot.data?.docs[index]
                                  ['applicationRef'] as String;
                              String resumeRef = snapshot.data?.docs[index]
                                  ['resumeRef'] as String;
                              String applicantRef = 'listings/' +
                                  widget.listingRef +
                                  '/applications/' +
                                  (snapshot.data?.docs[index].id as String);
                              String applicantEmail = snapshot.data?.docs[index]
                                  ['applicantEmail'] as String;
                              return buildApplicantCard(Applicant(
                                  name,
                                  dateSubmitted,
                                  timeSubmitted,
                                  grade,
                                  status,
                                  applicantRef,
                                  applicationRef,
                                  resumeRef,
                                  applicantEmail));
                            },
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Each applicant has a card build for them. The card provides lots of information for the partner
  // to reject or accept the applicant.
  Widget buildApplicantCard(Applicant applicant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: Offset(1, 1))
            ]),
        child: ExpansionTile(
          shape: Border(),
          title: Padding(
            padding: EdgeInsets.all(2),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          applicant.name,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          applicant.grade,
                          style: TextStyle(
                            color: Color(0xff8FD694),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      applicant.dateSubmitted + ' | ' + applicant.timeSubmitted,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                Spacer(),
                Text(
                  applicant.status,
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                )
              ],
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.black.withOpacity(0.6),
            size: 16,
          ),
          children: [
            ListTile(
              title: Text(
                'View Application:',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              subtitle: Row(
                children: [
                  TextButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return PDFViewer(
                                pdfUrl: applicant.resumeRef,
                                title: applicant.name + ' Resume');
                          },
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff2C003F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Resume',
                                style: TextStyle(color: Color(0xff2C003F)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.download,
                                color: Color(0xff2C003F),
                              )
                            ],
                          ),
                        ),
                      )),
                  TextButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return PDFViewer(
                                pdfUrl: applicant.applicationRef,
                                title: applicant.name + ' Application');
                          },
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff2C003F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Application',
                                style: TextStyle(color: Color(0xff2C003F)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.download,
                                color: Color(0xff2C003F),
                              )
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            applicant.status == 'Undecided'
                ? ListTile(
                    title: Text('Make a Decision:',
                        style: TextStyle(color: Colors.black87, fontSize: 14)),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xff8FD694).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // Updates Firebase Firestore when descision has been made.
                            // Also sends email to the applicant when accepted.
                            child: TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('listings')
                                      .doc(applicant.applicantRef.split('/')[1])
                                      .collection('applications')
                                      .doc(applicant.applicantRef.split('/')[3])
                                      .update({'status': 'Accepted'});
                                  sendEmail(
                                      applicant.applicantEmail,
                                      widget.listingTitle,
                                      'Congratulations! You have been acceped for the following position: ' +
                                          widget.listingTitle +
                                          '. We will be sending more information soon.');
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Color(0xff8FD694),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Accept',
                                      style: TextStyle(
                                          color: Color(0xff8FD694),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('listings')
                                      .doc(applicant.applicantRef.split('/')[1])
                                      .collection('applications')
                                      .doc(applicant.applicantRef.split('/')[3])
                                      .update({'status': 'Rejected'});

                                  sendEmail(
                                      applicant.applicantEmail,
                                      widget.listingTitle,
                                      'Unfortunately, you have been rejected for the following position ' +
                                          widget.listingTitle);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Reject',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                  )
                : ListTile(
                    title: Text(
                      'Contact Applicant',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    subtitle: TextButton(
                      onPressed: () {
                        sendEmail(applicant.applicantEmail, '', '');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff8FD694).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Contact Here',
                                style: TextStyle(
                                    color: Color(0xff8FD694),
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.message,
                                color: Color(0xff8FD694),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  // An preformatted email is drafted to the student whose application was accepted.
  sendEmail(String recipientEmail, String subject, String body) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [recipientEmail],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  // The partner has the ability to download a pdf of the students' applications and resumes.
  Future<void> downloadPdf(String downloadUrl, bool isApplication) async {
    final Dio dio = Dio();
    print('in here?');

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String filePath =
          '$appDocPath/' + (isApplication ? 'application.pdf' : 'resume.pdf');
      print('does this work ' + downloadUrl);

      await dio.download(downloadUrl, filePath,
          onReceiveProgress: (received, total) {});

      await Share.shareFiles([filePath]);
    } catch (e) {
      print('Error sharing file: $e');
    }
  }
}
