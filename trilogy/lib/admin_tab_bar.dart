import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:trilogy/admin_approvals.dart';
import 'package:trilogy/admin_find_partnerships.dart';
import 'package:trilogy/admin_settings.dart';

class AdminTabBar extends StatefulWidget {
  AdminTabBar({Key? key, required this.currentPage}) : super(key: key);

  int currentPage;

  @override
  State<AdminTabBar> createState() => _AdminTabBarState();
}

class _AdminTabBarState extends State<AdminTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
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

  void changePage(int newPage) {
    setState(() {
      widget.currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

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
                  Icons.gavel,
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
                  Icons.settings,
                  color: widget.currentPage == 2
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
        width: MediaQuery.of(context).size.width * 0.7,
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
            AdminFindPartnerships(),
            AdminApprovals(),
            AdminSettings(),
          ],
        ),
      ),
    );
  }
}
