import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/login_screen/view/login_screen.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:intl/intl.dart';

class StarredController extends GetxController {
  String? token;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isListMoreLoading = false;
  String title = 'All Inbox';
  var myDate = DateTime.now();
  Allmessages allInboxMessages = Allmessages();
  GmailMessage gmailMessage = GmailMessage();
  Allmessages allUnreadInboxMessages = Allmessages();
  final userAccounts = <Account>[].obs;
  int currentAccountIndex = 0;

  List<GmailMessage> gmailDetail = [];
  List<GmailMessage> listUntillLoading = [];
  List<GmailMessage> primaryDetail = [];
  List<GmailMessage> unreadGmailDetails = [];

  String? nextPageToken;
  String currentTabAPI = 'INBOX';
  bool noMail = false;

  int selectedIndex = 0;
  List<String> drawerListTitles = [
    "Inbox",
    "Starred",
    "Important",
    "Sent",
    "Drafts",
    "Unread",
    "Personal",
    "Social",
    "Promotions",
    "Spam",
    "Bin",
    "Settings",
    "Help & Feedback",
  ];

  @override
  void onInit() async {
    super.onInit();
    loadGmailApis('INBOX');
  }

  changeRefreshing(bool value) {
    isRefreshing = value;
    update();
  }

  moreListCalling() {
    isListMoreLoading = true;
    update();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    title = drawerListTitles[index];
    update();
  }

  Color? getTileColor(int index) {
    if (index == selectedIndex) {
      return Colors.blue;
    } else {
      return null;
    }
  }

  loadGmailApis(String lable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString('token');
    await fetchInboxMessages();
  }

  Future fetchInboxMessages() async {
    noMail = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    try {
      if (nextPageToken != null && nextPageToken!.isNotEmpty) {
        if (nextPageToken!.contains("FINISHED")) {
          isLoading = false;

          update();
          return;
        }
      }
      isLoading = true;
      update();
      final url = (nextPageToken == null && gmailDetail.isEmpty)
          ? Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=STARRED')
          : Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=STARRED&pageToken=$nextPageToken');

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/1/starred_messages_$nextPageToken.json';
      final file = File(filePath);

      if (file.existsSync()) {
        final response = await file.readAsString();
        final data = json.decode(response);

        allInboxMessages = Allmessages.fromJson(data);

        nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
        await fetchStartingGmails();
      } else {
        final networkResponse = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (networkResponse.statusCode == 200) {
          final data = networkResponse.body;
          final folder = Directory('${directory.path}/1');
          if (!folder.existsSync()) {
            folder.createSync(recursive: true);
          }
          await file.writeAsString(data);

          final decodedData = json.decode(data);
          allInboxMessages = Allmessages.fromJson(decodedData);
          nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
          await fetchStartingGmails();
        } else if (networkResponse.statusCode == 401) {
          Get.put(AuthService()).refreshToken();
          fetchInboxMessages();
        } else {
          throw Exception('Failed to load messages');
        }
      }
      // final response = await http.get(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Accept': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      // final data = json.decode(response.body);

      // allInboxMessages = Allmessages.fromJson(data);

      // nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
      // print('<----------------next page token $nextPageToken');
      // if (response.statusCode == 200) {
      //   await fetchStartingGmails();
      // } else if (data['error']['code'] == 401) {
      //   Get.put(AuthService()).refreshToken();
      //   fetchInboxMessages();
      // }
    } catch (e) {
      isLoading = false;
      update();
      throw Exception('Failed to load messages');
    }
  }

 Future<void> executeInBackground() async {
    // Perform your background task here
    // await Future.delayed(Duration(seconds: 1));
    // print('Background task executed');

    final directory = await getTemporaryDirectory();
    final inboxDir = Directory('${directory.path}/1');

// Get a list of all files within the "inbox" directory
    final files = inboxDir.listSync();

// Iterate over the list and delete each file
    for (var file in files) {
      if (file is File) {
        file.deleteSync();
      }
    }
  }
 
  fetchStartingGmails() async {
    listUntillLoading = [];
    for (int i = 0; i < allInboxMessages.messages!.length; i++) {
      await fetchGmailMessageDetails(allInboxMessages.messages![i].id!);
    }
    gmailDetail.addAll(listUntillLoading);
    if (nextPageToken != null && nextPageToken!.isNotEmpty) {
      if (nextPageToken!.contains("FINISHED")) {
        isLoading = false;

        update();
      }
    }
    isLoading = false;
    update();
  }



 Future<GmailMessage> fetchGmailMessageDetails(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isLoading = true;
    update();

    final url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId');
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/1/message_$messageId.json';
    final file = File(filePath);

    try {
      if (file.existsSync()) {
      
        final response = await file.readAsString();
        final data = json.decode(response);

        final message = GmailMessage.fromJson(data);
        listUntillLoading.add(message);
        if (message.labelIds!.contains('UNREAD')) {
          unreadGmailDetails.add(message);
        }

        return message;
      } else {
     

        final networkResponse = await http.get(url, headers: {
          'Authorization': 'Bearer $token',
        });

        if (networkResponse.statusCode == 200) {
          final data = networkResponse.body;

          // Save the data in a temporary file
          await file.writeAsString(data);

          final decodedData = json.decode(data);
          final message = GmailMessage.fromJson(decodedData);
          listUntillLoading.add(message);
          if (message.labelIds!.contains('UNREAD')) {
            unreadGmailDetails.add(message);
          }

          return message;
        } else {
          throw Exception('Failed to load message details');
        }
      }
    } catch (e) {
      isLoading = false;
      update();
      throw Exception('Failed to load message details');
    }
  }




