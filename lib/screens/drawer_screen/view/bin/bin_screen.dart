import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/bin/bin_controller.dart';
import '../../../../Models/all_message.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../home_screen/view/homemessage_body.dart';
import '../../../home_screen/widgets/list_items.dart';

class BinScreen extends StatefulWidget {
  @override
  _BinScreenState createState() => _BinScreenState();
}

class _BinScreenState extends State<BinScreen> {
  late BinController _binController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _binController = Get.put(BinController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_binController.isLoading) {
        _binController.moreListCalling();
        _binController.fetchInboxMessages();
      }
    }
  }

  void handleDismissAction(DismissDirection direction, int i) {
    if (direction == DismissDirection.startToEnd) {
      // Permanently delete message
      String messageId = _binController.gmailDetail[i].id!;
      _binController.deleteMessage(messageId);
      final snackBar = SnackBar(
        content: const Text(
          'Permanently Deleted',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Restore message
      String messageId = _binController.gmailDetail[i].id!;
      _binController.restoreMessage(messageId);
      final snackBar = SnackBar(
        content: const Text(
          'Moved to Inbox',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void onListItemTap(BuildContext context, int i) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GmailMessageBody(
          i: i,
          message: _binController.gmailDetail[i],
          threadId: '',
          isStarred: _binController.gmailDetail[i].labelIds!.contains('Starred')
              ? false
              : true,
        ),
      ),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    await AuthService().markMessageAsSeen(
        messageId: _binController.gmailDetail[i].id!, accessToken: token!);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BinController>(
        init: BinController(),
        builder: (binController) {
          return (binController.isLoading &&
                  binController.isListMoreLoading == false)
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : binController.isRefreshing
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
                        binController.changeRefreshing(true);
                        binController.gmailDetail = [];
                        binController.allInboxMessages = Allmessages();
                        binController.gmailDetail.clear();
                        binController.nextPageToken = null;
                        binController.unreadGmailDetails.clear();
                        _refreshIndicatorKey.currentState?.deactivate();
                        await binController.fetchInboxMessages();
                        binController.changeRefreshing(false);
                      }),
                      child: binController.gmailDetail.isEmpty
                          ? _buildEmptyListMessage()
                          : ListView.builder(
                              controller: _scrollController,
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  binController.gmailDetail.length + 1,
                              itemBuilder: (BuildContext context, int i) {
                                if (i == binController.gmailDetail.length) {
                                  // Show a loading indicator if we're currently loading more items
                                  return binController.isLoading
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : Container();
                                } else {
                                  return _buildListItem(context, i);
                                }
                              },
                            ),
                    );
        });
  }

  Widget _buildEmptyListMessage() {
    return LayoutBuilder(
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
                style: TextStyle(color: AppColor.blackColor, fontSize: 20.sp),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int i) {
    return Dismissible(
      key: UniqueKey(),
      background: _buildDismissBackground(
          Colors.red, Icons.delete, Alignment.centerRight),
      secondaryBackground: _buildDismissBackground(
          Colors.green, Icons.restore, Alignment.centerLeft),
      onDismissed: (direction) {
        handleDismissAction(direction, i);
      },
      child: GestureDetector(
        onTap: () {
          onListItemTap(context, i);
          _binController.gmailDetail[i].labelIds!.remove('UNREAD');
          _binController.update();
        },
        child: ListItems(
          isStarred: _binController.gmailDetail[i].labelIds!.contains('STARRED')
              ? true
              : false,
          i: i,
          date: _binController.getFormattedDate(
              int.tryParse(_binController.gmailDetail[i].internalDate!) ?? 0),
          from: _binController.gmailDetail[i].payload?.headers
                  ?.where((element) => element.name == "From")
                  .toList()
                  .first
                  .value ??
              '',
          subject: _binController.gmailDetail[i].payload?.headers
                  ?.where((element) => element.name == "Subject")
                  .toList()
                  .first
                  .value ??
              '',
          snippet: _binController.gmailDetail[i].snippet ?? '',
          isRead: _binController.gmailDetail[i].labelIds!.contains('UNREAD')
              ? false
              : true,
        ),
      ),
    );
  }

  Widget _buildDismissBackground(
      Color color, IconData icon, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

       








// class BinScreen extends StatefulWidget {
//   @override
//   _BinScreenState createState() => _BinScreenState();
// }

// class _BinScreenState extends State<BinScreen> {
//   late BinController _binController;
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _binController = Get.put(BinController(), permanent: true);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     super.dispose();
//   }

//   _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       if (!_binController.isLoading) {
//         _binController.moreListCalling();
//         _binController.fetchInboxMessages();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<BinController>(
//         init: BinController(),
//         builder: (binController) {
//           return (binController.isLoading &&
//                   binController.isListMoreLoading == false)
//               ? const Center(
//                   child: CircularProgressIndicator(),
//                 )
//               : RefreshIndicator(
//                   strokeWidth: 0.0,
//                   color: Colors.transparent,
//                   backgroundColor: AppColor.homeBackgroundColor,
//                   key: _refreshIndicatorKey,
//                   onRefresh: (() async {
//                     binController.gmailDetail = [];
//                     binController.allInboxMessages = Allmessages();
//                     binController.gmailDetail.clear();
//                     binController.nextPageToken = null;
//                     binController.unreadGmailDetails.clear();
//                     _refreshIndicatorKey.currentState?.deactivate();
//                     await binController.fetchInboxMessages();
//                   }),
//                   child: binController.gmailDetail.isEmpty
//                       ? LayoutBuilder(
//                           builder: (incont, constraints) => ListView(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(20.w),
//                                 constraints: BoxConstraints(
//                                   minHeight: constraints.maxHeight,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     'No Emails to show',
//                                     style: TextStyle(
//                                         color: AppColor.blackColor,
//                                         fontSize: 20.sp),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         )
//                       : ListView.builder(
//                           controller: _scrollController,
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           itemCount: binController.gmailDetail.length + 1,
//                           itemBuilder: (BuildContext context, int i) {
//                             if (i == binController.gmailDetail.length) {
//                               // Show a loading indicator if we're currently loading more items
//                               return binController.isLoading
//                                   ? const Center(
//                                       child: CircularProgressIndicator())
//                                   : Container();
//                             } else {
//                               return Dismissible(
//                                 key: UniqueKey(),
//                                 background: Container(
//                                   color: Colors.red,
//                                   alignment: Alignment.centerRight,
//                                   child: Padding(
//                                     padding: EdgeInsets.only(right: 20.w),
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 secondaryBackground: Container(
//                                   color: Colors.green,
//                                   alignment: Alignment.centerLeft,
//                                   child: Padding(
//                                     padding: EdgeInsets.only(left: 20.w),
//                                     child: const Icon(
//                                       Icons.restore,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 onDismissed: (direction) {
//                                   if (direction ==
//                                       DismissDirection.startToEnd) {
//                                     // Permanently delete message
//                                     String messageId =
//                                         binController.gmailDetail[i].id!;
//                                     binController.deleteMessage(messageId);
//                                   } else {
//                                     // Restore message
//                                     String messageId =
//                                         binController.gmailDetail[i].id!;
//                                     binController.restoreMessage(messageId);
//                                     Get.snackbar(
//                                       'Move to Inbox',
//                                       '',
//                                       backgroundColor: Colors.black,
//                                       colorText: Colors.white,
//                                       duration: const Duration(seconds: 2),
//                                       snackPosition: SnackPosition.BOTTOM,
//                                     );
//                                   }
//                                 },
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => GmailMessageBody(
//                                           message: binController.gmailDetail[i],
//                                         ),
//                                       ),
//                                     );
//                                     SharedPreferences prefs =
//                                         await SharedPreferences.getInstance();
//                                     String? token = prefs.getString('token');
//                                     // token k ander value pref se aaegi
//                                     await AuthService().markMessageAsSeen(
//                                         messageId:
//                                             binController.gmailDetail[i].id!,
//                                         accessToken: token!);
//                                   },
//                                   child: ListItems(
//                                     i: i,
//                                     date: binController.getFormattedDate(
//                                         int.tryParse(binController
//                                                 .gmailDetail[i]
//                                                 .internalDate!) ??
//                                             0),
//                                     from: binController
//                                             .gmailDetail[i].payload?.headers
//                                             ?.where((element) =>
//                                                 element.name == "From")
//                                             .toList()
//                                             .first
//                                             .value ??
//                                         '',
//                                     title: binController
//                                             .gmailDetail[i].payload?.headers
//                                             ?.where((element) =>
//                                                 element.name == "Subject")
//                                             .toList()
//                                             .first
//                                             .value ??
//                                         // ?.substring(0, 10) ??
//                                         '',
//                                     threadId: binController
//                                             .gmailDetail[i].payload?.headers
//                                             ?.where((element) =>
//                                                 element.name == "Subject")
//                                             .toList()
//                                             .first
//                                             .value ??
//                                         // ?.substring(0, 12) ??
//                                         '',
//                                     snippet:
//                                         binController.gmailDetail[i].snippet ??
//                                             '',
//                                     isRead: binController
//                                             .gmailDetail[i].labelIds!
//                                             .contains('UNREAD')
//                                         ? false
//                                         : true,
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                 );
//         });
//   }
// }
