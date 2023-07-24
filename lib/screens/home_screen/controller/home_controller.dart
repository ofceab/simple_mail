import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  String? token;
  bool isLoading = false;
  bool isListMoreLoading = false;
  String forDrawerApiLable = 'INBOX';
  String title = 'All Inbox';
  var myDate = DateTime.now();
  Allmessages allInboxMessages = Allmessages();
  Message message = Message();
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

  Future<void> replyToGmailMessage(String threadId, String messageId, String to,
      String from, String cc, String bcc, String subject, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Access token not found');
    }
    try {
      final Uri url = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/send');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final String ccHeader = cc.isNotEmpty ? 'Cc: $cc\r\n' : '';
      final String bccHeader = bcc.isNotEmpty ? 'Bcc: $bcc\r\n' : '';
      final String inReplyToHeader = 'In-Reply-To: $messageId\r\n';
      final String referencesHeader = 'References: $messageId\r\n';
      final String emailContent = 'To: $to\r\n'
          'From: $from\r\n'
          '$ccHeader'
          '$bccHeader'
          'Subject: $subject\r\n'
          '$inReplyToHeader'
          '$referencesHeader'
          '\r\n'
          '$body';
      final String encodedEmail = base64Url.encode(utf8.encode(emailContent));
      final Map<String, dynamic> jsonBody = {
        'raw': encodedEmail,
        'threadId': threadId,
      };
      final http.Response response =
          await http.post(url, headers: headers, body: json.encode(jsonBody));
      print(response.body);
      print(threadId);
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

  Future<void> forwardGmailMessage(String threadId, String messageId, String to,
      String from, String cc, String bcc, String subject, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Access token not found');
    }
    try {
      final Uri getEmailUrl = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId');
      final Map<String, String> getHeaders = {
        'Authorization': 'Bearer $token',
      };
      final http.Response getEmailResponse =
          await http.get(getEmailUrl, headers: getHeaders);
      if (getEmailResponse.statusCode != 200) {
        throw Exception('Failed to get message');
      }
      final Map<String, dynamic> getEmailJsonBody =
          json.decode(getEmailResponse.body);
      final String originalBody = getEmailJsonBody['payload']['body']['data'];

      final Uri url = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages/send');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final String ccHeader = cc.isNotEmpty ? 'Cc: $cc\r\n' : '';
      final String bccHeader = bcc.isNotEmpty ? 'Bcc: $bcc\r\n' : '';
      final String emailContent = 'To: $to\r\n'
          'From: $from\r\n'
          '$ccHeader'
          '$bccHeader'
          'Subject: Fwd: $subject\r\n'
          '\r\n'
          '---------- Forwarded message ---------\r\n'
          'From: $from\r\n'
          'Date: ...\r\n'
          'Subject: $subject\r\n'
          'To: $to\r\n'
          '\r\n'
          '$body'
          '\r\n'
          '$originalBody';
      final String encodedEmail = base64Url.encode(utf8.encode(emailContent));
      final Map<String, dynamic> jsonBody = {
        'raw': encodedEmail,
      };

      final http.Response response =
          await http.post(url, headers: headers, body: json.encode(jsonBody));
      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to send message');
    }
  }

  Future<List<String>> fetchThreadList() async {
    List<GmailMessage> messages = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final Uri url =
        Uri.parse('https://www.googleapis.com/gmail/v1/users/me/threads');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final http.Response response = await http.get(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch threads');
      }
      final jsonResponse = json.decode(response.body);
      final List<dynamic> threads = jsonResponse['threads'];
      List<String> threadIds =
          threads.map((thread) => thread['id'] as String).toList();
      return threadIds;
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch threads');
    }
  }

  Future<List<GmailMessage>> fetchThreadDetails(String threadId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final Uri url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/threads/$threadId');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode != 200) {
        switch (response.statusCode) {
          case 401:
            throw Exception('Access token is invalid');
          case 403:
            throw Exception('Access token does not have necessary permissions');
          default:
            throw Exception(
                'Failed to fetch thread details with status code: ${response.statusCode}');
        }
      }

      final jsonResponse = json.decode(response.body);
      List<GmailMessage> messages = [];

      if (jsonResponse.containsKey('messages')) {
        List<dynamic> messageData = jsonResponse['messages'];
        messages = messageData
            .map((message) => GmailMessage.fromJson(message))
            .toList();
      } else {
        GmailMessage message = GmailMessage.fromJson(jsonResponse);
        messages.add(message);
      }

      return messages;
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch thread details');
    }
  }
}
