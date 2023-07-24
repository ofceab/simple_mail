import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/sent/sent_reply_screen.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../home_screen/widgets/insta.dart';
import '../../../home_screen/widgets/social_embed_webview.dart';

class SentMessageBody extends StatefulWidget {
  SentMessageBody({
    super.key,
    required this.message,
  });
  GmailMessage message;

  @override
  State<SentMessageBody> createState() => _SentMessageBodyState();
}

class _SentMessageBodyState extends State<SentMessageBody> {
  bool isExpanded = false;
  InboxController inboxController = InboxController();


  final List<String> menuMailItems = [
    "Reply all",
    "Forward",
    "Add star",
  ];

  String to = '';
  String cc = '';
  String bcc = '';
  String date = '';
  String? subject = '';
  String from = '';
  String body = '';

  final dateTime = DateTime.now();

  @override
  void initState() {
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

    from = widget.message.payload?.headers
            ?.where((element) => element.name == "From")
            .toList()
            .first
            .value ??
        ' ';
    body = utf8.decode(
      base64.decode(
        widget.message.payload!.parts!
            .where((part) => part.mimeType == 'text/plain')
            .map((part) => part.body!.data)
            .join(),
      ),
    );

    setState(() {});
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
              backgroundColor: AppColor.whiteColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 24,
                color: Colors.black54,
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              subject!,
                              style: TextStyle(
                                color: Colors.black87.withOpacity(0.8),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(0.w, 8.h, 0..w, 0.h),
                          child: ListTile(
                            leading: CircleAvatar(
                                child: Text(getSenderName(widget.message))),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'me',
                                    style: TextStyle(
                                      color: Colors.black87.withOpacity(0.8),
                                      fontSize: 17.sp,
                                    ),
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
                                        "to ${to.split(RegExp(r'@|\<')).first}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 15.sp),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        Get.to(() => SentReplyScreen(
                                              senderEmail: widget
                                                      .message.payload?.headers
                                                      ?.where((element) =>
                                                          element.name == "To")
                                                      .toList()
                                                      .first
                                                      .value ??
                                                  ' ',
                                              cc: '',
                                              bcc: '',
                                              loggedInEmail: FirebaseAuth
                                                  .instance.currentUser!.email!,
                                              subject: widget
                                                      .message.payload?.headers
                                                      ?.where((element) =>
                                                          element.name ==
                                                          "Subject")
                                                      .toList()
                                                      .first
                                                      .value ??
                                                  ' ',
                                              originalMessage: body,
                                            ));
                                      },
                                      icon: Icon(
                                        Icons.reply_outlined,
                                        color: AppColor.homeIcon,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: InkWell(
                                      child: PopupMenuButton(
                                        iconSize: 24,
                                        icon: Icon(
                                          Icons.menu,
                                          color: AppColor.homeIcon,
                                        ),
                                        onSelected: (String selectedItem) {
                                          if (selectedItem == 'Reply all') {
                                            Get.to(() => SentReplyScreen(
                                                  senderEmail: widget.message
                                                          .payload?.headers
                                                          ?.where((element) =>
                                                              element.name ==
                                                              "To")
                                                          .toList()
                                                          .first
                                                          .value ??
                                                      ' ',
                                                  cc: cc,
                                                  bcc: bcc,
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
                                                      ' ',
                                                  originalMessage: body,
                                                ));
                                          } else if (selectedItem ==
                                              'Forward') {
                                          } else if (selectedItem ==
                                              'Add star') {}
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
                          )),
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
                                          Text("From",
                                              style:
                                                  TextStyle(fontSize: 14.sp)),
                                          SizedBox(
                                            width: 30.w,
                                          ),
                                          Expanded(
                                            child: Text(
                                              FirebaseAuth
                                                  .instance.currentUser!.email!,
                                              style: TextStyle(fontSize: 13.sp),
                                              overflow: TextOverflow.ellipsis,
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
                                          Text("To",
                                              style:
                                                  TextStyle(fontSize: 14.sp)),
                                          SizedBox(
                                            width: 46.w,
                                          ),
                                          Expanded(
                                            child: Text(
                                              to,
                                              // widget.message.payload?.headers!
                                              //         .where((element) =>
                                              //             element.name == "To")
                                              //         .toList()
                                              //         .first
                                              //         .value ??
                                              //     '',

                                              style: TextStyle(fontSize: 13.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      if (widget.message.payload?.headers!.any(
                                              (element) =>
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
                                                Text("cc",
                                                    style: TextStyle(
                                                        fontSize: 15.sp)),
                                                SizedBox(
                                                  width: 46.w,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    widget.message.payload
                                                            ?.headers!
                                                            .where((element) =>
                                                                element.name ==
                                                                "Cc")
                                                            .toList()
                                                            .first
                                                            .value ??
                                                        '',
                                                    style: TextStyle(
                                                        fontSize: 13.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            ),
                                          ],
                                        ),
                                      if (widget.message.payload?.headers!.any(
                                              (element) =>
                                                  element.name == "Bcc") ==
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
                                                Text("bcc",
                                                    style: TextStyle(
                                                        fontSize: 15.sp)),
                                                SizedBox(
                                                  width: 37.w,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    widget.message.payload
                                                            ?.headers!
                                                            .where((element) =>
                                                                element.name ==
                                                                "Bcc")
                                                            .toList()
                                                            .first
                                                            .value ??
                                                        '',
                                                    style: TextStyle(
                                                        fontSize: 13.sp),
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
                                          Text("Date",
                                              style:
                                                  TextStyle(fontSize: 14.sp)),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                inboxController.getFormattedDate(
                                                    int.tryParse(widget.message
                                                            .internalDate!) ??
                                                        0),
                                                style:
                                                    TextStyle(fontSize: 13.sp),
                                              )
                                              // Text(
                                              // inboxController.getFormattedDate(int.tryParse(inboxController.gmailDetail[i].internalDate!) ?? 0),
                                              //   style: const TextStyle(fontSize: 12),
                                              // )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(
                        height: 10.h,
                      ),
                      buildMessageBody(),
                      
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: AppColor.whiteColor,
                onPressed: (() {
                  Get.to(() => SentReplyScreen(
                        senderEmail: widget.message.payload?.headers
                                ?.where((element) => element.name == "To")
                                .toList()
                                .first
                                .value ??
                            ' ',
                        cc: '',
                        bcc: '',
                        loggedInEmail:
                            FirebaseAuth.instance.currentUser!.email!,
                        subject: widget.message.payload?.headers
                                ?.where((element) => element.name == "Subject")
                                .toList()
                                .first
                                .value ??
                            ' ',
                        originalMessage: body,
                      ));
                }),
                child: Icon(
                  Icons.reply,
                  color: AppColor.blackColor,
                )),
          );
        });
  }

  void downloadAndOpenFile(String attachmentId, String filename) async {
    // String attachmentId =/-y1OMAboA0Xq_itwXlTpY90HoeR0YmKSeavysZmeCK4yyjhkcSZFVuY6-QfMRcXTbDiiD9EWnfDKxKG7USrNjqwHIOZBCsYMxVyq0I6dcDr3h6RMutL4QuClTFcrobJZFAbPQjjL9uer2XwEnaNHHKElwRDXdCwKW74f0V8TiWyvbCRnkwCtwvEJMv7mbM1zF1VqLpMpoJeciw6FxXrUkPR6IJbqV5dQV3kZvr7PX-By3bJ9gPRlsYa5whh1_Ivdh-kdgn9g7dsnEnlKYkc02D6zM_Dh4Hsa4bLfRmVq13184SWqypeVgZRi9kuCbS8lrUKKbUZAWsEOC3bfcEKqP4meVDpUpKC9SPc0X';
    // String decodedString = utf8.decode(base64.decode(attachmentId));

    final url =
        'https://www.googleapis.com/gmail/v1/users/me/attachments/$attachmentId';
    var response = await http.get(Uri.parse(url));
    print(response);
    // print(response.body);
    print(response.statusCode);
    var bytes = response.bodyBytes;
    print('bytes');
    print(bytes);
    // Get the directory to save the file
    // var decodedBody = utf8.decode(base64Url.decode(response.body));

    // Html(
    //     data: decodedBody,
    //     onLinkTap: (url, _, __, ___) async {
    //       if (await canLaunch(url!)) {
    //         await launch(url);
    //       } else {
    //         throw 'Could not launch $url';
    //       }
    //     });
    var dir = await getApplicationDocumentsDirectory();
    // Save the file
    File file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(bytes);

    // Open the file
    OpenFile.open(file.path);
  }

  getDownloadUrl(String attachmentId) async {
    print('attachment id ');
    print(attachmentId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print('token -------------');
    print(token);
    final url =
        'https://www.googleapis.com/drive/v3/files/$attachmentId?alt=media';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);

    print(response.body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final downloadUrl = jsonResponse['webContentLink'];
      return downloadUrl;
    } else {
      throw Exception('Failed to get download URL');
    }
  }

  buildMessageBody() {
    List<Widget> messageParts = [];
    final payload = widget.message.payload;

    void parseParts(List<Part> parts) {
      String? plainText;
      String? htmlText;
      bool containsEmbeddedImages(String htmlContent) {
        RegExp imgTagRegex = RegExp(r'<img[^>]+>', caseSensitive: false);
        return imgTagRegex.hasMatch(htmlContent);
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
            String decodedUrl = part.body!.data!;
            messageParts.add(
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Attachment: ${part.filename}"),
                  ),
                  Image.memory(
                    base64Url.decode(decodedUrl),
                    fit: BoxFit.cover,
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
          print(fileName);
          print(fileUrl);
          if (part.body!.data != null) {
             fileUrl = part.body!.data!;
            print(fileUrl);
            messageParts.add(
              Column(
                children: [
                  Text("Attachment: $fileName"),
                  TextButton(
                    onPressed: () {
                      print('file url');
                      print(fileUrl);
                      downloadAndOpenFile(fileUrl, fileName);
                    },
                    child: const Text('Download and Open'),
                  ),
                ],
              ),
            );
          } else if (part.mimeType == 'application/pdf' &&
              disposition != 'attachment') {
            String fileName = part.filename!;
            String fileUrl = part.body?.data ?? '';
            print('attchment id  -------------');
            print(part.body?.toJson());
            print(parts.toString());
            print(part.body?.data ?? ' was not found ');
            if (part.body!.data != null) {
              String? messageId = widget.message.id;
              inboxController
                  .fetchAttachment(messageId!, part.body!.data!)
                  .then((fileData) {
                if (fileData != null) {
                   print('Fetched PDF attachment: $fileName');
                  messageParts.add(
                    Column(
                      children: [
                        Text("Attachment: $fileName"),
                        TextButton(
                          onPressed: () async {
                            print('fileUrl ---- direct');
                            print(fileUrl);
                            var dir = await getApplicationDocumentsDirectory();
                              File file = File('${dir.path}/$fileName.pdf');
                            await file.writeAsBytes(fileData);
                               OpenFile.open(file.path);
                              },
                          child: const Text('Download and Open'),
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

          if (fileUrl.isNotEmpty) {
            messageParts.add(
              Column(
                children: [
                  Text("Attachment: $fileName"),
                  TextButton(
                    onPressed: () async {
                      
                      // var dir = await getApplicationDocumentsDirectory();
                      // Save the file
                      // File file = File('${dir.path}/$fileName.pdf');
                      // await file.writeAsBytes();
                      // // Open the file
                      // OpenFile.open(file.path);
                      // downloadAndOpenFile(fileUrl, fileName);

                      downloadAndOpenFile(fileUrl, fileName);
                    },
                    child: const Text('Download and Open'),
                  ),
                ],
              ),
            );
          }
        }
      }

      if (htmlText != null) {
        if (containsEmbeddedImages(htmlText)) {
          double screenWidth = MediaQuery.of(context).size.width;

          // final controller = WebViewController()
          //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
          //   ..setBackgroundColor(const Color(0x00000000))
            // ..loadHtmlString(modifyHtmlContent(htmlText));
          messageParts.add(   Column(
                children: [ 
              InstagramEmbedData(embedHtml: htmlText) 
            ]
                    .map((instaData) => Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SocialEmbed(
                            socialMediaObj: instaData,
                          ),
                        ))
                    .toList()),
            // SizedBox(
            //   width: screenWidth,
            //   height: 5000,
            //   child: WebViewWidget(controller: controller),
            // ),
          );
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
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                }),
          );
        }
      } else if (plainText != null) {
        messageParts.add(SelectableText(plainText,
            style: TextStyle(
              fontSize: 18,
              color: AppColor.blackColor,
            )));
      }
    }

    if (payload!.mimeType!.startsWith('multipart/')) {
      parseParts(payload.parts!);
    } else if (payload.mimeType!.startsWith('text/plain')) {
      String decodedBody =
          getDecodedMessageBody(payload.body!.data!, payload.mimeType!);
      messageParts.add(SelectableText(decodedBody,
          style: TextStyle(
            fontSize: 18,
            color: AppColor.blackColor,
          )));
    } else if (payload.mimeType!.startsWith('text/html')) {
      bool containsEmbeddedImages(String htmlContent) {
        RegExp imgTagRegex = RegExp(r'<img[^>]+>', caseSensitive: false);
        return imgTagRegex.hasMatch(htmlContent);
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
        double screenWidth = MediaQuery.of(context).size.height;
        // final controller = WebViewController()
        //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
        //   ..setBackgroundColor(const Color(0x00000000))
        //   ..loadHtmlString(modifyHtmlContent(decodedBody));
        // NavigationDelegate
        messageParts.add(   Column(
                children: [ 
              InstagramEmbedData(embedHtml: decodedBody) 
            ]
                    .map((instaData) => Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SocialEmbed(
                            socialMediaObj: instaData,
                          ),
                        ),
                        )
                    .toList()),
          // SizedBox(
          //   width: screenWidth,
          //   height: 2000,
          //   child: WebViewWidget(controller: controller))
            );
      } else {
        messageParts.add(
          Html(
              data: decodedBody,
              onLinkTap: (url, _, __, ___) async {
                if (await canLaunch(url!)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              }),
        );
      }
    }

    return Column(children: messageParts);
  }

  String modifyHtmlContent(String htmlContent) {
    String newHtmlContent = '''
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style type="text/css">
        body {
          font-size: 20px; /* Or whatever size you want */
          width: 100%; /* Make the body take up the full screen width */
          max-width: 600%; /* Prevent the content from exceeding the width of the body */
          margin: 0; /* Remove default margin */
          padding: 20px; /* Add padding to create space around the content */
          overflow-x: hidden; /* Hide horizontal scroll bar */
          word-wrap: break-word; /* Break words into a new line when they reach the end of the body */
        }
        .content-container {
          max-width: 600px; /* Set the maximum width for the content */
          margin: 0 auto; /* Center the content horizontally */
        }
        img {
          max-width: 100%; /* Make sure images never exceed the width of their container */
          height: auto; /* Maintain the aspect ratio of the images */
        }
      
      </style>
    </head>
    <body>
      <div class="content-container">
        $htmlContent
      </div>
    </body>
    </html>
  ''';
    return newHtmlContent;
  }

  String getDecodedMessageBody(String encodedBody, String mimeType) {
    String decodedBody = '';

    if (mimeType == 'text/plain' || mimeType == 'text/html') {
      decodedBody = utf8.decode(base64Url.decode(encodedBody));
    }

    return decodedBody;
  }
}

String getSenderName(GmailMessage message) {
  // final message = message;
  final headers = message.payload!.headers!;
  final fromHeader = headers.firstWhere((h) => h.name == 'From');
  final senderName = fromHeader.value!.split(' ')[0].toUpperCase();
  return senderName[0];
}
