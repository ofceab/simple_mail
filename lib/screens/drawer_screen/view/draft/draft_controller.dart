import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/all_message.dart';
import 'package:simplemail/Models/drafts_message.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:intl/intl.dart';

class DraftController extends GetxController {
  String? token;
  bool isLoading = false;
  bool isRefreshing = false;

  bool isListMoreLoading = false;
  Allmessages allInboxMessages = Allmessages();
  GmailMessage gmailMessage = GmailMessage();

  List<GmailMessage> gmailDetail = [];
  List<GmailMessage> listUntillLoading = [];
  List<GmailMessage> primaryDetail = [];
  DraftMessages draftMessages = DraftMessages();

  Allmessages allUnreadInboxMessages = Allmessages();

  List<GmailMessage> unreadGmailDetails = [];
  String? nextPageToken;
  String currentTabAPI = 'INBOX';
  bool noMail = false;

  @override
  void onInit() async {
    super.onInit();
    loadGmailApis('INBOX');
    fetchDrafts();
  }

  changeRefreshing(bool value) {
    isRefreshing = value;
    update();
  }

  moreListCalling() {
    isListMoreLoading = true;
    update();
  }

  //= 2 nd p ye call hoga
  loadGmailApis(String lable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString('token');
    // token k ander value pref se aaegi
    await fetchInboxMessages();
  }

