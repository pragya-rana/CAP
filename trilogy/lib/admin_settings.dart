import 'package:flutter/material.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
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
                          'JS',
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
                          'Jeffrey Stride',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Head of CTE department',
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
                    'Display Name', 'Jeffrey Stride', Icons.person, false),
                displaySettingItem(
                    'Person', 'Administrator', Icons.school, false),
                displaySettingItem('Pronouns', 'He/Him', Icons.wc, true),
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
                displaySettingItem(
                    'View Licensing &\nTerms of Use', '', Icons.article, false),
                displaySettingItem(
                    'Instructions', '', Icons.question_mark, false),
                displaySettingItem(
                    'Give Us Feedback', '', Icons.feedback, true),
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
                displaySettingItem('Logout', '', Icons.logout, true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  displaySettingItem(
      String name, String current_display, IconData icon, bool isEditable) {
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
                ? Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xff9E9E9E),
                  )
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
