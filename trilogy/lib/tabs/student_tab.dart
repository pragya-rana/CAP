import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trilogy/all/calendar.dart';
import 'package:trilogy/screens/chat_screen.dart';
import 'package:trilogy/student/student_listings.dart';
import 'package:trilogy/student/student_settings.dart';

// This class is a widget that represents the tab bar the students will be able to see.
// ignore: must_be_immutable
class StudentTabBar extends StatefulWidget {
  StudentTabBar({Key? key, required this.currentPage, required this.user})
      : super(key: key);

  int currentPage;
  final GoogleSignInAccount user;

  @override
  State<StudentTabBar> createState() => _AdminTabBarState();
}

class _AdminTabBarState extends State<StudentTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
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

  // Dynamically updates the page the user is on when they navigate to a new one.
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

  // Builds the actual layout of the student's tab bar.
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
                  Icons.search,
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
                  Icons.calendar_month,
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
                  Icons.question_mark,
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
                  Icons.settings,
                  color: widget.currentPage == 3
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
        width: MediaQuery.of(context).size.width * 0.8,
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
            StudentListings(
              user: widget.user,
            ),
            Calendar(),
            ChatScreen(),
            StudentSettings(
              user: widget.user,
            ),
          ],
        ),
      ),
    );
  }
}
