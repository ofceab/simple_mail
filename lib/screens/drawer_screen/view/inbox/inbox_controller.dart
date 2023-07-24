import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/screens/login_screen/view/login_screen.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:simplemail/utils/url_config.dart';

class InboxController extends GetxController {
  // String apiKey = UrlConstants.apiKeyValue;
  String? token;
  bool isLoading = false;
  bool isRefreshing = false;
  int currentAccountIndex = 0;

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
  final userAccounts = <Account>[].obs;

  @override
  void onInit() async {
    super.onInit();
    //  await loadUserAccounts();
    // if (userAccounts.isNotEmpty) {
    //   token = userAccounts.first.token;
    await loadCurrentAccountIndex();
    loadGmailApis('INBOX');
    loadAccounts();
    // }
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

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/1/inbox_messages_$nextPageToken.json';
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

          // Save the data in cache
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

  // Future fetchInboxMessages() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token');
  //   try {
  //     if (nextPageToken != null && nextPageToken!.isNotEmpty) {
  //       if (nextPageToken!.contains("FINISHED")) {
  //         isLoading = false;
  //         update();
  //         return;
  //       }
  //     }
  //     isLoading = true;
  //     update();
  //     final url = (nextPageToken == null && gmailDetail.isEmpty)
  //         ? Uri.parse(
  //             'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=INBOX')
  //         : Uri.parse(
  //             'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=INBOX&pageToken=$nextPageToken');

  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     final data = json.decode(response.body);
  //     debugPrint('<----------------next page token $nextPageToken');
  //     if (response.statusCode == 200) {
  //       allInboxMessages = Allmessages.fromJson(data);
  //       nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
  //       await fetchStartingGmails();
  //     } else if (data['error']['code'] == 401) {
  //       Get.put(AuthService()).refreshToken();
  //       fetchInboxMessages();
  //     }
  //   } catch (e) {
  //     isLoading = false;
  //     update();
  //     throw Exception('Failed to load messages');
  //   }
  // }

  fetchStartingGmails() async {
    listUntillLoading = [];
    for (int i = 0; i < allInboxMessages.messages!.length; i++) {
      print(allInboxMessages.messages![i].id!);
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

  Future<GmailMessage> fetchGmailMessage(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId');
    try {
      final networkResponse = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      if (networkResponse.statusCode == 200) {
        final data = networkResponse.body;
        final decodedData = json.decode(data);
        final message = GmailMessage.fromJson(decodedData);
        return message;
      } else {
        throw Exception('Failed to load message details');
      }
    } catch (e) {
      throw Exception('Failed to load message details');
    }
  }

  //<--------------------Fetch details of a Gmail message
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

          // Save the data in a temporary file
          await file.writeAsString(data);

          final decodedData = json.decode(data);
          print(decodedData);
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

  Future<Uint8List> fetchAttachmentImage(
      String messageId, String attachmentId) async {
    final url =
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/attachments/$attachmentId';
    final headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      return base64Url.decode(data);
    } else {
      throw Exception('Failed to fetch attachment');
    }
  }

  Future<String?> fetchImage(String messageId, String? attachmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    final url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/attachments/$attachmentId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(response.body);
    print(data.toString());
    if (response.statusCode == 200) {
      final fileData = data['data'];
      print(fileData.toString());
      // Convert the base64url-encoded string to a data URL.
      return 'data:image/jpeg;base64,' + fileData;
    } else {
      throw Exception('Failed to load attachment');
    }
  }

  Future<Uint8List?> fetchAttachment(
      String messageId, String? attachmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    // try {
    final url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/attachments/$attachmentId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = json.decode(response.body);

    print('fected data here');
    print(data);
    if (response.statusCode == 200) {
      final fileData = data['data'];
      // fileData is a base64url-encoded string that represents the file data
      // You can decode it with base64Url.decode(fileData)
      return base64Url.decode(fileData);
    }
    // else if (data['error']['code'] == 401) {
    //   Get.put(AuthService()).refreshToken();
    //   return fetchAttachment(messageId, attachmentId);
    // }
    else {
      throw Exception('Failed to load attachment');
    }
    // return null;
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

  Future<void> starMessage(
      {required String messageId,
      context,
      required int index,
      bool updateList = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
        'https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId/modify');
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'addLabelIds': ['STARRED'],
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      print('Message $messageId marked as seen');
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/1/message_$messageId.json';
      final file = File(filePath);

      try {
        if (file.existsSync()) {
          final response = await file.readAsString();
          final data = json.decode(response);

          final message = GmailMessage.fromJson(data);

          message.labelIds!.add('STARRED');

          final updatedJson = json.encode(message.toJson());

          await file.writeAsString(updatedJson);
        }
      } catch (e) {
        throw Exception('Failed to load message details');
      }
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to star message');
    } else {
      if (updateList) {
        GmailMessage message = await fetchGmailMessage(messageId);
        gmailDetail[index] = message;
        update();
      }
      final snackBar = SnackBar(
        content: const Text(
          'Message successfully starred ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      print('Message successfully starred');
    }
  }

  Future<void> removeStarMessage(
      {required String messageId,
      context,
      required int index,
      bool updateList = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
        'https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId/modify');
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'removeLabelIds': [
        'STARRED'
      ], // Use 'removeLabelIds' instead of 'addLabelIds'
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    // if (response.statusCode == 200) {
    //   print('Message $messageId marked as seen');
    //   final directory = await getTemporaryDirectory();
    //   final filePath = '${directory.path}/1/message_$messageId.json';
    //   final file = File(filePath);

    //   try {

    //     if (file.existsSync()) {

    //       final response = await file.readAsString();
    //       final data = json.decode(response);

    //       final message = GmailMessage.fromJson(data);

    //       if (message.labelIds!.contains('STARRED')) {
    //         message.labelIds!.remove('STARRED');
    //       }

    //       final updatedJson = json.encode(message.toJson());

    //       await file.writeAsString(updatedJson);
    //       update();
    //     }
    //   } catch (e) {
    //     update();
    //     throw Exception('Failed to load message details');
    //   }
    // }
    if (response.statusCode != 200) {
      throw Exception('Failed to remove starred label from message');
    } else {
      if (updateList) {
        GmailMessage message = await fetchGmailMessage(messageId);
        gmailDetail[index] = message;
        update();
      }
      final snackBar = SnackBar(
        content: const Text(
          'Remove starred label',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      print('Starred label successfully removed from message');
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
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/1/message_$messageId.json';
      final file = File(filePath);
      if (await file.exists()) {
        print(messageId);
        await file.delete();
        print('File deleted');
        final filePath = '${directory.path}/1/inbox_messages_null.json';
        final folderfile = File(filePath);

        if (await folderfile.exists()) {
          final response = await file.readAsString();
          print(await file.readAsString());
          final data = json.decode(response);
          allInboxMessages = Allmessages.fromJson(data);
          allInboxMessages.messages!
              .remove((element) => element.id == messageId);
          final updatedJson = json.encode(allInboxMessages.toJson());
          print('alldone');
          await file.writeAsString(updatedJson);
        }
      } else {
        print('File not found');
      }

      // Write the updated list to the all-messages cache file
      final allMessagesFilePath =
          '${directory.path}/1/inbox_messages_null.json';
      final allMessagesFile = File(allMessagesFilePath);
      final updatedAllMessagesJson =
          json.encode(gmailDetail.map((message) => message.toJson()).toList());
      await allMessagesFile.writeAsString(updatedAllMessagesJson);

      update();
    }
  }

  Future<Uint8List> getAttachment(String messageId, String attachmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final url =
        'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/attachments/$attachmentId';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      return base64Url.decode(data);
    } else {
      throw Exception('Failed to download attachment');
    }
  }

  Future<List<String>> fetchThreadList(String threadId) async {
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

  // Future<List<dynamic>> fetchThreadDetails(String threadId) async {
  //   isLoading = true;
  //   update();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token');
  //   print('thread id here ');
  //   print(threadId);
  //   final Uri url = Uri.parse(
  //       'https://www.googleapis.com/gmail/v1/users/me/threads/$threadId');
  //   final Map<String, String> headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };

  //   try {
  //     final http.Response response = await http.get(url, headers: headers);
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to fetch thread details');
  //     }
  //     final jsonResponse = json.decode(response.body);
  //     print('message detail=============ss afor thread');
  //     print(threadId);
  //     // print(jsonResponse);
  //     print(jsonResponse['messages']);
  //     final messages = jsonResponse['messages'];
  //     List<dynamic> messageDetails = messages.map((message) {
  //       String messageId = message['id'];
  //       String snippet = message['snippet'];
  //       List<dynamic> headers = message['payload']['headers'];
  //       String subject = headers
  //           .firstWhere((header) => header['name'] == 'Subject')['value'];
  //       String from =
  //           headers.firstWhere((header) => header['name'] == 'From')['value'];
  //       String to =
  //           headers.firstWhere((header) => header['name'] == 'To')['value'];
  //       return {
  //         'messageId': messageId,
  //         'snippet': snippet,
  //         'subject': subject,
  //         'from': from,
  //         'to': to,
  //       };
  //     }).toList();
  //     isLoading = false;
  //     update();

  //     return messageDetails;
  //   } catch (e) {
  //     isLoading = false;
  //     update();
  //     print(e);
  //     throw Exception('Failed to fetch thread details');
  //   }
  // }

}
