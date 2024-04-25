import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/admin/admin_approvals.dart';
import 'package:trilogy/admin/admin_find_partnerships.dart';
import 'package:trilogy/admin/admin_settings.dart';
import 'package:trilogy/all/calendar.dart';
import 'package:trilogy/partner/partner_add_event_or_listing.dart';
import 'package:trilogy/partner/partner_calendar.dart';
import 'package:trilogy/partner/partner_home.dart';
import 'package:trilogy/partner/partner_settings.dart';
import 'package:trilogy/screens/chat_screen.dart';
import 'package:trilogy/unused/teacher_class_messages.dart';

// This class is a widget that represents the tab bar the partners will be able to see.
// ignore: must_be_immutable
class PartnerTabBar extends StatefulWidget {
  PartnerTabBar({Key? key, required this.currentPage, required this.user})
      : super(key: key);

  int currentPage;
  final GoogleSignInAccount user;

  @override
  State<PartnerTabBar> createState() => _PartnerTabBarState();
}

class _PartnerTabBarState extends State<PartnerTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  String companyName = '';

  // Retrieves the name of the partner from Firebase Firestore.
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

  @override
  void initState() {
    super.initState();
    getName();
    tabController = TabController(length: 6, vsync: this);
    tabController.index = widget.currentPage; // Set initial index here

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        final newPage = tabController.index;
        if (newPage != widget.currentPage && mounted) {
          changePage(newPage);
        }
      }
    });
  }

  // Dynamically updates the page when user navigates to a new one/
  void changePage(int newPage) {
    setState(() {
      widget.currentPage = newPage;
    });
  }

  // Called when this object is removed from the tree permanently.
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // This builds the actual layout of the tab bar that the partner sees.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomBar(
        child: TabBar(
          controller: tabController,
          indicatorPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xff8FD694), width: 3),
              insets: EdgeInsets.fromLTRB(16, 0, 16, 12)),
          tabs: [
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.home,
                  color: widget.currentPage == 0
                      ? Color(0xff8FD694)
                      : Color(0xff9E9E9E),
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: widget.currentPage == 1
                      ? Color(0xff8FD694)
                      : Color(0xff9E9E9E),
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.calendar_month,
                  color: widget.currentPage == 2
                      ? Color(0xff8FD694)
                      : Color(0xff9E9E9E),
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.chat_bubble,
                  color: widget.currentPage == 3
                      ? Color(0xff8FD694)
                      : Color(0xff9E9E9E),
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.question_mark,
                  color: widget.currentPage == 4
                      ? Color(0xff8FD694)
                      : Color(0xff9E9E9E),
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.settings,
                  color: widget.currentPage == 5
                      ? Color(0xff8FD694)
                      : Color(0xff9E9E9E),
                ),
              ),
            ),
          ],
        ),
        barDecoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(4, 4),
            blurRadius: 40,
          )
        ]),
        borderRadius: BorderRadius.circular(500),
        duration: Duration(seconds: 1),
        curve: Curves.decelerate,
        showIcon: true,
        width: MediaQuery.of(context).size.width * 0.9,
        barColor: Colors.white,
        start: 2,
        end: 0,
        offset: 25,
        barAlignment: Alignment.bottomCenter,
        iconHeight: 35,
        iconWidth: 35,
        reverse: false,
        hideOnScroll: true,
        scrollOpposite: false,
        onBottomBarHidden: () {},
        onBottomBarShown: () {},
        body: (context, controller) => TabBarView(
          controller: tabController,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(),
          children: [
            PartnerHome(
              user: widget.user,
            ),
            PartnerAddEventOrListing(
              user: widget.user,
            ),
            PartnerCalendar(user: widget.user),
            ListingsPage(business: companyName),
            ChatScreen(),
            PartnerSettings(user: widget.user)
          ],
        ),
      ),
    );
  }
}
