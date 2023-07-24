import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/screens/home_screen/view/home_screen.dart';
import 'package:simplemail/screens/login_screen/view/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/gmail_message.dart';

class AuthService extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://mail.google.com/',
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/gmail.labels',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/gmail.compose',
    'https://www.googleapis.com/auth/drive.readonly'
  ]);
  bool isLoading = false;
 

  StreamBuilder<User?> handleAuthState() {
    return StreamBuilder(
        stream: _firebaseAuth.authStateChanges(),
        builder: (BuildContext authcontext, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return const LoginScreen();
          }
        });
  }

  Future<void> signInWithGoogle() async {
    try {
      await Connectivity().checkConnectivity().then((value) async {
        if (value != ConnectivityResult.none) {
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          final GoogleSignInAuthentication googleAuth =
              await googleUser!.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', googleAuth.accessToken!);
          // await _firebaseAuth.signInWithCredential(credential);
          //          // After successful login
          // InboxController inboxController = Get.find();
          // await inboxController.saveUserAccount(googleUser.email, googleAuth.accessToken!);

          final authResult =
              await FirebaseAuth.instance.signInWithCredential(credential);
          await saveUserAccount(authResult);
          await prefs.setBool('isLoggedIn', true);
          Get.offAll(() => HomeScreen());
        } else {
          Get.snackbar(
            'No Internet Connection',
            'Connect to internet',
            duration: const Duration(seconds: 3),
          );
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> saveUserAccount(UserCredential userCredential) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final accounts = jsonDecode(accountsJson) as List;
    final account = {
      'uid': userCredential.user!.uid,
      'name': userCredential.user!.displayName,
      'email': userCredential.user!.email,
      'photoUrl': userCredential.user!.photoURL,
    };
    accounts.add(account);
    print('------------ user creds ');
    print(userCredential.credential!.asMap().toString());
    // prefs.setString(userCredential.user!.uid,
    //     userCredential.credential!.asMap().toString());
    await prefs.setString('${userCredential.user!.uid}__accessToken',
        userCredential.credential!.accessToken!);

    FirebaseAuth.instance.currentUser
        ?.getIdTokenResult(true)
        .then((tokenResult) {
      String? token = tokenResult.token;
      prefs.setString('${userCredential.user!.uid}__idToken', token!);
    }).catchError((error) {
      print("Error getting fresh ID Token: $error");
    });

    await prefs.setString('accounts', jsonEncode(accounts));
  }

  Future<void> signInWithUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final accounts = jsonDecode(accountsJson) as List;
    final account = accounts.firstWhere((account) => account['uid'] == uid);
    final authCredential = GoogleAuthProvider.credential(
      idToken: account['idToken'],
      accessToken: account['accessToken'],
    );
    await _firebaseAuth.signInWithCredential(authCredential);
  }


  Future<void> switchAccount(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String accessToken = prefs.getString('${uid}__accessToken')!;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: null, 
    );

    await prefs.setString('token', accessToken);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log(e.toString());
    }

    print(FirebaseAuth.instance.currentUser?.displayName);
    await prefs.setString('currentAccountUid', uid);
    update(['drawer']);
  }

  Future<String?> getCurrentToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentToken = prefs.getString('token');
    return currentToken;
  }

  Future<bool> isTokenExpired(String? token) async {
    if (token == null) {
      return true;
    }

    final Uri url =
        Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final http.Response response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return false;
    } else {
      return true;
    }
  }

  void refreshTokenWhenExpired() async {
    while (true) {
      try {
        final currentToken = await getCurrentToken();

        if (await isTokenExpired(currentToken)) {
          final newToken = await refreshToken();
        }

        await Future.delayed(Duration(minutes: 1));
      } catch (e, stackTrace) {
        break;
      }
    }
  }

  Future<String?> refreshToken() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signInSilently();
      if (googleSignInAccount == null) {
        throw Exception('Failed to refresh token: user is not signed in.');
      }

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final authResult = await _firebaseAuth.signInWithCredential(credential);

      if (authResult.user == null) {
        throw Exception('Failed to refresh token: authentication failed.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', googleSignInAuthentication.accessToken!);

      return googleSignInAuthentication.accessToken; // New refreshed token
    } catch (e) {
      print('Failed to refresh token: ${e.toString()}');
      return null;
    }
  }

//   Future<void> userSignOut(int index) async {
//   try {
//     isLoading = true;
//     update();

//     // Get the instance of InboxController
//     InboxController inboxController = Get.find<InboxController>();

//     // Remove the account from the userAccounts list in the InboxController
//     inboxController.signOutAccount(index);

//     // Call Google Sign-In's signOut method
//     // Note: This will sign out the current Google user. If you need more granular control,
//     // you might need to use the Google People API or a similar API to revoke access for specific accounts.
//     await _googleSignIn.signOut();

//     // Navigate to the LoginScreen if there are no accounts left
//     if (inboxController.userAccounts.isEmpty) {
//        await clearStoredData();
//       Get.deleteAll(force: true);
//       Get.offAll(() => const LoginScreen());
//     }

//     isLoading = false;
//     update();
//   } catch (E) {
//     isLoading = false;
//     update();
//     print(E.toString());
//   }
// }

  HomeController homeController = Get.put(HomeController());
  Future clearStoredData() async {
    final SharedPreferences clearData = await SharedPreferences.getInstance();
    clearData.clear();
    homeController.gmailDetail.clear();
    homeController.unreadGmailDetails.clear();
  }

  Future<void> markMessageAsSeen(
      {required String messageId, required String accessToken}) async {
    final endpoint =
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/modify';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'removeLabelIds': ['UNREAD'], 
      }),
    );

    if (response.statusCode == 200) {
      print('Message $messageId marked as seen');
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/1/message_$messageId.json';
      final file = File(filePath);

      try {
        print('object------------');
        if (file.existsSync()) {
          print('object------------1111111');

          print('inmessageFile');
          final response = await file.readAsString();
          final data = json.decode(response);

          final message = GmailMessage.fromJson(data);

          if (message.labelIds!.contains('UNREAD')) {
            message.labelIds!.remove('UNREAD');
          }

          final updatedJson = json.encode(message.toJson());

          await file.writeAsString(updatedJson);
          update();
        }
      } catch (e) {
        update();
        throw Exception('Failed to load message details');
      }
    } else {
      print('Failed to mark message $messageId as seen: ${response.body}');
    }
  }
}
