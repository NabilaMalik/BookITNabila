//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:get/get.dart';
//
// final FirebaseAuth _auth = FirebaseAuth.instance;
// Future<void> signInWithFacebook() async {
//
//   try {
//     // Attempt to log in the user using Facebook
//     final LoginResult result = await FacebookAuth.instance.login();
//
//     if (result.status == LoginStatus.success) {
//       // Get the access token as a string
//       final String? token = result.accessToken?.tokenString;
//
//       // Ensure that the token is not null before proceeding
//       if (token != null) {
//         // Create a Facebook Auth credential using the token
//         final OAuthCredential credential = FacebookAuthProvider.credential(token);
//
//         // Use the credential to sign in with Firebase
//         await _auth.signInWithCredential(credential);
//
//         // Navigate to the home page on successful login
//         Get.offNamed('/home');
//       } else {
//         Get.snackbar("Error", "Failed to retrieve access token.", backgroundColor: Colors.red);
//       }
//     } else {
//       Get.snackbar("Error", result.message ?? "Unknown error", backgroundColor: Colors.red);
//     }
//   } catch (e) {
//     // Show an error message if the login fails
//     Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
//   }
// }