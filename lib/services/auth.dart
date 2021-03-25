import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messanger_clone/helper_functions/shared_pref_helper.dart';
import 'package:messanger_clone/screens/home.dart';
import 'package:messanger_clone/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethod{
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async{
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );
    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    User userDetails = userCredential.user;

    if(userCredential != null){
      await SharedPrefHelper().saveUserEmail(userDetails.email);
      await SharedPrefHelper().saveUserId(userDetails.uid);
      await SharedPrefHelper().saveUserName(userDetails.email.replaceAll('@gmail.com', '').replaceAll('@taybull.com', '').replaceAll('@utg.edu.gm', ''));
      await SharedPrefHelper().saveDisplayName(userDetails.displayName);
      await SharedPrefHelper().saveUserProfileUrl(userDetails.photoURL);
      
      Map<String, dynamic> userInfoMap = {
        'email': userDetails.email,
        'username': userDetails.email.replaceAll('@gmail.com', '').replaceAll('@taybull.com', '').replaceAll('@utg.edu.gm', ''),
        'name': userDetails.displayName,
        'profileUrl': userDetails.photoURL,
      };
      
      DatabaseMethods().addUserInfoToDatabase(userDetails.uid, userInfoMap).then((value) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }
  //sign in with email and password
  Future registerWithEmailAndPassword(BuildContext context, String email, String password, String name, String photoUrl) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    User userDetails = userCredential.user;

    if(userCredential != null){
      await SharedPrefHelper().saveUserEmail(userDetails.email);
      await SharedPrefHelper().saveUserId(userDetails.uid);
      await SharedPrefHelper().saveUserName(userDetails.email.replaceAll('@gmail.com', '').replaceAll('@taybull.com', '').replaceAll('@utg.edu.gm', ''));
      await SharedPrefHelper().saveDisplayName(name);
      await SharedPrefHelper().saveUserProfileUrl(photoUrl);

      Map<String, dynamic> userInfoMap = {
        'email': userDetails.email,
        'username': userDetails.email.replaceAll('@gmail.com', '').replaceAll('@taybull.com', '').replaceAll('@utg.edu.gm', ''),
        'name': name,
        'profileUrl': photoUrl,
      };

      DatabaseMethods().addUserInfoToDatabase(userDetails.uid, userInfoMap).then((value) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}