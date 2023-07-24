import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/starred/starred_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class StarredScreen extends StatefulWidget {
  @override
  _StarredScreenState createState() => _StarredScreenState();
}

class _StarredScreenState extends State<StarredScreen> {
  late StarredController _starredController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _starredController = Get.put(StarredController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_starredController.isLoading) {
        _starredController.moreListCalling();
        _starredController.fetchInboxMessages();
      }
    }
  }

// String _extractNameFromEmail(String email) {
//   final nameInQuotesRegExp = RegExp(r'"([^"]*)');
//   final nameMatch = nameInQuotesRegExp.firstMatch(email);
//   if (nameMatch != null && nameMatch.groupCount >= 1) {
//     return nameMatch.group(1) ?? 'No name';
//   } else {
//     final nameRegExp = RegExp(r'^(.*?)<');
//     final match = nameRegExp.firstMatch(email);
//     if (match != null && match.groupCount >= 1) {
//       return match.group(1)?.trim() ?? 'No name';
//     }else if (email.contains("@")) {
//       return email.split("@")[0];
//     }
//   }
//   return 'No name';
// }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StarredController>(
        init: StarredController(),
        builder: (starredController) {
          return (starredController.isLoading &&
                  starredController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : starredController.isRefreshing
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
                        starredController.changeRefreshing(true);
                        starredController.gmailDetail = [];
                        starredController.allInboxMessages = Allmessages();
                        starredController.gmailDetail.clear();
                        starredController.nextPageToken = null;
                        starredController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await starredController.executeInBackground();
                        await starredController.fetchInboxMessages();
                        starredController.changeRefreshing(false);
                      }),
                      child: starredController.gmailDetail.isEmpty
                          ? LayoutBuilder(
                              builder: (starredContext, constraints) =>
                                  ListView(
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
                                  starredController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    starredController.gmailDetail.length) {
                                  return starredController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      starredController.trashMessage(
                                        starredController
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
                                              message: starredController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: starredController
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
                                                messageId: starredController
                                                    .gmailDetail[i].id!,
                                                accessToken: token!);

                                        _starredController
                                            .gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        _starredController.update();
                                      },
                                      child: ListItems(
                                          i: i,
                                          date: starredController.getFormattedDate(
                                              int.tryParse(starredController.gmailDetail[i].internalDate!) ??
                                                  000),
                                          from: starredController
                                                  .gmailDetail[i]
                                                  .payload
                                                  ?.headers
                                                  ?.where((element) =>
                                                      element.name ==
                                                      "From")
                                                  .toList()
                                                  .first
                                                  .value ??
                                              '',
                                          subject: starredController
                                                  .gmailDetail[i]
                                                  .payload
                                                  ?.headers
                                                  ?.where((element) => element.name == "Subject")
                                                  .toList()
                                                  .first
                                                  .value ??
                                              '',
                                          snippet: starredController.gmailDetail[i].snippet ?? '',
                                          isRead: starredController.gmailDetail[i].labelIds!.contains('UNREAD') ? false : true,
                                          isStarred: starredController.gmailDetail[i].labelIds!.contains('STARRED'),),
                                    ),
                                  );
                                }
                              },
                            ),
                    );
        });
  }
}
