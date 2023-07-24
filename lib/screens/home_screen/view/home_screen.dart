import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/compose/view/compose_email_screen.dart';
import 'package:simplemail/screens/drawer_screen/drawer_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/drawer_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/bin/bin_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/draft/draft_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/important/important_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/persnol/personal_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/promotion/promotions_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/sent/sent_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/social/social_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/spam/spam_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/starred/starred_screen.dart';
import 'package:simplemail/screens/drawer_screen/view/unread/unread_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/unread/unread_screen.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
// import 'package:simplemail/screens/search_screen/search_screen.dart';
import 'package:simplemail/screens/unread_snap/unreadsummary_screen.dart';
// import 'package:simplemail/screens/home_screen/widgets/account.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:simplemail/utils/colors.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String photoUrl = FirebaseAuth.instance.currentUser?.photoURL ?? '';
  DrawerNavController drawerNavController = Get.put(DrawerNavController());
  late HomeController _homeController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    Get.put(HomeController(), permanent: true);
    Get.put(AuthService().refreshTokenWhenExpired());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleSearchBar() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  InboxController inboxController = Get.put(InboxController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (homeController) {
          _homeController = homeController;
          return DefaultTabController(
            length: 1,
            child: Scaffold(
              // backgroundColor: AppColor.whiteColor,
              appBar: homeAppBar(
                  photoUrl: photoUrl,
                  homeController: homeController,
                  context: context,
                  toggleSearch: toggleSearchBar),
              drawer: NavigationDrawer(
                homeController: _homeController,
              ),
              body: screenReturner(homeController.selectedIndex),
              floatingActionButton: _floatingButton(),
            ),
          );
        });
  }

  UnreadController unreadController = Get.put(UnreadController());
  _floatingButton(// InboxController inboxController,
      ) {
    // if (_homeController.selectedIndex == 5 ||
    //     _homeController.selectedIndex == 0) {
    //   return Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       FloatingActionButton(
    //         backgroundColor: AppColor.composeButton,
    //         onPressed: () async {
    //           List<GmailMessage> gmails = _homeController.selectedIndex == 5
    //               ? unreadController.gmailDetail
    //               : inboxController.unreadGmailDetails;
    //           Get.to(
    //             () => UnreadEmailScreen(
    //               unreadGmailDetails: gmails,
    //               // index: 0,
    //             ),
    //           );
    //         },
    //         child: SvgPicture.asset(
    //           'assets/images/unreadsummarise.svg',
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       SizedBox(height: 16.h),
    //       FloatingActionButton(
    //         backgroundColor: AppColor.composeButton,
    //         heroTag: 'button2',
    //         onPressed: () {
    //           Get.to(
    //             () => ComposeScreen(
    //               email: FirebaseAuth.instance.currentUser!.email!,
    //             ),
    //           );
    //         },
    //         child: Icon(
    //           Icons.edit,
    //           color: AppColor.whiteColor,
    //         ),
    //       ),
    //     ],
    //   );
    // } else {
    return InkWell(
      onTap: () {
        Get.to(
          () => ComposeScreen(
            email: FirebaseAuth.instance.currentUser!.email!,
          ),
        );
      },
      child: Container(
        height: 56.h,
        width: 56.w,
        decoration: BoxDecoration(
          color: Color(0xFF7A85DE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            Icons.edit,
            color: AppColor.whiteColor,
            size: 24.sp,
          ),
        ),
      ),
    );
    // FloatingActionButton(
    //   backgroundColor: AppColor.composeButton,
    //   // heroTag: 'button2',
    //   onPressed: () {
    //     Get.to(
    //       () => ComposeScreen(
    //         email: FirebaseAuth.instance.currentUser!.email!,
    //       ),
    //     );
    //   },
    //   child: SvgPicture.asset(
    //     'assets/images/compose.svg',
    //     fit: BoxFit.cover,
    //   ),
    // );
    // }
  }
}

bool _isSearching = false;
UnreadController unreadController = Get.put(UnreadController());
homeAppBar({
  required String photoUrl,
  required HomeController homeController,
  required BuildContext context,
  required Function toggleSearch,
}) {
  return AppBar(
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF74AADF),
            Color(0xFF9698E3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: _isSearching
        ? Container(
            height: 40,
            // width: ,
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {},
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.grey,
                  onPressed: () {
                    toggleSearch;

                    //            showSearch(
                    //   context: context,
                    //   delegate: EmailSearchDelegate(),
                    // );
                  },
                ),
              ],
            ),
          )
        : Text(
            homeController.title,
            style: TextStyle(color: AppColor.whiteColor),
          ),
    leading: Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: Icon(
            Icons.menu,
            color: AppColor.whiteColor,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      },
    ),
    actions: [
      !_isSearching
          ? IconButton(
              icon: const Icon(Icons.search),
              color: AppColor.whiteColor,
              onPressed: () {
                toggleSearch;
                // showSearch(
                //   context: context,
                //   delegate: EmailSearchDelegate(),
                // );
              },
            )
          : const SizedBox.shrink(),
      // IconButton(
      //     icon: const Icon(Icons.more_vert),
      //     color: AppColor.blackColor,
      //     onPressed: () {
      //       Get.put(InboxController()).isLoading
      //           ? null
      //           : showDialog(
      //               context: context,
      //               builder: (BuildContext context) => buildAccountSetting());
      //     }),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 48.h,
          width: 307.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3FF),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      color: Color(0xFF434343),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Unread Snap",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF434343),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onTap: (value) {
              //  List<GmailMessage> gmails = _homeController.selectedIndex == 5
              //     ? unreadController.gmailDetail
              //     : inboxController.unreadGmailDetails;
              Get.to(
                () => UnreadEmailScreen(
                  unreadGmailDetails: unreadController.gmailDetail,
                  // index: 0,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

screenReturner(int val) {
  int value = val;
  switch (value) {
    case 1:
      {
        return StarredScreen();
      }
    case 2:
      {
        return ImportantScreen();
      }
    case 3:
      {
        return SentScreen();
      }
    case 4:
      {
        return DraftScreen();
      }
    case 5:
      {
        return UnreadScreen();
      }
    case 6:
      {
        return PersonalScreen();
      }
    case 7:
      {
        return SocialScreen();
      }
    case 8:
      {
        return PromotionScreen();
      }
    case 9:
      {
        return SpamScreen();
      }
    case 10:
      {
        return BinScreen();
      }
    default:
      {
        return InboxScreen();
      }
  }
}