  Future fetchDrafts() async {
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
          ? Uri.parse('https://www.googleapis.com/gmail/v1/users/me/drafts')
          : Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=DRAFT&pageToken=$nextPageToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      draftMessages = DraftMessages.fromJson(data);
      nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
      print('<----------------next page token $nextPageToken');
      if (response.statusCode == 200) {
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

  //fetch all inbox list
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
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=DRAFT')
          : Uri.parse(
              'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=DRAFT&pageToken=$nextPageToken');

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/1/draft_messages_$nextPageToken.json';
      final file = File(filePath);

      if (file.existsSync()) {
        print('file');
        final response = await file.readAsString();
        final data = json.decode(response);

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
  //   noMail = false;
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
  //             'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=DRAFT')
  //         : Uri.parse(
  //             'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=15&labelIds=DRAFT&pageToken=$nextPageToken');

  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     final data = json.decode(response.body);
  //     allInboxMessages = Allmessages.fromJson(data);
  //     nextPageToken = allInboxMessages.nextPageToken ?? "FINISHED";
  //     print('<----------------next page token $nextPageToken');
  //     if (response.statusCode == 200) {
  //       await fetchStartingGmails();
  //     } else if (data['error']['code'] == 401) {
  //       Get.put(AuthService()).refreshToken();
  //       fetchInboxMessages();
  //     }
  //   } catch (e) {
  //     isLoading = false;
  //     update();
  //     print('error');
  //     print(e.toString());
  //     throw Exception('Failed to load messages');
  //   }
  // }

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

  Future sendDraftMessage(String draftId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    try {
      final Uri url = Uri.parse(
          'https://www.googleapis.com/gmail/v1/users/me/drafts/$draftId/send');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.post(url, headers: headers);
      print(response.body);

      isLoading = false;
      update();
      if (response.statusCode != 200) {
        print('Failed to send draft message');
      }
    } catch (e) {
      print(e);
      isLoading = false;
      update();
      throw Exception('Failed to send draft message');
    }
  }

  Future<void> createDraftMessage(
      String to, String cc, String bcc, String subject, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print(
          'Token not found. Make sure to authenticate before creating a draft.');
      return;
    }

    final url =
        Uri.parse('https://www.googleapis.com/gmail/v1/users/me/drafts');

    const mimeBoundary = 'boundary-example';
    final mimeMessage = '''
MIME-Version: 1.0
To: $to
Cc: $cc
Bcc: $bcc
Subject: $subject
Content-Type: multipart/alternative; boundary=$mimeBoundary

--$mimeBoundary
Content-Type: text/plain; charset="UTF-8"

$body

--$mimeBoundary
Content-Type: text/html; charset="UTF-8"

<html>
<body>
  <p>$body</p>
</body>
</html>
--$mimeBoundary--
''';

    final draftMessage = {
      'message': {
        'raw': base64Url.encode(utf8.encode(mimeMessage)),
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(draftMessage),
    );

    if (response.statusCode == 200) {
      print('Draft message created successfully!');
    } else {
      print('Failed to create draft message. Error: ${response.body}');
    }
  }
// Future<void> createDraftMessage(String to, String subject, String body) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');
//   if (token == null) {
//     print('Token not found. Make sure to authenticate before creating a draft.');
//     return;
//   }

//   final url = Uri.parse('https://www.googleapis.com/gmail/v1/users/me/drafts');

//   final draftMessage = {
//     'message': {
//       'raw': base64Url.encode(utf8.encode('To: $to\r\nSubject: $subject\r\n\r\n$body')),
//     }
//   };

//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     },
//     body: json.encode(draftMessage),
//   );

//   if (response.statusCode == 200) {
//     print('Draft message created successfully!');
//   } else {
//     print('Failed to create draft message. Error: ${response.body}');
//   }
// }

  Future<void> createNewDraftMessage(String to, String subject, String body,
      {String? draftId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print(
          'Token not found. Make sure to authenticate before creating or updating a draft.');
      return;
    }

    final url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/me/drafts' +
            (draftId != null ? '/$draftId' : ''));

    final draftMessage = {
      'message': {
        'raw': base64Url
            .encode(utf8.encode('To: $to\r\nSubject: $subject\r\n\r\n$body')),
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(draftMessage),
    );

    if (response.statusCode == 200) {
      if (draftId != null) {
        print('Draft message updated successfully!');
      } else {
        print('Draft message created successfully!');
      }
    } else {
      print(
          'Failed to create or update draft message. Error: ${response.body}');
    }
  }

  Future<void> updateDraft(String draftId, String to, String cc, String bcc,
      String from, String subject, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');
    if (token == null || userId == null) {
      // Handle missing token or user ID
      return;
    }

    final url = Uri.parse(
        'https://www.googleapis.com/gmail/v1/users/$userId/drafts/$draftId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Create the updated draft payload
    final updatedDraft = {
      'message': {
        'raw': base64Url.encode(utf8.encode(createEmail(to, subject, body))),
      },
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(updatedDraft),
      );

      if (response.statusCode == 200) {
        print('Draft updated successfully.');
      } else {
        print('Failed to update draft.');
      }
    } catch (e) {
      print('Failed to update draft: $e');
    }
  }

  String createEmail(String to, String subject, String body) {
    final email = 'Content-Type: text/plain; charset=utf-8\r\n'
        'MIME-Version: 1.0\r\n'
        'From: Your Name <yourname@gmail.com>\r\n'
        'To: $to\r\n'
        'Subject: $subject\r\n\r\n'
        '$body';

    return email;
  }

// Future<void> createDraftMessage(String to, String subject, String body) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//    token = prefs.getString('token');
//   if (token == null) {
//     print('Token not found. Make sure to authenticate before creating a draft.');
//     return;
//   }

//   // Set isLoading to true if it's a state variable you use for UI purposes
//   // isLoading = true;
//   // update();

//   final url = Uri.parse('https://www.googleapis.com/gmail/v1/users/me/drafts');

//   final draftMessage = {
//     'message': {
//       'to': [{'email': to}],
//       'subject': subject,
//       'body': {'text': body},
//     }
//   };

//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     },
//     body: json.encode(draftMessage),
//   );

//   if (response.statusCode == 200) {
//     print('Draft message created successfully!');
//   } else {
//     print('Failed to create draft message. Error: ${response.body}');
//   }

//   // Set isLoading to false if it's a state variable you use for UI purposes
//   // isLoading = false;
//   // update();
// }

  Future discardDraftMessage(Draft draftMessages, String draftId) async {
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
        gmailDetail.removeWhere((element) => element.id == draftMessages.id);
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
