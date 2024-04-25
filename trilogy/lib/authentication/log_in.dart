import 'package:flutter/material.dart';
import 'package:trilogy/partner/partner_pending.dart';
import 'package:trilogy/tabs/admin_tab_bar.dart';
import '../tabs/student_tab.dart';
import 'google_sign_in_api.dart';
import '../all/calendar.dart';

// This widget will display the sign in page.
// It will use the GoogleSignInApi class to assess whether the user
// able to be successfully authorized.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _MemberLoginPageState();
}

class _MemberLoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff8FD694),
      body: SafeArea(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Title of app
            Image.asset(
              'images/logo.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),

            // App slogan
            const Text(
              'LEARN. GROW. EVOLVE.',
              style: TextStyle(
                fontSize: 23,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 20,
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 25, 10),
                child: Text(
                  'LOGIN AS A...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            // Student sign in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(76, 44, 114, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: TextButton(
                  onPressed: () {
                    signInStudent();
                  },
                  child: const Text(
                    "STUDENT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 12),

            // Parent sign in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(76, 44, 114, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: TextButton(
                  onPressed: () {
                    signInAdmin();
                  },
                  child: const Text(
                    "ADMINISTRATOR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 12),

            // Teacher sign in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(76, 44, 114, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: TextButton(
                  onPressed: () {
                    signInBusiness();
                  },
                  child: const Text(
                    "BUSINESS OWNER",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                )),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Signs in student by first checking whether the Google account is verified
  // Secondary verification occurs by checking if the email matches the 'apps.nsd.org' extension.
  // This extension is common to all NCHS students.
  Future signInStudent() async {
    var user = await GoogleSignInApi.login();

    if (user != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StudentTabBar(
                currentPage: 0,
                user: user,
              )));
    }
  }

  // Signs in parent by checking whether the Google account is verified.
  Future signInAdmin() async {
    final user = await GoogleSignInApi.login();

    if (user != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AdminTabBar(currentPage: 0, user: user)));
    }
  }

  // Signs in teacher by checking whether the Google account is verfied.
  // Secondary verification occurs by checking if the email contains the 'nsd.org' extension.
  // This extension common to all NCHS teachers.
  Future signInBusiness() async {
    final user = await GoogleSignInApi.login();

    if (user != null) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PartnerPending(user: user)));
    }
  }
}