  // Future<GmailMessage> fetchGmailMessageDetails(String messageId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token');
  //   isLoading = true;
  //   update();

  //   final response = await http.get(
  //     Uri.parse(
  //         'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final message = GmailMessage.fromJson(data);
  //     listUntillLoading.add(message);
  //     if (message.labelIds!.contains('UNREAD')) {
  //       unreadGmailDetails.add(message);
  //       print('unread gmail details');
  //       print(unreadGmailDetails);
  //     }
  //     return message;
  //   } else {
  //     isLoading = false;
  //     update();

  //     throw Exception('Failed to load message details');
  //   }
  // }

  Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final accounts = jsonDecode(accountsJson) as List;
    userAccounts.assignAll(
      accounts.map(
        (account) => Account(
          uid: account['uid'],
          name: account['name'],
          email: account['email'],
          photoUrl: account['photoUrl'],
        ),
      ),
    );
  }

  String? getCurrentAccountUid() {
    // return the uid of the current account, or null if there are no accounts
    return userAccounts.isNotEmpty
        ? userAccounts[currentAccountIndex].uid
        : null;
  }

  Future<void> saveCurrentAccountIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentAccountIndex', currentAccountIndex);
  }

  Future<void> loadCurrentAccountIndex() async {
    final prefs = await SharedPreferences.getInstance();
    currentAccountIndex = prefs.getInt('currentAccountIndex') ?? 0;
  }

  Future<void> switchAccount(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String accessToken = prefs.getString('${uid}__accessToken')!;
    print(prefs.getString('${uid}__accessToken'));

    // Here, it would be better to get a new access token using the refresh token

    // final AuthCredential credential = GoogleAuthProvider.credential(
    //   accessToken: accessToken,
    //   idToken: null, // idToken is not needed for this
    // );

    await prefs.setString('token', accessToken);

    // Find the account with the provided uid
    final index = userAccounts.indexWhere((account) => account.uid == uid);

    // If there is no account with that uid, do nothing
    if (index == -1) return;

    // Set the current account to the selected account
    currentAccountIndex = index;

    // Clear previous email data
    gmailDetail.clear();
    unreadGmailDetails.clear();
    update();

    // Load the data for the selected account
    await loadGmailApis('INBOX');

    // You can also store the current account index in SharedPreferences
    // so that it persists across app restarts
    //   final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentAccountIndex', index);
  }

// signout
  AuthService authService = Get.put(AuthService());
  Future<void> signOutUser() async {
    try {
      isLoading = true;
      update();

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      print(currentUid);
      await prefs.getString('accounts');
      for (var element in userAccounts) {
        print(element.uid.toString());
      }

      // Find the account with the current uid
      final index =
          userAccounts.indexWhere((account) => account.uid == currentUid);

      // If there is no account with that uid, do nothing
      if (index == -1) {
        print('noid');
        isLoading = false;
        update();
        await authService.clearStoredData();
        Get.deleteAll(force: true);
        prefs.clear();
        Get.offAll(() => const LoginScreen());
        await authService.googleSignIn.signOut();
      } else {}
      // Remove the account from the userAccounts list
      userAccounts.removeAt(index);

      // If there are still any accounts left, set the first one as the current account
      if (userAccounts.isNotEmpty) {
        await Get.put(AuthService()).switchAccount(userAccounts.first.uid);
        await loadGmailApis('INBOX');
      } else {
        // Handle the case where there are no accounts left
        // You might want to navigate the user to a sign-in screen or another appropriate screen in this case
        // await authService.clearStoredData();
        Get.deleteAll(force: true);
        Get.offAll(() => const LoginScreen());
      }

      // Save the updated list of accounts to SharedPreferences
      final accountsJson = jsonEncode(
          userAccounts.map((account) => account.toString()).toList());
      await prefs.setString('accounts', accountsJson);
      await prefs.setInt('currentAccountIndex', currentAccountIndex);

      // Call Google Sign-In's signOut method
      // Note: This will sign out the current Google user. If you need more granular control,
      // you might need to use the Google People API or a similar API to revoke access for specific accounts.
      await authService.googleSignIn.signOut();

      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      print(e.toString());
    }
  }

  Future<void> trashMessage(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/trash'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      gmailDetail.removeWhere((element) => element.id == messageId);
      update();
    } else {
      throw Exception('Failed to move message to Trash');
    }
  }

  String getFormattedDate(int dateValue) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateValue);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.isAfter(today)) {
      return DateFormat('h:mm a').format(dateTime);
    } else {
      return DateFormat('d MMM').format(dateTime);
    }
  }

  Future discardGmailDraft(String draftId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isLoading = true;
    update();

    final response = await http.post(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$draftId/trash'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      isLoading = false;
      update();
    } else {
      isLoading = false;
      update();
      throw Exception('Failed to discard draft');
    }
  }
}
