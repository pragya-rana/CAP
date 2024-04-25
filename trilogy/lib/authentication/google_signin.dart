import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:trilogy/authentication/log_in.dart';
import 'package:trilogy/tabs/student_tab.dart';

// This class allows the user to sign in using their Google account.
// This is an important check on privacy and ensures that the user's information is their own.
// This class has methods to login,
class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  // User is able to signin with credentials when they select their account.
  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Notifies the client if the user was able to be authorized successfully.
    notifyListeners();
  }

  // Checks whether or not the user was able to be successfully authorized.
  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // Logs out user
  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }

  // Checks how the authorization state has changed and returns page accordingly.
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            // If user has been successfully authorized, they will have
            // access to all of the student items.
            return StudentTabBar(currentPage: 0, user: user);
          } else {
            // If user has not been successfully authorized or they have
            // signed out, the sign in page will be displayed.
            return LoginPage();
          }
        });
  }
}
