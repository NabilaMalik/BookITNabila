// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//
// Future<User?> signInWithApple() async {
//   final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
//     scopes: [
//       AppleIDAuthorizationScopes.email,
//       AppleIDAuthorizationScopes.fullName,
//     ],
//   );
//
//   final AuthCredential credential = OAuthProvider('apple.com').credential(
//     idToken: appleCredential.identityToken,
//     accessToken: appleCredential.authorizationCode,
//   );
//
//   final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//   return userCredential.user;
// }
