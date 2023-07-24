import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:simplemail/Models/gmail_message.dart';

class EmailMessageScreen extends StatelessWidget {
  // final GmailApi gmailApi;
  GmailMessage message;

  EmailMessageScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    String messageBody = '';

    // Get the message body
    List<Part> messageParts = message.payload!.parts!;
    for (var part in messageParts) {
      if (part.mimeType == 'text/plain') {
        messageBody = utf8.decode(base64Url.decode(part.body!.data!));
        break;
      } else if (part.mimeType == 'multipart/alternative') {
        for (var subPart in part.parts!) {
          if (subPart.mimeType == 'text/plain') {
            messageBody = utf8.decode(base64Url.decode(subPart.body!.data!));
            break;
          }
        }
      }
    }

    // Format the message date
    String formattedDate = DateFormat('MMM d, yyyy h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(
            int.parse(message.internalDate!)))
        .toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Message'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.payload!.headers!
                    .firstWhere((header) => header.name == 'From')
                    .value!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                message.payload!.headers!
                    .firstWhere((header) => header.name == 'To')
                    .value!,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                message.payload!.headers!
                    .firstWhere((header) => header.name == 'Subject')
                    .value!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(messageBody),
            ],
          ),
        ),
      ),
    );
  }
}
