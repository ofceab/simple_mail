import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/screens/home_screen/view/forward_reply.dart';
import 'package:simplemail/screens/home_screen/view/homereply_screen.dart';
import 'package:simplemail/screens/home_screen/view/reply_all.dart';
import 'package:simplemail/screens/home_screen/widgets/insta.dart';
import 'package:simplemail/screens/home_screen/widgets/social_embed_webview.dart';
import 'package:simplemail/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class GmailMessageBody extends StatefulWidget {
  GmailMessageBody({
    super.key,
    required this.i,
    required this.message,
    required this.threadId,
    required this.isStarred,
  });

  int i;
  GmailMessage message;
  final String threadId;
  bool isStarred;

  @override
  State<GmailMessageBody> createState() => _GmailMessageBodyState();
}

class _GmailMessageBodyState extends State<GmailMessageBody> {
  List<int> expandedIndices = [];
  bool isExpanded = false;

  late final InboxController inboxController = InboxController();

  final List<String> menuMailItems = [
    "Reply all",
    "Forward",
  ];

  String to = '';
  String cc = '';
  String bcc = '';
  String replyTo = '';
  String? subject = '';
  String from = '';
  String body = '';

  @override
  void initState() {
    replyTo = (widget.message.payload!.headers!
            .any((element) => element.name == 'Reply-To')
        ? (widget.message.payload?.headers
                    ?.where((element) => element.name == "Reply-To")
                    .toList()
                    .first
                    .value
                    ?.isNotEmpty ??
                false)
            ? widget.message.payload?.headers
                ?.where((element) => element.name == "Reply-To")
                .toList()
                .first
                .value
            : ''
        : '')!;
    from = widget.message.payload?.headers
            ?.where((element) => element.name == "From")
            .toList()
            .first
            .value ??
        ' ';
    to = widget.message.payload?.headers!
            .where((element) => element.name == "To")
            .toList()
            .first
            .value ??
        '';
    cc =
        (widget.message.payload!.headers!.any((element) => element.name == 'Cc')
            ? (widget.message.payload?.headers
                        ?.where((element) => element.name == "Cc")
                        .toList()
                        .first
                        .value
                        ?.isNotEmpty ??
                    false)
                ? widget.message.payload?.headers
                    ?.where((element) => element.name == "Cc")
                    .toList()
                    .first
                    .value
                : ''
            : '')!;
    bcc = (widget.message.payload!.headers!
            .any((element) => element.name == 'Bcc')
        ? (widget.message.payload?.headers
                    ?.where((element) => element.name == "Bcc")
                    .toList()
                    .first
                    .value
                    ?.isNotEmpty ??
                false)
            ? widget.message.payload?.headers
                ?.where((element) => element.name == "Bcc")
                .toList()
                .first
                .value
            : ''
        : '')!;

    subject = widget.message.payload!.headers!
            .any((element) => element.name == 'Subject')
        ? (widget.message.payload?.headers
                    ?.where((element) => element.name == "Subject")
                    .toList()
                    .first
                    .value
                    ?.isNotEmpty ??
                false)
            ? widget.message.payload?.headers
                ?.where((element) => element.name == "Subject")
                .toList()
                .first
                .value
            : '(No Subject)'
        : '(No Subject)';

    body = utf8.decode(
      base64.decode(
        widget.message.payload!.parts!
            .where((part) => part.mimeType == 'text/plain')
            .map((part) => part.body!.data)
            .join(),
      ),
    );

    super.initState();
  }

