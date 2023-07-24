import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/drawer_screen/view/unread/unread_controller.dart';
import 'package:simplemail/screens/home_screen/view/home_screen.dart';
import 'package:simplemail/screens/unread_snap/summary_reply_screen.dart';
import 'package:simplemail/screens/home_screen/widgets/list_items.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:simplemail/utils/colors.dart';


class UnreadEmailScreen extends StatefulWidget {
  List<GmailMessage> unreadGmailDetails;


  UnreadEmailScreen({
    Key? key,
    required this.unreadGmailDetails,

  }) : super(key: key);

  @override
  _UnreadEmailScreenState createState() => _UnreadEmailScreenState();
}

class _UnreadEmailScreenState extends State<UnreadEmailScreen> {
  List<Sumrise> summaryEmails = [];
  List<GmailMessage> currentEmails = [];
  bool isLoading = true;
  bool isExpanded = false;
  int pageNumber = 0;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    loadSummaryEmails(pageNumber);
  }

  @override
  void dispose() {
    super.dispose();
    summaryEmails.clear();
  }

  void loadSummaryEmails(int pageNumber) async {
    int start = pageNumber * 10;
    int end = start + 10 > widget.unreadGmailDetails.length - 1
        ? widget.unreadGmailDetails.length - 1
        : start + 10;
    if (end == widget.unreadGmailDetails.length - 1) {
      setState(() {
        hasMore = false;
      });
    }
    
    if (start < widget.unreadGmailDetails.length) {
      currentEmails.clear();
      for (int i = start; i <= end; i++) {
        currentEmails.add(widget.unreadGmailDetails[i]);
      }



      summaryEmails =
          await _unreadController.summariseAllUnreadEmails(currentEmails);
      List<Sumrise> availableSummaryEmails =
          summaryEmails.where((value) => value.from.isNotEmpty).toList();
      summaryEmails.clear();
      summaryEmails = availableSummaryEmails;

  
      setState(() {
        isLoading = false;
      });
    } else {
      hasMore = false;
    }
  }

  bool _isSearching = false;
  final UnreadController _unreadController = Get.put(UnreadController());
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF74AADF),
                Color(0xFF9698E3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _isSearching
            ? Container(
                height: 40,
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const  InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {},
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                    ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Unread Snap",
                      style: TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                   const  SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Summary of unread emails',
                      style: TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),

       
        actions: [
          !_isSearching
              ? IconButton(
                  icon: const Icon(Icons.search),
                  color: AppColor.whiteColor,
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                )
              : const SizedBox.shrink(),
        ],
        ),

      body: Stack(
        children: [
          const SizedBox(
            height: double.infinity,
            width: double.infinity,
          ),
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : summaryEmails.isEmpty
                  ? const Center(
                    child: Text(
                      "No Unread mails to summarize",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: summaryEmails.length,
                    itemBuilder: (context, index) {
                      var title = currentEmails[index]
                          .payload
                          ?.headers
                          ?.where((element) => element.name == "From")
                          .toList()
                          .first
                          .value!
                          .toString()
                          .split(RegExp(r'[<>]'))
                          .first;
                      Color color = generateRandomColor(title!);

                      return 
                      ExpansionTile(
                        backgroundColor: const Color(0xFFF2F3FF),
                        textColor: AppColor.blackColor,
                        leading: Icon(
                          Icons.account_circle,
                          color: color,
                        ),
                        tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              summaryEmails[index].from,
                                overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                             const SizedBox(width: 8), 
                             Text(
                                    unreadController.getFormattedDate(
                                        int.tryParse(widget
                                                .unreadGmailDetails[index].internalDate!) ??
                                            0),
                                    // widget.message.payload?.headers
                                    //         ?.where(
                                    //             (element) => element.name == "Date")
                                    //         .toList()
                                    //         .first
                                    //         .value
                                    //         ?.substring(5, 10) ??
                                    //     '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                  ),
                          ],
                        ),
                        subtitle: Text(
                          summaryEmails[index].subject,
                    
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: AppColor.whiteColor,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(summaryEmails[index].data),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 1, 20, 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences
                                            .getInstance();
                                    String? token =
                                        prefs.getString('token');

                                    await AuthService().markMessageAsSeen(
                                        messageId: _unreadController
                                            .gmailDetail[index].id!,
                                        accessToken: token!);
                                    _unreadController
                                        .gmailDetail[index].labelIds!
                                        .remove('UNREAD');
                                    _unreadController.update();
                                    Get.to(
                                      () => SummaryReplyScreen(
                                        senderEmail: widget
                                                .unreadGmailDetails[index]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            ' ',
                                        loggedInEmail: FirebaseAuth
                                            .instance.currentUser!.email!,
                                        subject: widget
                                                .unreadGmailDetails[index]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name ==
                                                    "Subject")
                                                .toList()
                                                .first
                                                .value ??
                                            ' ',
                                        originalMessage: utf8.decode(
                                          base64.decode(
                                            widget.unreadGmailDetails[index]
                                                .payload!.parts!
                                                .where((part) =>
                                                    part.mimeType ==
                                                    'text/plain')
                                                .map((part) =>
                                                    part.body!.data)
                                                .join(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(30.0),
                                  splashColor: Colors.grey.withOpacity(0.5),
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF7A85DE),
                                    ),
                                    child: const Icon(
                                      Icons.reply,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7A85DE),
          child: const Icon(Icons.arrow_forward),
          onPressed: () {
            summaryEmails.clear();
            isLoading = true;
            if (hasMore) {
              setState(() {
                pageNumber++;
                 loadSummaryEmails(pageNumber);
              });
            } else {
              final snackBar = SnackBar(
                content: const Text(
                  'No More Unread emails ',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red.shade600,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                margin:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
          }),
    );
  }

  Color generateRandomColor(String name) {
    int hash = name.hashCode;
    Random random = Random(hash);
    return ListItems.colorList[random.nextInt(ListItems.colorList.length)];
   
  }
}
