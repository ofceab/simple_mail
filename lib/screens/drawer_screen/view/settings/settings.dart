import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  InboxController inboxController = Get.put(InboxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   flexibleSpace: Container(
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
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text('Settings'),
          ],
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
              ),
              title: Text(
                overflow: TextOverflow.ellipsis,
                FirebaseAuth.instance.currentUser!.displayName != null
                    ? FirebaseAuth.instance.currentUser!.displayName!
                    : '',
                maxLines: 1,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                FirebaseAuth.instance.currentUser!.email!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: const Color(0xFF434343),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      size: 42,
                      color: Color(0xFF434343),
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF434343),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      size: 38,
                      color: Color(0xFF434343),
                    ),
                    title: Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF434343),
                      ),
                    ),
                  ),
                ],
              ),
            ),
           
           Column(crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                ListTile(
              leading: const Icon(
                Icons.login_outlined,
                size: 42,
                color: Color(0xFF434343),
              ),
              title: const Text(
                'LogOut',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF434343),
                ),
              ),
              onTap: (() async {
                await inboxController.executeInBackground();
                await inboxController.signOutUser();
              }),
            ),
       
           ],)],
        ),
      ),
      ),
    );
  }
}
