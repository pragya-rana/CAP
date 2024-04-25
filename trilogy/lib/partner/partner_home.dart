import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/partner/business_view_applications.dart';
import 'package:intl/intl.dart';
import 'package:overlay_group_avatar/overlay_group_avatar.dart';

// This class is a widget that represents the home page for the partner.
class PartnerHome extends StatefulWidget {
  const PartnerHome({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  State<PartnerHome> createState() => _PartnerHomeState();
}

class _PartnerHomeState extends State<PartnerHome> {
  List<Map<String, String>> listings = [];
  List<Map<String, String>> events = [];

  String companyName = '';

  // The name of the company that the partner represents is retrieved.
  Future<void> getName() async {
    var userQuery = await FirebaseFirestore.instance
        .collection('partnerships')
        .where('contactInfo', isEqualTo: widget.user.email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      var userSnapshot = userQuery.docs.first;
      setState(() {
        companyName = userSnapshot.data()['name'];
      });
    }
  }

  // All of the upcoming events native to the company are retrieved from Firestore.
  Future<void> getEvents() async {
    await getName();
    await FirebaseFirestore.instance
        .collection('events')
        .where('name', isEqualTo: companyName)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                String title = element.data()['title'] as String;
                String day =
                    element.data()['startDate'].toDate().day.toString();
                String month =
                    element.data()['startDate'].toDate().month.toString();
                String location = element.data()['location'] as String;
                setState(() {
                  events.add({
                    'title': title,
                    'day': day,
                    'month': month,
                    'location': location,
                  });
                });
              })
            });
  }

  // All of the listings that the company offers is retrieved from Firestore.
  Future<void> getListings() async {
    await getName();
    await FirebaseFirestore.instance
        .collection('listings')
        .where('name', isEqualTo: companyName)
        .get()
        .then((value) => {
              value.docs.forEach((element) async {
                int applicationsLength = await FirebaseFirestore.instance
                    .collection('listings')
                    .doc(element.id)
                    .collection('applications')
                    .get()
                    .then((appsSnapshot) => appsSnapshot.size);
                String type = element.data()['type'];
                String title = element.data()['title'];
                String deadline = DateFormat('MMMM d, yyyy')
                    .format(element.data()['deadline'].toDate());
                print(deadline);
                String location = element.data()['location'];
                setState(() {
                  listings.add({
                    'type': type,
                    'title': title,
                    'month': DateFormat('MMM')
                        .format(element.data()['deadline'].toDate()),
                    'day': DateFormat('d')
                        .format(element.data()['deadline'].toDate()),
                    'deadline': deadline,
                    'applications': applicationsLength.toString(),
                    'location': location,
                    'listingRef': element.id,
                  });
                });
              })
            });
  }

  @override
  void initState() {
    getListings();
    getEvents();
    super.initState();
  }

  // This builds the layout of the home page for the partner.
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
                Text(
                  'View Listings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 0),
                listings.length == 0
                    ? CircularProgressIndicator()
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.38,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int index = 0;
                                  index < listings.length;
                                  index++)
                                buildListingCard(
                                    listings[index]['type']!,
                                    listings[index]['location']!,
                                    listings[index]['title']!,
                                    listings[index]['deadline']!,
                                    listings[index]['applications']!,
                                    listings[index]['month']!,
                                    listings[index]['day']!,
                                    listings[index]['listingRef']!),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  itemCount: events.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    String title = events[index]['title'] as String;
                    String day = events[index]['day'] as String;
                    String month = events[index]['month'] as String;
                    String location = events[index]['location'] as String;
                    return buildEventCard(title, location, month, day);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListingCard(
      String type,
      String location,
      String title,
      String deadline,
      String applications,
      String month,
      String day,
      String listingRef) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return BusinessViewApplications(
                    listingRef: listingRef, listingTitle: title);
              },
            ));
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.32,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(4, 4))
                ]),
            child: Stack(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'images/' + type.toLowerCase() + '.jpg',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.1), // Adjust opacity as needed
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                month.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          location,
                          style:
                              TextStyle(fontSize: 12, color: Color(0xff9E9E9E)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xff8FD694),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      applications + ' Applications',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xff8FD694),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      determineIfOngoing(deadline),
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  determineIfOngoing(String deadline) {
    DateTime deadlineDateTime = DateFormat('MMMM d, yyyy').parse(deadline);
    DateTime now = DateTime.now();
    if (deadlineDateTime.isBefore(now)) {
      return 'Passed';
    } else {
      return 'Ongoing';
    }
  }

  Widget buildEventCard(
      String title, String location, String month, String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 4, right: 4),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(2, 2),
                  blurRadius: 6)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    color: Color(0xffE4E4EC),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff2C003F)),
                    ),
                    Text(
                      DateFormat('MMM').format(DateTime(0, int.parse(month))),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff2C003F)),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    location,
                    style: TextStyle(fontSize: 12, color: Color(0xff9E9E9E)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
