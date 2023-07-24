import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

// class InboxScreen extends StatefulWidget {
//   @override
//   _InboxScreenState createState() => _InboxScreenState();
// }

// class _InboxScreenState extends State<InboxScreen> {
//   late InboxController _inboxController;
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _inboxController = Get.put(InboxController(), permanent: true);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       if (!_inboxController.isLoading) {
//         _inboxController.moreListCalling();
//         _inboxController.fetchInboxMessages();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<InboxController>(
//         init: InboxController(),
//         builder: (inboxController) {
//           if (inboxController.isLoading &&
//               inboxController.isListMoreLoading == false) {
//             return _buildLoadingContainer();
//           } else if (inboxController.isRefreshing) {
//             return _buildRefreshingContainer();
//           } else {
//             return _buildInboxListContainer(inboxController);
//           }
//         });
//   }

//   Widget _buildLoadingContainer() {
//     return Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30.w),
//             topRight: Radius.circular(30.w),
//           ),
//           // color: AppColor.homeBackgroundColor,
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(),
//         ));
//   }

//   Widget _buildRefreshingContainer() {
//     return ClipRRect(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(40.w),
//         topRight: Radius.circular(40.w),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(40.w),
//             topRight: Radius.circular(40.w),
//           ),
//           // color: AppColor.homeBackgroundColor,
//         ),
//         child: _buildLoadingListView(),
//       ),
//     );
//   }

//   Widget _buildLoadingListView() {
//     return LayoutBuilder(
//       builder: (incont, constraints) => ListView(
//         children: [
//           Container(
//             padding: EdgeInsets.all(20.w),
//             constraints: BoxConstraints(
//               minHeight: constraints.maxHeight,
//             ),
//             child: const Center(child: CircularProgressIndicator()),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildInboxListContainer(InboxController inboxController) {
//     return RefreshIndicator(
//       key: _refreshIndicatorKey,
//       onRefresh: (() async {
//         await _handleRefresh(inboxController);
//       }),
//       child: ClipRRect(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(40.w),
//           topRight: Radius.circular(40.w),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(40.w),
//               topRight: Radius.circular(40.w),
//             ),
//             // color: AppColor.homeBackgroundColor,
//           ),
//           child: _buildContent(inboxController),
//         ),
//       ),
//     );
//   }

//   Future _handleRefresh(InboxController inboxController) async {
//     inboxController.changeRefreshing(true);
//     inboxController.gmailDetail = [];
//     inboxController.allInboxMessages = Allmessages();
//     inboxController.gmailDetail.clear();
//     inboxController.nextPageToken = null;
//     inboxController.unreadGmailDetails.clear();
//     _refreshIndicatorKey.currentState?.deactivate();
//     await inboxController.executeInBackground();
//     await inboxController.fetchInboxMessages();
//     inboxController.changeRefreshing(false);
//   }

//   Widget _buildContent(InboxController inboxController) {
//     return inboxController.gmailDetail.isEmpty
//         ? _buildNoEmailMessage()
//         : _buildEmailList(inboxController);
//   }

//   Widget _buildNoEmailMessage() {
//     return LayoutBuilder(
//       builder: (incont, constraints) => ListView(
//         children: [
//           Container(
//             padding: EdgeInsets.all(20.w),
//             constraints: BoxConstraints(
//               minHeight: constraints.maxHeight,
//             ),
//             child: Center(
//               child: Text(
//                 'No Emails to show',
//                 style: TextStyle(color: AppColor.blackColor, fontSize: 20.sp),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildEmailList(InboxController inboxController) {
//     return ListView.builder(
//       controller: _scrollController,
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: inboxController.gmailDetail.length + 1,
//       itemBuilder: (BuildContext context, int i) {
//         if (i == inboxController.gmailDetail.length) {
//           return _buildProgressIndicator(inboxController);
//         } else {
//           return _buildListItem(context, inboxController, i);
//         }
//       },
//     );
//   }

//   Widget _buildProgressIndicator(InboxController inboxController) {
//     return inboxController.isLoading
//         ? const Center(
//             child: CircularProgressIndicator(),
//           )
//         : Container();
//   }

//   Widget _buildListItem(
//       BuildContext context, InboxController inboxController, int i) {
//     return Dismissible(
//       key: UniqueKey(),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         _handleDismiss(context, inboxController, i);
//       },
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       child: _buildListItems(context, inboxController, i),
//     );
//   }

//   void _handleDismiss(
//       BuildContext context, InboxController inboxController, int i) {
//     inboxController.trashMessage(
//       inboxController.gmailDetail[i].id!,
//     );
//     final snackBar = SnackBar(
//       content: const Text(
//         'Moved to bin',
//         style: TextStyle(color: Colors.white),
//       ),
//       backgroundColor: Colors.black.withOpacity(0.8),
//       duration: const Duration(seconds: 2),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   Widget _buildListItems(
//       BuildContext context, InboxController inboxController, int i) {
//     return GestureDetector(
//       onTap: () async {
//         await _handleTap(context, inboxController, i);
//       },
//       child: ListItems(
//         i: i,
//         date: inboxController.getFormattedDate(
//             int.tryParse(inboxController.gmailDetail[i].internalDate!) ?? 000),
//         from: inboxController.gmailDetail[i].payload?.headers
//                 ?.where((element) => element.name == "From")
//                 .toList()
//                 .first
//                 .value ??
//             '',
//         subject: inboxController.gmailDetail[i].payload!.headers!
//                 .any((element) => element.name == 'Subject')
//             ? (inboxController.gmailDetail[i].payload?.headers
//                         ?.where((element) => element.name == "Subject")
//                         .toList()
//                         .first
//                         .value
//                         ?.isNotEmpty ??
//                     false)
//                 ? inboxController.gmailDetail[i].payload?.headers
//                     ?.where((element) => element.name == "Subject")
//                     .toList()
//                     .first
//                     .value
//                 : '(No Subject)'
//             : '(No Subject)',
//         snippet: inboxController.gmailDetail[i].snippet ?? '',
//         isRead: inboxController.gmailDetail[i].labelIds!.contains('UNREAD')
//             ? false
//             : true,
//         isStarred: inboxController.gmailDetail[i].labelIds!.contains('STARRED')
//             ? true
//             : false,
//       ),
//     );
//   }

//   Future _handleTap(
//       BuildContext context, InboxController inboxController, int i) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GmailMessageBody(
//           i: i,
//           message: inboxController.gmailDetail[i],
//           threadId: '',
//           isStarred:
//               inboxController.gmailDetail[i].labelIds!.contains('STARRED')
//                   ? true
//                   : false,
//         ),
//       ),
//     );

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');

//     await AuthService().markMessageAsSeen(
//         messageId: inboxController.gmailDetail[i].id!, accessToken: token!);

//     inboxController.gmailDetail[i].labelIds!.remove('UNREAD');
//     inboxController.update();
//   }
// }

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late InboxController _inboxController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _inboxController = Get.put(InboxController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_inboxController.isLoading) {
        _inboxController.moreListCalling();
        _inboxController.fetchInboxMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InboxController>(
        init: InboxController(),
        builder: (inboxController) {
          return (inboxController.isLoading &&
                  inboxController.isListMoreLoading == false)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : inboxController.isRefreshing
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
                        inboxController.changeRefreshing(true);
                        inboxController.gmailDetail = [];
                        inboxController.allInboxMessages = Allmessages();
                        inboxController.gmailDetail.clear();
                        inboxController.nextPageToken = null;
                        inboxController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await inboxController.executeInBackground();
                        await inboxController.fetchInboxMessages();
                        inboxController.changeRefreshing(false);
                      }),
                      child: inboxController.gmailDetail.isEmpty
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
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: inboxController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i == inboxController.gmailDetail.length) {
                                  return inboxController.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      inboxController.trashMessage(
                                        inboxController.gmailDetail[i].id!,
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
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GmailMessageBody(
                                              i: i,
                                              message: inboxController
                                                  .gmailDetail[i],
                                              threadId: '',
                                              isStarred: inboxController
                                                      .gmailDetail[i].labelIds!
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

                                        await AuthService().markMessageAsSeen(
                                            messageId: inboxController
                                                .gmailDetail[i].id!,
                                            accessToken: token!);

                                        inboxController.gmailDetail[i].labelIds!
                                            .remove('UNREAD');
                                        inboxController.update();
                                      },
                                      child: ListItems(
                                        i: i,
                                        date: inboxController.getFormattedDate(
                                            int.tryParse(inboxController
                                                    .gmailDetail[i]
                                                    .internalDate!) ??
                                                000),
                                        from: inboxController
                                                .gmailDetail[i].payload?.headers
                                                ?.where((element) =>
                                                    element.name == "From")
                                                .toList()
                                                .first
                                                .value ??
                                            '',
                                        subject: inboxController.gmailDetail[i]
                                                .payload!.headers!
                                                .any((element) =>
                                                    element.name == 'Subject')
                                            ? (inboxController.gmailDetail[i]
                                                        .payload?.headers
                                                        ?.where((element) =>
                                                            element.name ==
                                                            "Subject")
                                                        .toList()
                                                        .first
                                                        .value
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? inboxController.gmailDetail[i]
                                                    .payload?.headers
                                                    ?.where((element) =>
                                                        element.name ==
                                                        "Subject")
                                                    .toList()
                                                    .first
                                                    .value
                                                : '(No Subject)'
                                            : '(No Subject)',
                                        snippet: inboxController
                                                .gmailDetail[i].snippet ??
                                            '',
                                        isRead: inboxController
                                                .gmailDetail[i].labelIds!
                                                .contains('UNREAD')
                                            ? false
                                            : true,
                                        isStarred: inboxController
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
