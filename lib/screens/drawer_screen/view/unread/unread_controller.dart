import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:simplemail/utils/url_config.dart';

class UnreadController extends GetxController {
  // String apiKey = UrlConstants.apiKeyValue;

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

  // int selectedIndex = 0;
  // List<String> drawerListTitles = [
  //   "Inbox",
  //   "Starred",
  //   "Important",
  //   "Sent",
  //   "Drafts",
  //   "Unread",
  //   "Personal",
  //   "Social",
  //   "Promotions",
  //   "Spam",
  //   "Bin",
  //   "Settings",
  //   "Help & Feedback",
  // ];

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

  // void setSelectedIndex(int index) {
  //   selectedIndex = index;
  //   title = drawerListTitles[index];
  //   update();
  // }

  // Color? getTileColor(int index) {
  //   if (index == selectedIndex) {
  //     return Colors.blue;
  //   } else {
  //     return null;
  //   }
  // }

  loadGmailApis(String lable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString('token');
    await fetchInboxMessages();
  }

  Future fetchInboxMessages() async {
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
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=UNREAD')
          : Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=UNREAD&pageToken=$nextPageToken');

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/1/unread_messages_$nextPageToken.json';
      final file = File(filePath);

      if (file.existsSync()) {
        print('file');
        final response = await file.readAsString();
        final data = json.decode(response);
        debugPrint('<----------------next page token $nextPageToken');

        allInboxMessages = Allmessages.fromJson(data);

        nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";

        await fetchStartingGmails();
      } else {
        print('notfile');

        final networkResponse = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

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
    } catch (e) {
      isLoading = false;
      update();
      throw Exception('Failed to load messages');
    }
  }

  Future<void> executeInBackground() async {
    final directory = await getTemporaryDirectory();
    final inboxDir = Directory('${directory.path}/1');

    final files = inboxDir.listSync();

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
        print('inmessageFile');
        final response = await file.readAsString();
        final data = json.decode(response);

        final message = GmailMessage.fromJson(data);
        listUntillLoading.add(message);
        if (message.labelIds!.contains('UNREAD')) {
          unreadGmailDetails.add(message);
        }

        return message;
      } else {
        print('notMessageFile');

        final networkResponse = await http.get(url, headers: {
          'Authorization': 'Bearer $token',
        });

        if (networkResponse.statusCode == 200) {
          final data = networkResponse.body;

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

  summariseAllUnreadEmails(List<GmailMessage> unreadGmailDetails) async {
    List<Sumrise> summaryEmails = [];
    for (int i = 0; i < unreadGmailDetails.length; i++) {
      try {
        String mailText = utf8.decode(base64.decode(
            unreadGmailDetails[i].payload?.parts?[0].body?.data ?? " "));
        Sumrise result =
            await summariseAllEmail('', mailText, unreadGmailDetails[i]);
        summaryEmails.add(result);
      } catch (E) {
        print(E.toString());
      }
    }
    return summaryEmails;
  }

  Future<Sumrise> summariseAllEmail(
      String prompt, String emailBody, GmailMessage currntEmailData) async {
    // var url = Uri.https(UrlConstants.baseUrl, UrlConstants.completionUrl);
    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //       "Authorization": "Bearer $apiKey"
    //     },
    //     body: json.encode({
    //       "model": "text-davinci-003",
    //       "prompt":
    //           "Extract key points from the Email.\n$emailBody\nkey points:",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String? summaryText = newresponse['choices'][0]['text'] ?? ' ';
    //   return Sumrise(
    //       currntEmailData.payload?.headers
    //               ?.where((element) => element.name == "From")
    //               .toList()
    //               .first
    //               .value!
    //               .toString()
    //               .split(RegExp(r'[<>]'))
    //               .first ??
    //           '',
    //       currntEmailData.payload?.headers
    //               ?.where((element) => element.name == "Subject")
    //               .toList()
    //               .first
    //               .value ??
    //           '',
    //       '',
    //       summaryText!);
    // } catch (e) {
    //   print(e.toString());
    return Sumrise('', '', '', ' ');
    // }
  }

  String getFormattedDate(int dateValue) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateValue);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.isAfter(today)) {
      return DateFormat('h:mm a').format(dateTime);
    } else {
      return DateFormat('d MMMM').format(dateTime);
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

  Future sendGmailMessage(String to, String from, String cc, String bcc,
      String subject, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    try {
      final Uri url = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/send');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final String ccHeader = cc != null ? 'Cc: $cc\r\n' : '';
      final String bccHeader = bcc != null ? 'Bcc: $bcc\r\n' : '';
      final String emailContent = 'To: $to\r\n'
          '$ccHeader'
          '$bccHeader'
          'Subject: $subject\r\n'
          '\r\n'
          '$body';
      final String encodedEmail = base64Url.encode(utf8.encode(emailContent));
      final Map<String, String> jsonBody = {'raw': encodedEmail};
      final http.Response response =
          await http.post(url, headers: headers, body: json.encode(jsonBody));
      print(response.body);

      isLoading = false;
      update();
      if (response.statusCode != 200) {
        print('Failed to send message');
      }
    } catch (e) {
      print(e);
      isLoading = false;
      update();
      throw Exception('Failed to send message');
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

class Sumrise {
  String from;
  String subject;
  String name;
  String data;
  Sumrise(this.from, this.subject, this.name, this.data);
}
