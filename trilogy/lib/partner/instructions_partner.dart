import 'package:flutter/material.dart';

// This widget shows all instructions for how to use the app as a partner.
class InstructionsPartner extends StatefulWidget {
  const InstructionsPartner({super.key});

  @override
  State<InstructionsPartner> createState() => _InstructionsPartnerState();
}

class _InstructionsPartnerState extends State<InstructionsPartner> {
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
                      'As a partner, you have access to the following pages:\n',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '1. Home (home icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Displays offered listings and upcoming events.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '2. Add Listing/Event (add icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Create a listing or event by inputting information into the text fields.\n',
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
                              'Displays events organized by your business/organization.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '4. Messages (chat icon): ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                          text:
                              'Message school administrators from various departments.\n',
                          style: TextStyle(
                            color: Colors.black,
                          ))
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '5. Helix Helper (question mark icon): ',
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
                        text: '6. Settings (settings icon): ',
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
                      'Home Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                        'This page is meant to provide a snapshot of listings and events that your business offers. In this page, you will see:\n',
                        style: TextStyle(color: Colors.black)),
                    Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'You will have access to all of the upcoming events that are organized by your business/organization. These events will have the title, description, and dates of the event. These events are also accessible in the calendar page where more information is provided.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Listings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'All of the listings that are offered by your business/organizations. These listings will provide information into the number of applicants, title of the listing, and deadline of the listing. Upon clicking on the listing, you can download the applicants’ resumes and applications. Then, you can make a decision on that applicant and further contact them via email.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Add Listing/Event Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'In this page, you have the ability to create listings of events that are offered by your company. These opportunities will then be able to be accessed by the students.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Add Listing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'To add a listing, you should input the title of the listing, description of the listing, type it falls under (job, internship, or volunteer), grade requirements, address, deadline of the application, and a pdf of the application that students are required to fill.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Add Event',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'To add an event, you should input the title of the event, description of the event, start date and time, end date and time, and the address.\n',
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
                      'The purpose of this page is to see any upcoming events that are being organized by your business/organization. In this page, you will be able to:\n',
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
                      'Messaging Page',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'In this page, you will have the opportunity to contact school administrators to ask them questions and to connect with them. You will have the opportunity to communicate with several different department heads of the school.\n',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Messaging Administrator',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'When messaging the administrator, you can click on the text field and write a short message. You will additionally have the opportunity to message photos to the administrator. The administrator will receive these messages and have the opportunity to communicate back.\n',
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
                      'This information will be relevant to you. It will include items, such as your business/organization name, the type of person you are (“partner” in this case), and your pronouns.\n',
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
