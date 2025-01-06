// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../Utilities/global_variables.dart';
//
//
//
// Future<void> signUpWithGoogle() async {
//   try {
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//
//     if (googleUser != null) {
//       // Verify ID token instead of email enumeration
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final UserCredential userCredential = await auth.signInWithCredential(credential);
//       final User user = userCredential.user!;
//
//       // Check if the user already exists
//       if (userCredential.additionalUserInfo!.isNewUser) {
//         // User is new, proceed with registration
//         Get.offNamed('/login'); // Redirect to the dashboard after successful login
//       } else {
//         // User already exists, show a snack bar
//         Get.snackbar(
//           'Error',
//           'This email is already registered.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         // Optionally sign out the newly signed-in user if desired
//         await auth.signOut();
//       }
//     }
//   } catch (e) {
//     print('Google Sign-In Error: $e');
//   }
// }
//
