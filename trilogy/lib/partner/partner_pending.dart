import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/tabs/partner_tab_bar.dart';

// This class is a widget that represents what the partner sees based on
// whether they have been accepted or rejected by the school's administration.
class PartnerPending extends StatefulWidget {
  const PartnerPending({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  State<PartnerPending> createState() => _BusinessPendingState();
}

class _BusinessPendingState extends State<PartnerPending> {
  @override
  Widget build(BuildContext context) {
    // Dyanmically updates page layout based on status.
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('partnerships')
          .where('contactInfo', isEqualTo: widget.user.email)
          .snapshots()
          .map((snapshot) => snapshot.docs.first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('No data found');
        } else {
          var status = snapshot.data!['status'];
          if (status == 'Pending') {
            return buildPendingPage();
          } else if (status == 'Rejected') {
            return buildRejectedPage();
          } else {
            return PartnerTabBar(currentPage: 0, user: widget.user);
          }
        }
      },
    );
  }

  // If rejected by school's administration, a page informing this is displayed.
  Widget buildRejectedPage() {
    return Scaffold(
      backgroundColor: Color(0xff8FD694),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your request to join the NCHS CTE department has been denied. Sorry!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // If the request is still pending, a page informing this is displayed.
  Widget buildPendingPage() {
    return Scaffold(
      backgroundColor: Color(0xff8FD694),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your request to join the NCHS CTE department is currently being processed. Please be patient.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              CircularProgressIndicator(
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
