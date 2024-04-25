import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/authentication/google_sign_in_api.dart';
import 'package:trilogy/authentication/log_in.dart';
import 'package:trilogy/student/instructions.dart';
import 'package:trilogy/all/terms_conditions.dart';

// This class is a widget that represents the settings that will be displayed to the user.
class StudentSettings extends StatefulWidget {
  const StudentSettings({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  State<StudentSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<StudentSettings> {
  String firstName = '';
  String lastName = '';
  String pronouns = '';

  // Gets information about the user id from the user's name, so that Firestore can be accessed.
  String getUserId() {
    return widget.user.displayName!.split(' ').join('_').toLowerCase();
  }

  // Gets details about the user from Firestore.
  Future<void> getUserDetails() async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(getUserId())
        .get();
    if (userSnapshot.exists) {
      setState(() {
        firstName = userSnapshot.data()!['firstName'] as String;
        lastName = userSnapshot.data()!['lastName'] as String;
        pronouns = userSnapshot.data()!['pronouns'] as String;
      });
    }
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  // Displays the actual layout of the settings that the user will see.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xff8FD694).withOpacity(0.2),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xff8FD694),
                        child: Text(
                          firstName == ''
                              ? ''
                              : firstName.substring(0, 1) +
                                  lastName.substring(0, 1),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.displayName!,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Student at NCHS',
                          style: TextStyle(color: Color(0xff9E9E9E)),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Account Information',
                  style: TextStyle(
                      color: Color(0xff2C003F),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                displaySettingItem('Display Name', widget.user.displayName!,
                    Icons.person, false, LicensePage()),
                displaySettingItem(
                    'Person', 'Student', Icons.school, false, LicensePage()),
                displaySettingItem(
                    'Pronouns', pronouns, Icons.wc, true, LicensePage()),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Help and Permissions',
                  style: TextStyle(
                      color: Color(0xff2C003F),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                displaySettingItem('View Licensing &\nTerms of Use', '',
                    Icons.article, true, TermsAndConditionsPage()),
                displaySettingItem('Instructions', '', Icons.question_mark,
                    true, Instructions()),
                displaySettingItem('Give Us Feedback', '', Icons.feedback, true,
                    LicensePage()),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Logout',
                  style: TextStyle(
                      color: Color(0xff2C003F),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                displayLogoutItem(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the logout button and uses FirebaseAuth to sign out.
  displayLogoutItem() {
    return TextButton(
      onPressed: () async {
        await GoogleSignInApi.logout();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xff8FD694).withOpacity(0.2),
                child: Icon(
                  Icons.logout,
                  color: Color(0xff8FD694),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Logout',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xff9E9E9E),
              )
            ],
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  // Each setting item is displayed in a nice manner.
  displaySettingItem(String name, String current_display, IconData icon,
      bool isEditable, Widget goToPage) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xff8FD694).withOpacity(0.2),
              child: Icon(
                icon,
                color: Color(0xff8FD694),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            current_display != ''
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(color: Color(0xff9E9E9E)),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        current_display,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      )
                    ],
                  )
                : Text(
                    name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
            Spacer(),
            isEditable
                ? IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return goToPage;
                        },
                      ));
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xff9E9E9E),
                    ))
                : Container(),
          ],
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
