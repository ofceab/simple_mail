import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/important/important_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class ImportantScreen extends StatefulWidget {
  @override
  _ImportantScreenState createState() => _ImportantScreenState();
}

class _ImportantScreenState extends State<ImportantScreen> {
  late ImportantController _importantController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _importantController = Get.put(ImportantController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_importantController.isLoading) {
        _importantController.moreListCalling();
        _importantController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImportantController>(
        init: ImportantController(),
        builder: (importantController) {
          return (importantController.isLoading &&
                  importantController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : importantController.isRefreshing
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
                        importantController.changeRefreshing(true);
                        importantController.gmailDetail = [];
                        importantController.allInboxMessages = Allmessages();
                        importantController.gmailDetail.clear();
                        importantController.nextPageToken = null;
                        importantController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await importantController.executeInBackground();
                        await importantController.fetchInboxMessages();
                        importantController.changeRefreshing(false);
                      }),
                      child: importantController.gmailDetail.isEmpty
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
                                  importantController.gmailDetail.length +
                                      1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i ==
                                    importantController
                                        .gmailDetail.length) {
                                  // Show a loading indicator if we're currently loading more items
                                  return importantController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      importantController.trashMessage(
                                        importantController
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
                                              message: importantController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: importantController
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
                                        // token k ander value pref se aaegi
                                        await AuthService()
                                            .markMessageAsSeen(
                                                messageId:
                                                    importantController
                                                        .gmailDetail[i].id!,
                                                accessToken: token!);
                                        importantController
                                            .gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        importantController.update();
                                      },
                                      child: ListItems(
                                        isStarred: importantController
                                                .gmailDetail[i].labelIds!
                                                .contains('STARRED')
                                            ? true
                                            : false,
                                        i: i,
                                        date: importantController
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
                                        from: importantController
                                                .gmailDetail[i]
                                                .payload
                                                ?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: importantController
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
                                        snippet: importantController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: importantController
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
