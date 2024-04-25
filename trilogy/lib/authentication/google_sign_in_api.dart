import 'package:google_sign_in/google_sign_in.dart';

// This class uses the GoogleSignIn class to handle authorization.
class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future logout() => _googleSignIn.disconnect();
}