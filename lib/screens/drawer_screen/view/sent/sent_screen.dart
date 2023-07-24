import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/sent/sent_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/sent/sent_message_body.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/widgets/list_items.dart';

class SentScreen extends StatefulWidget {
  @override
  _SentScreenState createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  late SentController _sentController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _sentController = Get.put(SentController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_sentController.isLoading) {
        _sentController.moreListCalling();
        _sentController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SentController>(
        init: SentController(),
        builder: (sentController) {
          return (sentController.isLoading &&
                  sentController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : sentController.isRefreshing
                  ? LayoutBuilder(
                    builder: (incont, constraints) => ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: const Center(
                              child: CircularProgressIndicator()),
                        )
                      ],
                    ),
                  )
                  : RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: (() async {
                        sentController.changeRefreshing(true);
                        sentController.gmailDetail = [];
                        sentController.allInboxMessages = Allmessages();
                        sentController.gmailDetail.clear();
                        sentController.nextPageToken = null;
                        sentController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                         await sentController.executeInBackground();
                        await sentController.fetchInboxMessages();
                        sentController.changeRefreshing(false);
                      }),
                      child: sentController.gmailDetail.isEmpty
                          ? LayoutBuilder(
                              builder: (incont, constraints) => ListView(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20.w),
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No Emails to show',
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
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  sentController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    sentController.gmailDetail.length) {
                                  return sentController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      sentController.trashMessage(
                                        sentController.gmailDetail[i].id!,
                                      );
                                      final snackBar = SnackBar(
                                        content: const Text(
                                          'Moved to bin',
                                          style: TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor:
                                            Colors.black.withOpacity(0.8),
                                        duration:
                                            const Duration(seconds: 2),
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
                                      padding:
                                          const EdgeInsets.only(right: 20),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: GestureDetector(
                                      onDoubleTap: () {},
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SentMessageBody(
                                              message: sentController
                                                  .gmailDetail[i],
                                            ),
                                          ),
                                        );
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String? token =
                                            prefs.getString('token');
                                        await AuthService()
                                            .markMessageAsSeen(
                                                messageId: sentController
                                                    .gmailDetail[i].id!,
                                                accessToken: token!);
                                      },
                                      child: ListItems(
                                        isStarred: sentController
                                            .gmailDetail[i].labelIds!
                                            .contains('STARRED')
                                        ? true
                                        : false ,
                                        i: i,
                                        date:
                                            sentController.getFormattedDate(
                                                int.tryParse(sentController
                                                        .gmailDetail[i]
                                                        .internalDate!) ??
                                                    000),
                                        from: sentController.gmailDetail[i]
                                                .payload?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: sentController
                                                .gmailDetail[i]
                                                .payload!
                                                .headers!
                                                .any((element) =>
                                                    element.name ==
                                                    'Subject')
                                            ? (sentController.gmailDetail[i]
                                                        .payload?.headers
                                                        ?.where((element) =>
                                                            element.name ==
                                                            "Subject")
                                                        .toList()
                                                        .first
                                                        .value
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? sentController
                                                    .gmailDetail[i]
                                                    .payload
                                                    ?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "Subject")
                                                    .toList()
                                                    .first
                                                    .value
                                                : '(No Subject)'
                                            : '(No Subject)',
                                        snippet: sentController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: sentController
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
