import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:intl/intl.dart';


class BinController extends GetxController {
  String? token;
  bool isLoading = false;
  bool isRefreshing = false;
  
  bool isListMoreLoading = false;
  String forDrawerApiLable = 'INBOX';
  String title = 'All Inbox';
  var myDate = DateTime.now();
  Allmessages allInboxMessages = Allmessages();
  GmailMessage gmailMessage = GmailMessage();

  List<GmailMessage> gmailDetail = [];
  List<GmailMessage> listUntillLoading = [];
  List<GmailMessage> primaryDetail = [];

  Allmessages allUnreadInboxMessages = Allmessages();

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

  //= 2 nd p ye call hoga
  loadGmailApis(String lable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString('token');
    // token k ander value pref se aaegi
    await fetchInboxMessages();
  }

  //fetch all inbox list

  Future fetchInboxMessages() async {
    noMail = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    // print('<-------------------auth toke $token');
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
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=TRASH')
          : Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=TRASH&pageToken=$nextPageToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);

      allInboxMessages = Allmessages.fromJson(data);

      nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
      print('<----------------next page token $nextPageToken');
      if (response.statusCode == 200) {
        await fetchStartingGmails();
      } else if (data['error']['code'] == 401) {
        Get.put(AuthService()).refreshToken();
        fetchInboxMessages();
      }
    } catch (e) {
      isLoading = false;
      update();
      print('error');
      print(e.toString());
      throw Exception('Failed to load messages');
    }
  }

  // ek ek msg ki details
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

  //<--------------------Fetch details of a Gmail message
  Future<GmailMessage> fetchGmailMessageDetails(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isLoading = true;
    update();

    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = GmailMessage.fromJson(data);
      // Add message to list
      listUntillLoading.add(message);
      if (message.labelIds!.contains('UNREAD')) {
        unreadGmailDetails.add(message);
        print('unread gmail details');
        print(unreadGmailDetails);
      }
      return message;
    } else {
      isLoading = false;
      update();

      throw Exception('Failed to load message details');
    }
  }




// ...

// void retrieveMessageDetails(GmailMessage message) {
//   // Retrieve the subject of the message
//   String subject = message.payload!.headers!
//       .firstWhere((header) => header.name == 'Subject', orElse: () => Header())
//       .value ?? '';

//   // Retrieve the date the message was sent
//   String date = message.payload!.headers!
//       .firstWhere((header) => header.name == 'Date', orElse: () => Header())
//       .value ?? '';

//   // Retrieve the cc recipients of the message
//   List<String> ccRecipients = message.payload!.headers!
//       .where((header) => header.name == 'Cc')
//       .map((header) => header.value ?? '')
//       .toList();

//   // Retrieve the bcc recipients of the message
//   List<String> bccRecipients = message.payload!.headers!
//       .where((header) => header.name == 'Bcc')
//       .map((header) => header.value ?? '')
//       .toList();

//   // Print the retrieved details
//   print('Subject: $subject');
//   print('Date: $date');
//   print('Cc: ${ccRecipients.join(', ')}');
//   print('Bcc: ${bccRecipients.join(', ')}');
// }



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

  Future<void> deleteMessage(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      gmailDetail.removeWhere((element) => element.id == messageId);
      update();
    } else {
      throw Exception('Failed to delete message');
    }
  }


  Future<void> restoreMessage(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    // Retrieve the message's original label IDs
    final labelResponse = await http.get(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    List<String> labelIds =
        List<String>.from(json.decode(labelResponse.body)['labelIds']);

    print('labelIds');
    print(labelIds);
    // Add the label IDs back to the message
    final modifyResponse = await http.post(
      Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/modify'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'addLabelIds': ['INBOX']}),
    );

    if (modifyResponse.statusCode == 200) {
      
      // Update the UI or perform any other necessary tasks
      print('Message restored successfully');
      // Untrash the message
      final response = await http.post(
        Uri.parse(
            'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/untrash'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('response');
      print(response);

      
      if (response.statusCode == 200) {
       
      } else {
        throw Exception('Failed to restore message from trash');
      }
    } else {
      throw Exception('Failed to add label IDs back to message');
    }
  }

  Future discardDraftMessage(String draftId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isLoading = true;
    update();
    try {
      final url = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/drafts/$draftId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      isLoading = false;
      update();
      if (response.statusCode == 204) {
        print('Draft message discarded successfully.');
      } else {
        print('Failed to discard draft message.');
      }
    } catch (e) {
      isLoading = false;
      update();
      print('Failed to discard draft message.');
      print(e.toString());
      throw Exception('Failed to discard draft message.');
    }
  }
}
