import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/promotion/promotions_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class PromotionScreen extends StatefulWidget {
  @override
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  late PromotionController _promotionController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _promotionController = Get.put(PromotionController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_promotionController.isLoading) {
        _promotionController.moreListCalling();
        _promotionController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: PromotionController(),
        builder: (promotionController) {
          return (promotionController.isLoading &&
                  promotionController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : promotionController.isRefreshing
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
                        promotionController.changeRefreshing(true);
                        promotionController.gmailDetail = [];
                        promotionController.allInboxMessages = Allmessages();
                        promotionController.gmailDetail.clear();
                        promotionController.nextPageToken = null;
                        promotionController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();

                        await promotionController.fetchInboxMessages();
                        promotionController.changeRefreshing(false);
                      }),
                      child: promotionController.gmailDetail.isEmpty
                          ? LayoutBuilder(
                              builder: (procont, constraints) => ListView(
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
                                  promotionController.gmailDetail.length +
                                      1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    promotionController
                                        .gmailDetail.length) {
                                  // Show a loading indicator if we're currently loading more items
                                  return promotionController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      promotionController.trashMessage(
                                        promotionController
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
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GmailMessageBody(
                                              i: i,
                                              message: promotionController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: promotionController
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
                                                    promotionController
                                                        .gmailDetail[i].id!,
                                                accessToken: token!);
                                        promotionController
                                            .gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        promotionController.update();
                                      },
                                      child: ListItems(
                                        isStarred: promotionController
                                                .gmailDetail[i].labelIds!
                                                .contains('STARRED')
                                            ? true
                                            : false,
                                        i: i,
                                        date: promotionController
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
                                        from: promotionController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: promotionController
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
                                        snippet: promotionController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: promotionController
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
