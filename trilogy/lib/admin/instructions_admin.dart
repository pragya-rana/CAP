import 'package:flutter/material.dart';

// This widget shows all instructions for how to use the app as a administrator.
class InstructionsAdmin extends StatefulWidget {
  const InstructionsAdmin({super.key});

  @override
  State<InstructionsAdmin> createState() => _InstructionsAdminState();
}

class _InstructionsAdminState extends State<InstructionsAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff8FD694),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 0.0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          )),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Color(0xffF7F7F7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 20.0, 20.0),
                        child: Text(
                          'Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'The purpose of Helix is to connect students, administrators, and business owners on one platform in order to get the best networking and workplace experience possible.\n',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'As a administrator, you have access to the following pages:\n',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '1. Find Partnerships (search icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Displays all the partners currently associated with your school.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '2. Pending Approvals (gavel icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Displays all businesses that have requested approval to become a partner with the school.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '3. Calendar (calendar icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Displays events organized by partners approved by you or another administration member.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '4. Helix Helper (question mark icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'An intelligent chatbot that can help you navigate Helix and answer any questions about the app.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '5. Settings (settings icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Displays all user settings, including pronouns, terms of licensing & use, a feedback page, and so much more.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    Text(
                      'Find Partnerships Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                        'This page is meant to provide a snapshot of all the partners that have been approved by either you or another administration member at your school. In this page, you will be able to view:\n',
                        style: TextStyle(color: Colors.black)),
                    Text(
                      'All Partners',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'You will have access to all of the partners of your school. A picture of the partner\'s logo and information of the company name and type is provided. These partners are displayed on individual cards. Partners can be searched for at the top of the screen or filtered down (when the filter icon is pressed). These search and filter options make it easier to narrow down all the partners.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Partner Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'To learn more about each partner, you can click on the partner card. Additional information, such as the location the company is based in, contact information, a description of the company, the type of partner, and the types of services they offer. You will even have the ability to message this partner.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Messaging Partner',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'When messaging the partner, you can click on the text field and write a short message. You will additionally have the opportunity to message photos to the partner. The partner will receive these messages and have the opportunity to communicate back.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Pending Approvals Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'A list of partners that require approval will be displayed here. You can automatically reject this partner by swiping the card to the left. To get more information on the partner, you can click on the three dots icon.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Partner Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'To learn more about each partner, you can click on the partner card. Additional information, such as the location the company is based in, contact information, a description of the company, the type of partner, and the types of services they offer. You will have the opportunity to approve the partnership or reject the partnership here.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Calendar Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'The purpose of this page is to see any upcoming events that are being organized by partners approved by your school\'s administration. In this page, you will be able to:\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Browsing Through the Events',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'You will be able to click through the different dates (switching across days, months, and even years); the purple dots under the data will tell you the number of events that you have on that particular day; when you click on the date, a list of offered events will show up. These events will have initial information about time, event title, and company organizing it. By clicking on the three dots icon on the right, you will have access to additional information, such as the description and location of the event.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Helix Helper',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'The Helix Helper is a trained and intelligent chatbot that will answer any questions you have about the app, whether it be about navigation or the ways you can utilize Helix to benefit you. To use this key feature, just type in your question into the search box and press the send icon. A response will be generated in just a few seconds.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Settings Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'The settings page is meant to provide an overview information about your account and information about Helix. In the settings page, you will be able to view:\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'This information will be relevant to you. It will include items, such as your name, the type of person you are ("administrator" in this case), and your pronouns. The only editable field is your pronouns.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Changing Pronouns',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'You will be able to change your pronouns by being redirected to a page where you will be able to input your new pronouns. This is important because this information will be displayed to the individual being messaged.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Help and Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'These settings will present information about our app, including our licensing & terms of use, these instructions, and a feedback page.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Give Us Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'If you have a bug, suggestion, compliments, etc. to report you can give us feedback, which we will seriously consider. To give us feedback, you will be redirected to a new page, which will be a form. You will rate the satisfaction you have with Helix on a scale of 0-10, pick the subject of feedback through a dropdown menu, and add an option comment. When you click the submit button, this feedback will be recorded and we will make sure to consider it.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'The last item on this screen is the logout button. It will log you out of your account and take you back to the sign in page.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
