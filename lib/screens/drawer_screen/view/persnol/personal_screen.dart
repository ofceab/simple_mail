import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/persnol/personal_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class PersonalScreen extends StatefulWidget {
  @override
  _PersonalScreenState createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  late PersonalController _personalController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _personalController = Get.put(PersonalController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_personalController.isLoading) {
        _personalController.moreListCalling();
        _personalController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalController>(
        init: PersonalController(),
        builder: (personalController) {
          return (personalController.isLoading &&
                  personalController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : personalController.isRefreshing
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
                        personalController.changeRefreshing(true);
                        personalController.gmailDetail = [];
                        personalController.allInboxMessages = Allmessages();
                        personalController.gmailDetail.clear();
                        personalController.nextPageToken = null;
                        personalController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await personalController.executeInBackground();
                        await personalController.fetchInboxMessages();
                        personalController.changeRefreshing(false);
                      }),
                      child: personalController.gmailDetail.isEmpty
                          ? LayoutBuilder(
                              builder: (percont, constraints) => ListView(
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
                                  personalController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    personalController.gmailDetail.length) {
                                  return personalController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      personalController.trashMessage(
                                        personalController
                                            .gmailDetail[i].id!,
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
                                              message: personalController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: personalController
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
                                                messageId:
                                                    personalController
                                                        .gmailDetail[i].id!,
                                                accessToken: token!);
                                        personalController
                                            .gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        personalController.update();
                                      },
                                      child: ListItems(
                                        isStarred: personalController
                                                .gmailDetail[i].labelIds!
                                                .contains('STARRED')
                                            ? true
                                            : false,
                                        i: i,
                                        date: personalController
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
                                        from: personalController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: personalController
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
                                        snippet: personalController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: personalController
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
