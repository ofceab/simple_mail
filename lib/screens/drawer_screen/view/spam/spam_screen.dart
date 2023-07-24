import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/spam/spam_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class SpamScreen extends StatefulWidget {
  @override
  _SpamScreenState createState() => _SpamScreenState();
}

class _SpamScreenState extends State<SpamScreen> {
  late SpamController _homeController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _homeController = Get.put(SpamController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_homeController.isLoading) {
        _homeController.moreListCalling();
        _homeController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SpamController>(
        init: SpamController(),
        builder: (homeController) {
          return (homeController.isLoading &&
                  homeController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : homeController.isRefreshing
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
                        homeController.gmailDetail = [];
                        homeController.allInboxMessages = Allmessages();
                        homeController.gmailDetail.clear();
                        homeController.nextPageToken = null;
                        homeController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await homeController.executeInBackground();
                        await homeController.fetchInboxMessages();
                        homeController.changeRefreshing(false);
                      }),
                      child: homeController.gmailDetail.isEmpty
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
                                  homeController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    homeController.gmailDetail.length) {
                                  return homeController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      homeController.trashMessage(
                                        homeController.gmailDetail[i].id!,
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
                                                GmailMessageBody(
                                              i: i,
                                              message: homeController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: homeController
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
                                                messageId: homeController
                                                    .gmailDetail[i].id!,
                                                accessToken: token!);
                                        _homeController
                                            .gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        _homeController.update();
                                      },
                                      child: ListItems(
                                        i: i,
                                        date: homeController.gmailDetail[i]
                                                .payload?.headers
                                                ?.where((element) =>
                                                    element.name == "Date")
                                                .toList()
                                                .first
                                                .value
                                                ?.substring(4, 10) ??
                                            '',
                                        from: homeController.gmailDetail[i]
                                                .payload?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: homeController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name ==
                                                    "Subject")
                                                .toList()
                                                .first
                                                .value ??
                                         
                                            '',
                                        snippet: homeController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: homeController
                                                .gmailDetail[i].labelIds!
                                                .contains('UNREAD')
                                            ? false
                                            : true,
                                        isStarred: homeController
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
