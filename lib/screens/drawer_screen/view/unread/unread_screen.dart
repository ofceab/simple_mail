import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/unread/unread_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class UnreadScreen extends StatefulWidget {
  @override
  _UnreadScreenState createState() => _UnreadScreenState();
}

class _UnreadScreenState extends State<UnreadScreen> {
  late UnreadController _unreadController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _unreadController = Get.put(UnreadController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_unreadController.isLoading) {
        _unreadController.moreListCalling();
        _unreadController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UnreadController>(
        init: UnreadController(),
        builder: (unreadController) {
          return (unreadController.isLoading &&
                  unreadController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : unreadController.isRefreshing
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
                      // strokeWidth: 0.0,
                      // color: Colors.transparent,
                      // backgroundColor: AppColor.homeBackgroundColor,
                      key: _refreshIndicatorKey,
                      onRefresh: (() async {
                        unreadController.changeRefreshing(true);
                        unreadController.gmailDetail = [];
                        unreadController.allInboxMessages = Allmessages();
                        unreadController.gmailDetail.clear();
                        unreadController.nextPageToken = null;
                        unreadController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await unreadController.fetchInboxMessages();
                        await unreadController.executeInBackground();
                        unreadController.changeRefreshing(false);
                      }),
                      child: unreadController.gmailDetail.isEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) => ListView(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20.0),
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
                                  unreadController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    unreadController.gmailDetail.length) {
                                  return unreadController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      unreadController.trashMessage(
                                        unreadController.gmailDetail[i].id!,
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
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GmailMessageBody(
                                              i: i,
                                              message: unreadController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: unreadController
                                                      .gmailDetail[i]
                                                      .labelIds!
                                                      .contains('STARRED')
                                                  ? true
                                                  : false,
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
                                                messageId: unreadController
                                                    .gmailDetail[i].id!,
                                                accessToken: token!);
                                        unreadController
                                            .gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        unreadController.update();
                                      },
                                      child: ListItems(
                                        i: i,
                                        date: unreadController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name == "Date")
                                                .toList()
                                                .first
                                                .value
                                                ?.substring(4, 10) ??
                                            '',
                                        from: unreadController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: unreadController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name ==
                                                    "Subject")
                                                .toList()
                                                .first
                                                .value ??
                                            // ?.substring(0, 10) ??
                                            '',
                                        snippet: unreadController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: unreadController
                                                .gmailDetail[i].labelIds!
                                                .contains('UNREAD')
                                            ? false
                                            : true,
                                        isStarred: unreadController
                                                .gmailDetail[i].labelIds!
                                                .contains('STARRED')
                                            ? true
                                            : false,
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
