import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/drawer_screen/view/draft/draft_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/draft/draft_replyscreen.dart';
import 'package:simplemail/screens/drawer_screen/view/draft/widget.dart';
import '../../../../Models/all_message.dart';
import '../../../../utils/colors.dart';

class DraftScreen extends StatefulWidget {
  @override
  _DraftScreenState createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  late DraftController _draftController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  GmailMessage message = GmailMessage();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _draftController = Get.put(DraftController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_draftController.isLoading) {
        _draftController.moreListCalling();
        _draftController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DraftController>(
        init: DraftController(),
        builder: (draftController) {
          return (draftController.isLoading &&
                  draftController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: (() async {
                    draftController.changeRefreshing(true);
                    draftController.gmailDetail = [];
                    draftController.allInboxMessages = Allmessages();
                    draftController.gmailDetail.clear();
                    draftController.nextPageToken = null;
                    draftController.unreadGmailDetails.clear();
                    _refreshIndicatorKey.currentState?.deactivate();
                    await draftController.executeInBackground();
                    await draftController.fetchInboxMessages();
                    draftController.changeRefreshing(false);
                  }),
                  child: draftController.gmailDetail.isEmpty
                      ? LayoutBuilder(
                          builder: (draftcont, constraints) => ListView(
                            children: [
                              Container(
                                padding: EdgeInsets.all(20.w),
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: Text(
                                    'Nothing in Drafts',
                                    style: TextStyle(
                                        color: AppColor.blackColor,
                                        fontSize: 20.sp),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: draftController.gmailDetail.length + 1,
                          itemBuilder: (BuildContext context, int i) {
                            if (i == draftController.gmailDetail.length) {
                              return draftController.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Container();
                            } else {
                              return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  draftController.trashMessage(
                                    draftController.gmailDetail[i].id!,
                                  );
                                  final snackBar = SnackBar(
                                    content: const Text(
                                      'Moved to bin',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        Colors.black.withOpacity(0.8),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(4.0),
                                    ),
                                    margin: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        bottom: 8.0),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    draftController.discardDraftMessage(
                                        draftController
                                            .draftMessages.drafts![i],
                                        draftController
                                            .draftMessages.drafts![i].id!);
                                  },
                                  onTap: () async {
                                    GmailMessage message =
                                        draftController.gmailDetail[i];

                                    String? to = message.payload!.headers!
                                            .any((element) =>
                                                element.name == 'To')
                                        ? (message.payload?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "To")
                                                    .toList()
                                                    .first
                                                    .value
                                                    ?.isNotEmpty ??
                                                false)
                                            ? message.payload?.headers
                                                ?.where((element) =>
                                                    element.name == "To")
                                                .toList()
                                                .first
                                                .value
                                            : ''
                                        : '';

                                    String? subject = message
                                            .payload!.headers!
                                            .any((element) =>
                                                element.name == 'Subject')
                                        ? (message.payload?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "Subject")
                                                    .toList()
                                                    .first
                                                    .value
                                                    ?.isNotEmpty ??
                                                false)
                                            ? message.payload?.headers
                                                ?.where((element) =>
                                                    element.name ==
                                                    "Subject")
                                                .toList()
                                                .first
                                                .value
                                            : ''
                                        : '';
                                    String? cc = (message.payload!.headers!
                                            .any((element) =>
                                                element.name == 'Cc')
                                        ? (message.payload?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "Cc")
                                                    .toList()
                                                    .first
                                                    .value
                                                    ?.isNotEmpty ??
                                                false)
                                            ? message.payload?.headers
                                                ?.where((element) =>
                                                    element.name == "Cc")
                                                .toList()
                                                .first
                                                .value
                                            : ''
                                        : '');
                                    String? bcc = (message.payload!.headers!
                                            .any((element) =>
                                                element.name == 'Bcc')
                                        ? (message.payload?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "Bcc")
                                                    .toList()
                                                    .first
                                                    .value
                                                    ?.isNotEmpty ??
                                                false)
                                            ? message.payload?.headers
                                                ?.where((element) =>
                                                    element.name == "Bcc")
                                                .toList()
                                                .first
                                                .value
                                            : ''
                                        : '');
                                    String? body = message.payload!.mimeType ==
                                                'text/plain' &&
                                            message.payload!.body != null &&
                                            message.payload!.body!.data !=
                                                null
                                        ? utf8.decode(base64.decode(
                                            message.payload!.body!.data!))
                                        : message.payload!.parts != null &&
                                                message.payload!.parts!.any(
                                                    (part) =>
                                                        part.mimeType ==
                                                        'text/plain')
                                            ? utf8.decode(base64.decode(message
                                                .payload!.parts!
                                                .where((part) => part.mimeType == 'text/plain')
                                                .map((part) => part.body!.data)
                                                .join()))
                                            : message.payload!.body != null && message.payload!.body!.data != null
                                                ? utf8.decode(base64.decode(message.payload!.body!.data!))
                                                : '';

                                    Get.to(
                                      () => DraftReplyScreen(
                                        gmailMessage: message,
                                        senderEmail: to!,
                                        cc: cc!,
                                        bcc: bcc!,
                                        loggedInEmail: FirebaseAuth
                                            .instance.currentUser!.email!,
                                        subject: subject!,
                                        originalMessage: body,
                                        i: i,
                                      ),
                                    );
                                    // !
                                    //     .then((value) async {

                                    //   draftController
                                    //       .changeRefreshing(true);
                                    //   draftController.gmailDetail = [];
                                    //   draftController.allInboxMessages =
                                    //       Allmessages();
                                    //   draftController.gmailDetail.clear();
                                    //   draftController.nextPageToken = null;
                                    //   draftController.unreadGmailDetails
                                    //       .clear();
                                    //   _refreshIndicatorKey.currentState
                                    //       ?.deactivate();
                                    //   await draftController
                                    //       .fetchInboxMessages();
                                    //   draftController
                                    //       .changeRefreshing(false);
                                    // });
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => GmailMessageBody(
                                    //       message:
                                    //           draftController.gmailDetail[i], threadId: '',
                                    //     ),
                                    //   ),
                                    // );
                                    // SharedPreferences prefs =
                                    //     await SharedPreferences
                                    //         .getInstance();
                                    // String? token =
                                    //     prefs.getString('token');
                                    // // token k ander value pref se aaegi
                                    // await AuthService().markMessageAsSeen(
                                    //     messageId: draftController
                                    //         .gmailDetail[i].id!,
                                    //     accessToken: token!);
                                  },
                                  child: DraftListItems(
                                    i: i,
                                    date: draftController.getFormattedDate(
                                        int.tryParse(draftController
                                                .gmailDetail[i]
                                                .internalDate!) ??
                                            0),
                                    from: draftController
                                            .gmailDetail[i].payload?.headers
                                            ?.where((element) =>
                                                element.name == "From")
                                            .toList()
                                            .first
                                            .value ??
                                        '',
                                    subject: draftController.gmailDetail[i]
                                            .payload!.headers!
                                            .any((element) =>
                                                element.name == 'Subject')
                                        ? (draftController.gmailDetail[i]
                                                    .payload?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "Subject")
                                                    .toList()
                                                    .first
                                                    .value
                                                    ?.isNotEmpty ??
                                                false)
                                            ? draftController.gmailDetail[i]
                                                .payload?.headers
                                                ?.where((element) =>
                                                    element.name ==
                                                    "Subject")
                                                .toList()
                                                .first
                                                .value
                                            : '(No )'
                                        : '(No )',
                                    snippet: draftController
                                            .gmailDetail[i].snippet ??
                                        '',
                                    isRead: draftController
                                            .gmailDetail[i].labelIds!
                                            .contains('UNREAD')
                                        ? false
                                        : true,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                );
        });
  }
}
