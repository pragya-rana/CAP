import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/authentication/google_sign_in_api.dart';
import 'package:trilogy/authentication/log_in.dart';
import 'package:trilogy/partner/instructions_partner.dart';
import 'package:trilogy/all/terms_conditions.dart';

// This class represents the settings that the partner sees.
class PartnerSettings extends StatefulWidget {
  const PartnerSettings({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  State<PartnerSettings> createState() => _PartnerSettingsState();
}

class _PartnerSettingsState extends State<PartnerSettings> {
  String companyName = '';
  String companyId = '';
  String logoUrl = '';

  // The user id of the partner is retrieved from Firestore.
  Future<void> getUserId() async {
    var userQuery = await FirebaseFirestore.instance
        .collection('partnerships')
        .where('contactInfo', isEqualTo: widget.user.email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      var userSnapshot = userQuery.docs.first;
      String logoRef = userSnapshot.data()['logoRef'];
      var ref = FirebaseStorage.instance
          .ref()
          .child("logos/" + logoRef.split('/')[1]);
      String logo_url = (await ref.getDownloadURL()).toString();
      setState(() {
        companyId = userSnapshot.id;
        logoUrl = logo_url;
      });
    }
  }

  // Details about the user are retrieved from Firestore.
  Future<void> getUserDetails() async {
    await getUserId();
    var userSnapshot = await FirebaseFirestore.instance
        .collection('partnerships')
        .doc(companyId)
        .get();
    if (userSnapshot.exists) {
      setState(() {
        companyName = userSnapshot.data()!['name'] as String;
      });
    }
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  // The actual settings layout is built here.
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
                      child: logoUrl == ''
                          ? Container()
                          : ClipOval(
                              child: Image.network(
                                logoUrl,
                                fit: BoxFit
                                    .cover, // Ensures the image fits and covers the circular boundary
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
                          companyName == '' ? '' : companyName,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Partnered with NCHS CTE',
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
                displaySettingItem(
                    'Display Name',
                    companyName == '' ? '' : companyName,
                    Icons.person,
                    false,
                    LicensePage()),
                displaySettingItem('Person', 'Business Owner', Icons.school,
                    false, LicensePage()),
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
                    true, InstructionsPartner()),
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

  // The logout button is created and uses GoogleAuth to successfully logout.
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

  // Each setting is built to nicely represent the item that it symbolizes.
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
