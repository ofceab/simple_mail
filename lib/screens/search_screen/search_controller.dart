import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:simplemail/utils/url_config.dart';

class SearchController extends GetxController {
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
  List<GmailMessage> listUntillLoading = [];
  List<GmailMessage> gmailDetail = [];
  List<GmailMessage> unreadGmailDetails = [];
  List<Payload>? images;
  List<Payload>? attachments;
  String? nextPageToken;
  String currentTabAPI = 'INBOX';
  ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    loadGmailApis('INBOX');
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading) {
        moreListCalling();
        fetchInboxMessages();
      }
    }
  }

  void performSearch(String query) async {
    isLoading = true;
    update();
    final results = await searchEmails(query);
    gmailDetail = results;
    isLoading = false;
    update();
  }

  Future<List<GmailMessage>> searchEmails(String query) async {
    List<GmailMessage> messages = [];
    String? token;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    try {
      final url = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/messages?q=$query&maxResults=15');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> messageItems = data['messages'] ?? [];

        for (var msg in messageItems) {
          var messageResponse = await fetchGmailMessageDetails(msg['id']);
          messages.add(messageResponse);
        }
      } else if (response.statusCode == 401) {
        Get.put(AuthService()).refreshToken();
        return searchEmails(query);
      } else {
        throw Exception('Failed to search messages');
      }
    } catch (error) {
      print("Error in searchEmails: $error");
    }

    return messages;
  }

  @override
  void load() async {
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

  loadGmailApis(String lable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      print(token);
      await fetchInboxMessages();
    } else {
      Get.put(AuthService()).refreshToken();
    }
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
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=INBOX')
          : Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=INBOX&pageToken=$nextPageToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      debugPrint('<----------------next page token $nextPageToken');
      if (response.statusCode == 200) {
        allInboxMessages = Allmessages.fromJson(data);
        nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
        await fetchStartingGmails();
      } else if (data['error']['code'] == 401) {
        Get.put(AuthService()).refreshToken();
        fetchInboxMessages();
      }
    } catch (e) {
      isLoading = false;
      update();
      throw Exception('Failed to load messages');
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
    // getmessagedata();
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

      listUntillLoading.add(message);
      if (message.labelIds!.contains('UNREAD')) {
        unreadGmailDetails.add(message);
      }

      return message;
    } else {
      isLoading = false;
      update();

      throw Exception('load message details');
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
}
