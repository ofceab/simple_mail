import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:simplemail/Models/email_reply.dart';

import '../../../utils/url_config.dart';

class ComposeController extends GetxController {
  String apiKey = UrlConstants.apiKeyValue;
  bool showSend = false;
  showSendFuc(bool value) {
    showSend = value;
    update();
  }

  Future composeMail(String prompt, String emailBody) async {
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
    //           "INSTRUCTION: Rewrite and extend the INPUT into a professional sophisticated style email using complicated grammar, including greeting and subject line, Do not miss any key points,include good wishes. and body do not include a signature.\n\nInput:\n\"$emailBody\"\n\nOutput:\n",
    //       "max_tokens": 400,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //       "best_of": 3,
    //     }),
    //   );

    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();
    //   return summaryText;
    // } catch (e) {
    //   print('Compose controller error write email ======');
    //   print(e.toString());
    //   return;
    // }
  }

  Future regenrateEmail(String senderEmail, String emailBody) async {
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
    //           "\n\nInstruction: $senderEmail rewrite the above email replying to $emailBody with a professional sophisticated writing style including a salutation, and a body, do not include a signature. The reply email should be very detailed about each point.\n****\n",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();
    //   return summaryText;
    // } catch (e) {
    //   print('Compose controller error regenrate email ======');
    //   print(e.toString());
    //   return;
    // }
  }

  Future summariseEmail(String prompt, String emailBody) async {
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
    //   print('summraize reply ');
    //   print(summaryText);
    //   return summaryText;
    // } catch (e) {
    //   print('Compose controller error summraize email ======');
    //   print(e.toString());
    //   return ' ';
    // }
  }

  Future aiReply(String senderEmail, String emailBody) async {
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
    //       "prompt": '' "\n\nInstruction: " +
    //           senderEmail +
    //           " has sent the above email to me. Write a " +
    //           '' +
    //           " email reply to " +
    //           emailBody +
    //           " with a professional sophisticated writing style including a salutation, and a body does not include a signature. The reply email should be very detailed about each point.\n****\n",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();
    //   return summaryText;
    // } catch (e) {
    //   print('Compose controller error regenrate email ======');
    //   print(e.toString());
    //   return;
    // }
  }

  Future positive(String senderEmail, String emailBody, String positive) async {
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
    //       "prompt": '' "\n\nInstruction: " +
    //           senderEmail +
    //           " has sent the above email to me. Write a " +
    //           positive +
    //           " email reply to " +
    //           emailBody +
    //           " with a professional sophisticated writing style including a salutation, and with a subject line and a body does not include a signature. The reply email should be very detailed about each point.\n****\n",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();
    //   String text = summaryText;
    //   List<String> emailLines = text.split("\n");
    //   String subject = '';
    //   String emailContent = "";
    //   for (String line in emailLines) {
    //     if (line.startsWith("Subject:")) {
    //       subject = line.substring(8);
    //     } else {
    //       emailContent += "$line\n";
    //     }
    //   }
    //   EmailReply emailReply = EmailReply(email: emailContent, subject: subject);
    //   return emailReply;
    // } catch (e) {
    //   return;
    // }
  }

  Future negative(String senderEmail, String emailBody, String nagative) async {
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
    //       "prompt": '' "\n\nInstruction: " +
    //           senderEmail +
    //           " has sent the above email to me. Write a " +
    //           nagative +
    //           " email reply to " +
    //           emailBody +
    //           " with a professional sophisticated writing style including a salutation,  and with a subject line and a body does not include a signature. The reply email should be very detailed about each point.\n****\n",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();

    //   String text = summaryText;
    //   List<String> emailLines = text.split("\n");

    //   String subject = '';
    //   String emailContent = "";
    //   for (String line in emailLines) {
    //     if (line.startsWith("Subject:")) {
    //       subject = line.substring(8);
    //     } else {
    //       emailContent += "$line\n";
    //     }
    //   }
    //   EmailReply emailReply = EmailReply(email: emailContent, subject: subject);
    //   return emailReply;
    // } catch (e) {
    //   return;
    // }
  }

  Future netural(String senderEmail, String emailBody, String neutral) async {
    var url = Uri.https(UrlConstants.baseUrl, UrlConstants.completionUrl);
    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //       "Authorization": "Bearer $apiKey"
    //     },
    //     body: json.encode({
    //       "model": "text-davinci-003",
    //       "prompt": '' "\n\nInstruction: " +
    //           senderEmail +
    //           " has sent the above email to me. Write a " +
    //           neutral +
    //           " email reply to " +
    //           emailBody +
    //           " with a professional sophisticated writing style including a salutation, and with a subject line and a body does not include a signature. The reply email should be very detailed about each point.\n****\n",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();

    //   String text = summaryText;
    //   List<String> emailLines = text.split("\n");

    //   String subject = '';
    //   String emailContent = "";
    //   for (String line in emailLines) {
    //     if (line.startsWith("Subject:")) {
    //       subject = line.substring(8);
    //     } else {
    //       emailContent += "$line\n";
    //     }
    //   }
    //   EmailReply emailReply = EmailReply(email: emailContent, subject: subject);
    //   return emailReply;
    // } catch (e) {
    //   return;
    // }
  }

  Future customReply(String senderEmail, String emailBody) async {
    var url = Uri.https(UrlConstants.baseUrl, UrlConstants.completionUrl);
    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //       "Authorization": "Bearer $apiKey"
    //     },
    //     body: json.encode({
    //       "model": "text-davinci-003",
    //       // ignore: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings
    //       "prompt": '' +
    //           "\n\nInstruction:" +
    //           senderEmail +
    //           " has sent the above email to me. Write a reply email in detail to " +
    //           emailBody +
    //           " for the given Input with a professional writing style including a subject, a salutation and a body do not include a signature.\nInput:\n\"" +
    //           '' +
    //           "\"\n****\n",
    //       "max_tokens": 1000,
    //       "temperature": 0.65,
    //       "top_p": 1,
    //       "n": 1,
    //       "stream": false,
    //       "logprobs": null,
    //     }),
    //   );
    //   Map<String, dynamic> newresponse = jsonDecode(response.body);
    //   String summaryText = newresponse['choices'][0]['text'].toString();
    //   String text = summaryText;
    //   List<String> emailLines = text.split("\n");

    //   String subject = '';
    //   String emailContent = "";
    //   for (String line in emailLines) {
    //     if (line.startsWith("Subject:")) {
    //       subject = line.substring(8);
    //     } else {
    //       emailContent += "$line\n";
    //     }
    //   }
    //   EmailReply emailReply = EmailReply(email: emailContent, subject: subject);
    //   return emailReply;
    // } catch (e) {
    //   return;
    // }
  }
}
