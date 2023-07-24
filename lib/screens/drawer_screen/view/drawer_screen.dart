import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/screens/drawer_screen/drawer_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/settings/settings.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/utils/colors.dart';

// ignore: must_be_immutable
class NavigationDrawer extends StatefulWidget {
  NavigationDrawer({super.key, required this.homeController});
  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
  HomeController homeController;
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  HomeController homeController = Get.put(HomeController());
  var shapeBorder = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(25),
      bottomRight: Radius.circular(25),
      bottomLeft: Radius.circular(0),
    ),
  );

  int _selectedIndex = 0;
  void showSnackbar(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        left: MediaQuery.of(context).size.width / 6,
        child: Material(
          color: Colors.transparent,
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColor.blackColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Text(
              'Copied to clipboard',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3)).then((value) {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return GetBuilder<DrawerNavController>(
        init: DrawerNavController(),
        id: 'drawer',
        builder: (context) {
          return Drawer(
            backgroundColor: const Color(0xFFF2F3FF),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F3FF),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!),
                    ),
                    accountName: Text(
                      FirebaseAuth.instance.currentUser!.displayName != null
                          ? FirebaseAuth.instance.currentUser!.displayName!
                          : '',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    accountEmail: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(FirebaseAuth.instance.currentUser!.email!),
                        Padding(
                          padding: EdgeInsets.only(right: 25.w),
                          child: InkWell(
                            child: const Icon(Icons.copy),
                            onTap: () {
                              final email =
                                  FirebaseAuth.instance.currentUser!.email!;
                              Clipboard.setData(ClipboardData(text: email))
                                  .then((value) => showSnackbar(ctx));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListView(
                      shrinkWrap: true,
                      // padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      children: [
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 0,
                          leading: const Icon(Icons.move_to_inbox),
                          title: const Text("Inbox",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(0, widget.homeController);
                            widget.homeController.currentTabAPI = 'INBOX';
                          }),
                        ),
                       
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 1,
                          leading: const Icon(Icons.star_border_outlined),
                          title: const Text("Starred",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(1, widget.homeController);
                            widget.homeController.currentTabAPI = 'STARRED';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 2,
                          leading: const Icon(Icons.label_important_outline),
                          title: const Text("Important",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(2, widget.homeController);
                            widget.homeController.currentTabAPI = 'IMPORTANT';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 3,
                          leading: const Icon(Icons.send),
                          title: const Text("Sent",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(3, widget.homeController);
                            widget.homeController.currentTabAPI = 'SENT';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 4,
                          leading: const Icon(Icons.note_outlined),
                          title: const Text("Drafts",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(4, widget.homeController);
                            widget.homeController.currentTabAPI = 'DRAFT';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 5,
                          leading: const Icon(Icons.mark_email_unread_outlined),
                          title: const Text("Unread",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(5, widget.homeController);
                            widget.homeController.currentTabAPI = 'UNREAD';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 6,
                          leading: const Icon(Icons.person),
                          title: const Text("Personal",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(6, widget.homeController);
                            widget.homeController.currentTabAPI =
                                'CATEGORY_PERSONAL';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 7,
                          leading: const Icon(Icons.group_outlined),
                          title: const Text("Social",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(7, widget.homeController);
                            widget.homeController.currentTabAPI =
                                'CATEGORY_SOCIAL';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 8,
                          leading: const Icon(Icons.sell_outlined),
                          title: const Text("Promotions",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(8, widget.homeController);
                            widget.homeController.currentTabAPI =
                                'CATEGORY_PROMOTIONS';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 9,
                          leading: const Icon(Icons.report_outlined),
                          title: const Text("Spam",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(9, widget.homeController);
                            widget.homeController.currentTabAPI = 'SPAM';
                          }),
                        ),
                        ListTile(
                          selectedTileColor: AppColor.drawerTileColor,
                          selectedColor: AppColor.whiteColor,
                          // shape: shapeBorder,
                          selected: context.selectedIndex == 10,
                          leading: const Icon(Icons.delete_outlined),
                          title: const Text("Bin",
                              style: TextStyle(fontSize: 15.0)),
                          onTap: (() async {
                            Get.back();
                            context.setSelectedIndex(10, widget.homeController);
                            widget.homeController.currentTabAPI = 'TRASH';
                          }),
                        ),
                        // ListTile(
                        //   selectedTileColor: AppColor.homeBackgroundColor,
                        //   shape: shapeBorder,
                        //   selected: context.selectedIndex == 11,
                        //   leading: Icon(Icons.settings),
                        //   title: Text("Settings",
                        //       style: TextStyle(fontSize: 15.0)),
                        //   onTap: (() {Get.back();
                        //     // context.setSelectedIndex(11, widget.homeController);
                        //     // Get.back();
                        //     // homeController.setSelectedIndex(11);
                        //   }),
                        // ),
                        // ListTile(
                        //   selectedTileColor: AppColor.homeBackgroundColor,
                        //   shape: shapeBorder,
                        //   selected: context.selectedIndex == 12,
                        //   leading: Icon(Icons.help),
                        //   title: Text("Help & feedback",
                        //       style: TextStyle(fontSize: 15.0)),
                        //   onTap: (() {
                        //     // context.setSelectedIndex(12, widget.homeController);
                        //     // Get.back();
                        //     // homeController.setSelectedIndex(12);
                        //   }),
                        // ),
                      ],
                    ),
                  ),
                   const Divider(
                          // color: AppColor.blackColor,
                        ),
                  Stack(
                    children: [
                      ListTile(
                        selectedTileColor: AppColor.drawerTileColor,
                        // shape: shapeBorder,
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text(
                          "Settings",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        onTap: () {
                          
                          Get.to(SettingScreen());
                          // Handle the click action for the Settings item
                          // For example, navigate to the settings screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SettingsScreen(),
                          //   ),
                          // );
                        },
                      ),
                    ],
                  ),
                  //     Container(
                  //   decoration: BoxDecoration(
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.12),
                  //         blurRadius: 6.0,
                  //         offset: const Offset(0, -3),
                  //       ),
                  //     ],
                  //   ),
                  //   child: BottomNavigationBar(
                  //     backgroundColor: Colors.white,
                  //     currentIndex: 0, // Only one item, so always index 0
                  //     onTap: (_) {
                  //       // Handle the click action for the bottom navigation bar item
                  //       // For example, navigate to the settings screen
                  //       // Navigator.push(
                  //       //   context,
                  //       //   MaterialPageRoute(
                  //       //     builder: (context) => SettingsScreen(),
                  //       //   ),
                  //       // );
                  //     },
                  //     selectedItemColor: AppColor.homeBackgroundColor,
                  //     unselectedItemColor: AppColor.grey,
                  //     items: const <BottomNavigationBarItem>[
                  //       BottomNavigationBarItem(
                  //         icon: Icon(Icons.settings),
                  //         label: 'Settings',
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        });
  }
}