  void _toggleContainer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (homeController) {
          return Scaffold(
            backgroundColor: AppColor.whiteColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFFF2F3FF),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 24,
                color: Colors.black54,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      subject ?? "",
                      style: TextStyle(
                        color: Colors.black87.withOpacity(0.8),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 24,
                  color: Colors.black54,
                  onPressed: () {
                    Get.put(InboxController()).trashMessage(widget.message.id!);
                    Get.back();
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Container(
                    height: 48.h,
                    // width: 307.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F3FF),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            tileColor: Color(0xffF2F3FF),
                            leading: CircleAvatar(
                              child: Text(
                                getSenderName(widget.message),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    from.split(RegExp(r'@|\<')).first,
                                    style: TextStyle(
                                      color: Colors.black87.withOpacity(0.8),
                                      fontSize: 17.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  inboxController.getFormattedDate(int.tryParse(
                                          widget.message.internalDate!) ??
                                      0),
                                  style: TextStyle(
                                    color: Colors.black87.withOpacity(0.8),
                                    fontSize: 13.sp,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            subtitle: InkWell(
                              onTap: (() {
                                _toggleContainer();
                              }),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'to me',
                                        style: TextStyle(fontSize: 17.sp),
                                      ),
                                      const Icon(Icons.expand_more),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: SizedBox(
                              width: 80.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      child: PopupMenuButton(
                                        color: Color(0xffF2F3FF),
                                        // shape: ,
                                        iconSize: 24,
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Color(0xff434343),
                                        ),
                                        onSelected: (String selectedItem) {
                                          if (selectedItem == 'Reply all') {
                                            Get.to(
                                              () => ReplyAllScreen(
                                                messagebody: buildMessageBody(
                                                    widget.message,
                                                    context,
                                                    inboxController),
                                                gmailMessage: widget.message,
                                                senderEmail: from,
                                                cc: cc,
                                                bcc: bcc,
                                                loggedInEmail: FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .email!,
                                                subject: widget.message.payload
                                                        ?.headers
                                                        ?.where((element) =>
                                                            element.name ==
                                                            "Subject")
                                                        .toList()
                                                        .first
                                                        .value ??
                                                    '',
                                                originalMessage: body,
                                              ),
                                            );
                                          } else if (selectedItem ==
                                              'Forward') {
                                            Get.to(() => ForwardReplyScreen(
                                                  messagebody: buildMessageBody(
                                                    widget.message,
                                                    context,
                                                    inboxController,
                                                  ),
                                                  gmailMessage: widget.message,
                                                  senderEmail: '',
                                                  cc: '',
                                                  bcc: '',
                                                  loggedInEmail: FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .email!,
                                                  subject: widget.message
                                                          .payload?.headers
                                                          ?.where((element) =>
                                                              element.name ==
                                                              "Subject")
                                                          .toList()
                                                          .first
                                                          .value ??
                                                      '',
                                                  originalMessage: body,
                                                ));
                                          }
                                        },
                                        itemBuilder: (context) => menuMailItems
                                            .map(
                                              (itemName) => PopupMenuItem(
                                                value: itemName,
                                                child: Text(itemName),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isExpanded
                            ? Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.w),
                                  color: AppColor.homeBackgroundColor,
                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "From",
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            SizedBox(
                                              width: 35.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                from,
                                                style:
                                                    TextStyle(fontSize: 12.sp),
                                                // overflow: TextOverflow.ellipsis,
                                                // maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (widget.message.payload?.headers!
                                                .any((element) =>
                                                    element.name ==
                                                    "Reply-To") ==
                                            true)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 20, 0, 0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Reply-To",
                                                      style: TextStyle(
                                                          fontSize: 14.sp),
                                                    ),
                                                    SizedBox(
                                                      width: 15.w,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        widget.message.payload
                                                                ?.headers!
                                                                .where((element) =>
                                                                    element
                                                                        .name ==
                                                                    "Reply-To")
                                                                .toList()
                                                                .first
                                                                .value ??
                                                            '',
                                                        // maxLines: 2,
                                                        style: TextStyle(
                                                            fontSize: 12.sp),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "To",
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            SizedBox(
                                              width: 49.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                to,
                                                style:
                                                    TextStyle(fontSize: 12.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        if (widget.message.payload?.headers!
                                                .any((element) =>
                                                    element.name == "Cc") ==
                                            true)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "cc",
                                                    style: TextStyle(
                                                        fontSize: 14.sp),
                                                  ),
                                                  SizedBox(
                                                    width: 52.w,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      widget.message.payload
                                                              ?.headers!
                                                              .where((element) =>
                                                                  element
                                                                      .name ==
                                                                  "Cc")
                                                              .toList()
                                                              .first
                                                              .value ??
                                                          '',
                                                      // maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                            ],
                                          ),
                                        if (widget.message.payload?.headers!
                                                .any((element) =>
                                                    element.name == "Bcc") ==
                                            true)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "bcc",
                                                    style: TextStyle(
                                                        fontSize: 14.sp),
                                                  ),
                                                  SizedBox(
                                                    width: 47.w,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      widget.message.payload
                                                              ?.headers!
                                                              .where((element) =>
                                                                  element
                                                                      .name ==
                                                                  "Bcc")
                                                              .toList()
                                                              .first
                                                              .value ??
                                                          '',
                                                      // maxLines: 3,
                                                      style: TextStyle(
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            Text(
                                              "Date",
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.message.payload
                                                          ?.headers
                                                          ?.where((element) =>
                                                              element.name ==
                                                              "Date")
                                                          .toList()
                                                          .first
                                                          .value
                                                          ?.substring(0, 16) ??
                                                      '',
                                                  style: TextStyle(
                                                      fontSize: 12.sp),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: homeController.isLoading
                ? Container()
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FutureBuilder<List<GmailMessage>>(
                            future: homeController
                                .fetchThreadDetails(widget.message.threadId!),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<GmailMessage>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                if (snapshot.hasData &&
                                    snapshot.data!.length > 1) {
                                  print(
                                      "There are multiple messages in this thread.");
                                  return ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Widget threadBody = buildMessageBody(
                                        snapshot.data![index],
                                        context,
                                        inboxController,
                                      );
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: threadBody,
                                          ),
                                          const Divider(),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  buildMessageBody(
                                      widget.message, context, inboxController);
                                  print(
                                      "There is only one message in this thread.");
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      buildMessageBody(widget.message, context,
                                          inboxController),
                                      const Divider(),
                                    ],
                                  );
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
            floatingActionButton: ElevatedButton.icon(
              onPressed: (() {
                Get.to(
                  () => EmailReplyScreen(
                    messagebody: buildMessageBody(
                        widget.message, context, inboxController),
                    gmailMessage: widget.message,
                    senderEmail: replyTo.isNotEmpty ? replyTo : from,
                    cc: '',
                    bcc: '',
                    loggedInEmail: FirebaseAuth.instance.currentUser!.email!,
                    subject: widget.message.payload?.headers
                            ?.where((element) => element.name == "Subject")
                            .toList()
                            .first
                            .value ??
                        '',
                    originalMessage: body,
                  ),
                );
              }),
              icon: Icon(
                Icons.edit_outlined,
                color: AppColor.whiteColor,
              ),
              label: const Text('Reply'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A85DE),
                  shape: const StadiumBorder()),
            ),
          );
        });
  }
}

String getSenderName(GmailMessage message) {
  final headers = message.payload!.headers!;
  final fromHeader = headers.firstWhere((h) => h.name == 'From');
  final senderName = fromHeader.value!.split(' ')[0];
  return senderName[0];
}

getDownloadUrl(String attachmentId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  final url =
      'https://www.googleapis.com/drive/v3/files/$attachmentId?alt=media';
  final headers = {'Authorization': 'Bearer $token'};

  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final downloadUrl = jsonResponse['webContentLink'];
    return downloadUrl;
  } else {
    throw Exception('Failed to get download URL');
  }
}

buildMessageBody(GmailMessage message, BuildContext context,
    InboxController inboxController) {
  List<Widget> messageParts = [];
  final payload = message.payload;

  // return WebView(
  //   initialUrl: 'about:blank',
  //   onWebViewCreated: (WebViewController webViewController) {
  //     // Chargez le contenu HTML de l'e-mail dans le WebView une fois qu'il est créé
  //     webViewController.loadUrl(Uri.dataFromString(
  //       htmlText,
  //       mimeType: 'text/html',
  //       encoding: Encoding.getByName('utf-8'),
  //     ).toString());
  //   },
  // );

  void parseParts(List<Part> parts) {
    String? plainText;
    String? htmlText;

    bool containsEmbeddedImage(String htmlContent) {
      RegExp imgTagRegex = RegExp(r'<img[^>]+>', caseSensitive: false);
      return imgTagRegex.hasMatch(htmlContent);
    }

    bool containsEmbeddedImages(String htmlContent) {
      RegExp imgTagRegex = RegExp(r'<img[^>]+>', caseSensitive: false);
      List<RegExpMatch> matches = imgTagRegex.allMatches(htmlContent).toList();
      return matches.length > 1;
    }

    bool containsClickableUrls(String htmlContent) {
      RegExp anchorTagRegex =
          RegExp(r'<a[^>]+href="[^"]+"[^>]*>', caseSensitive: false);
      return anchorTagRegex.hasMatch(htmlContent);
    }

    for (Part part in parts) {
      final mimeType = part.mimeType ?? '';
      final disposition = part.headers
              ?.firstWhere((header) => header.name == 'Content-Disposition',
                  orElse: () => Header())
              .value ??
          '';
      if (part.mimeType == 'text/plain' && disposition != 'attachment') {
        plainText = getDecodedMessageBody(part.body!.data!, part.mimeType!);
      } else if (part.mimeType == 'text/html') {
        htmlText = getDecodedMessageBody(part.body!.data!, part.mimeType!);
      } else if (part.parts != null) {
        parseParts(part.parts!);
      } else if (part.mimeType!.startsWith('image/') &&
          disposition != 'attachment' &&
          part.filename != null &&
          part.filename!.isNotEmpty) {
        try {
          String? messageIdImage = message.id;
          String decodedUrl = part.body!.data!;

          inboxController.fetchImage(messageIdImage!, decodedUrl);
          messageParts.add(
            Column(
              children: [
                FutureBuilder<Uint8List?>(
                  future: inboxController.fetchAttachment(
                      messageIdImage, decodedUrl),
                  builder: (BuildContext context,
                      AsyncSnapshot<Uint8List?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Image.memory(snapshot.data!);
                    }
                  },
                ),
              ],
            ),
          );
        } catch (e) {
          print(e);
        }
      } else if (part.filename != null && part.filename!.isNotEmpty) {
        String fileName = part.filename!;
        String fileUrl = part.body?.data ?? '';

        if (part.body!.data != null) {
          fileUrl = part.body!.data!;
          print(fileUrl);
          messageParts.add(
            Column(
              children: [
                Text("$fileName"),
                TextButton(
                  onPressed: () {
                    print('file url');
                    print(fileUrl);
                    String? messageId = message.id;
                    downloadAndOpenFile(
                        messageId!, part.body!.data!, part.filename!);
                  },
                  child: Text('Download and Open'),
                ),
              ],
            ),
          );
        } else if (part.mimeType == 'application/pdf' &&
            disposition != 'attachment') {
          String fileName = part.filename!;
          String fileUrl = part.body?.data ?? '';

          if (part.body!.data != null) {
            String? messageId = message.id;
            inboxController
                .fetchAttachment(messageId!, part.body!.data!)
                .then((fileData) {
              if (fileData != null) {
                messageParts.add(
                  Column(
                    children: [
                      Text("$fileName"),
                      TextButton(
                        onPressed: () async {
                          var dir = await getApplicationDocumentsDirectory();

                          File file = File('${dir.path}/$fileName.pdf');
                          await file.writeAsBytes(fileData);

                          OpenFile.open(file.path);
                        },
                        child: Text('Download and Open'),
                      ),
                    ],
                  ),
                );
              } else {
                print('Failed to fetch PDF attachment: $fileName');
              }
            }).catchError((error) {
              print('Error fetching PDF attachment: $fileName - $error');
            });
          } else {
            print('Attachment not fetched: $fileName');
          }
        }
      }
    }

    if (htmlText != null) {
      if (containsEmbeddedImages(htmlText)) {
        print("hello there2");

        // print(htmlText);
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        messageParts.add(
          Column(
              children: [InstagramEmbedData(embedHtml: htmlText)]
                  .map((instaData) => SocialEmbed(
                        socialMediaObj: instaData,
                        backgroundColor: Color(0x00000000),
                      ))
                  .toList()),
        );
        // print(htmlText);
      } else {
        messageParts.add(
          Html(
              data: htmlText,
              style: {
                "body": Style(
                    fontSize: FontSize(18.sp), color: AppColor.blackColor),
              },
              onLinkTap: (url, _, __, ___) async {
                if (await canLaunch(url!)) {
                  if (url.startsWith('tel:')) {
                    await launch(url);
                  } else {
                    await launch(url);
                  }
                } else {
                  throw 'Could not launch $url';
                }
              }),
        );
      }
    } else if (plainText != null) {
      messageParts.add(
        SelectableText(
          plainText,
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColor.blackColor,
          ),
        ),
      );
    }
  }

  if (payload != null &&
      payload.mimeType != null &&
      payload.mimeType!.startsWith('multipart/') &&
      payload.parts != null) {
    parseParts(payload.parts!);
  } else if (payload != null &&
      payload.mimeType != null &&
      payload.mimeType!.startsWith('text/plain') &&
      payload.body != null &&
      payload.body!.data != null) {
    String decodedBody =
        getDecodedMessageBody(payload.body!.data!, payload.mimeType!);
    messageParts.add(
      SelectableText(
        decodedBody,
        style: TextStyle(
          fontSize: 18.sp,
          color: AppColor.blackColor,
        ),
      ),
    );
  } else if (payload != null &&
      payload.mimeType != null &&
      payload.mimeType!.startsWith('text/html') &&
      payload.body != null &&
      payload.body!.data != null) {
    bool containsEmbeddedImages(String htmlContent) {
      RegExp imgTagRegex = RegExp(r'<img[^>]+>', caseSensitive: false);
      List<RegExpMatch> matches = imgTagRegex.allMatches(htmlContent).toList();
      return matches.length > 1;
    }

    bool containsClickableUrls(String htmlContent) {
      RegExp anchorTagRegex =
          RegExp(r'<a[^>]+href="[^"]+"[^>]*>', caseSensitive: false);
      return anchorTagRegex.hasMatch(htmlContent);
    }

    String decodedBody =
        getDecodedMessageBody(payload.body!.data!, payload.mimeType!);
    if (containsEmbeddedImages(decodedBody) ||
        containsClickableUrls(decodedBody)) {
      messageParts.add(
        Column(
            children: [InstagramEmbedData(embedHtml: decodedBody)]
                .map((instaData) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SocialEmbed(
                        socialMediaObj: instaData,
                      ),
                    ))
                .toList()),
      );
    } else {
      messageParts.add(
        Html(
            data: decodedBody,
            style: {
              "body":
                  Style(fontSize: FontSize(18.sp), color: AppColor.blackColor),
            },
            onLinkTap: (url, _, __, ___) async {
              if (await canLaunch(url!)) {
                if (url.startsWith('tel:')) {
                  await launch(url);
                } else {
                  await launch(url);
                }
              } else {
                throw 'Could not launch $url';
              }
            }),
      );
    }
  }

  return Column(children: messageParts);
}

String getDecodedMessageBody(String encodedBody, String mimeType) {
  String decodedBody = '';

  if (mimeType == 'text/plain' || mimeType == 'text/html') {
    decodedBody = utf8.decode(base64Url.decode(encodedBody));
  }

  return decodedBody;
}

void downloadAndOpenFile(
    String messageId, String attachmentId, String filename) async {
  final url =
      'https://www.googleapis.com/gmail/v1/users/me/messages/$messageId/attachments/$attachmentId';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  final headers = {'Authorization': 'Bearer $token'};
  var response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    var bytes = base64Url.decode(jsonResponse['data']);
    var dir = await getApplicationDocumentsDirectory();

    bool isGranted = false;

    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.manageExternalStorage,
        Permission.photos,
        Permission.mediaLibrary,
      ].request();

      isGranted = statuses.values.every((status) => status.isGranted);
    } else if (Platform.isIOS) {
      PermissionStatus status = await Permission.photos.request();
      isGranted = status.isGranted;
    }

    File file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);

    OpenResult result = await OpenFile.open(file.path);

    if (result.type != ResultType.done) {
      throw 'Could not launch ${file.path}: ${result.message}';
    }
  } else {
    throw Exception('Failed to download file');
  }
}
