
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:simplemail/utils/colors.dart';

Widget buildAccountSetting(
    // {required String name, required String email, required String imgPath}
    ) {
  return GetBuilder<InboxController>(builder: (inboxController) {
    InboxController inboxController = Get.put(InboxController());
    final accounts = inboxController.userAccounts;

    int index = inboxController.userAccounts.indexWhere(
        (account) => account.uid == inboxController.getCurrentAccountUid());

    return Dialog(
      elevation: 15,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 70.h,
            width: 250.w,
            child: const Image(
              image: AssetImage('assets/images/simplemail.png'),
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccountWidget(
                      name:
                            FirebaseAuth.instance.currentUser?.displayName != null
                                ? FirebaseAuth.instance.currentUser!.displayName!
                                : '',
                        mail: FirebaseAuth.instance.currentUser?.email ?? '',
                        imgPath: FirebaseAuth.instance.currentUser?.photoURL??'',
                  // name: name,
                  // mail: email,
                  // imgPath: imgPath,
                  key: const Key(''),
                ),
                const Divider(height: 2, color: Colors.black45),
                const SizedBox(height: 15),
                // Text('Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    // if (accounts[index].uid ==
                    //     inboxController.getCurrentAccountUid())
                    if(FirebaseAuth.instance.currentUser!.uid==accounts[index].uid)
                         {
                      // If it is, then return an empty Container for this item
                      return Container();
                    } else {
                      return ListTile(
                        leading: CircleAvatar(
                            // backgroundImage: NetworkImage(accounts[index].email),
                            backgroundImage:
                                NetworkImage(accounts[index].photoUrl)),
                        title: Text(accounts[index].email),
                        onTap: () async {
                          Get.back();
                          index = index;
                          SharedPreferences sh =
                              await SharedPreferences.getInstance();
                          sh.setString('a', accounts[index].uid);

                          await inboxController
                              .switchAccount(accounts[index].uid);
                          await Get.put(AuthService())
                              .switchAccount(accounts[index].uid);

                          print(accounts[index].uid);
                          // Close the account switcher dialog
                        },
                      );
                    }
                  },
                  shrinkWrap: true,
                ),
                const SizedBox(height: 10),
                // Container(
                //   margin: const EdgeInsets.only(
                //     left: 10,
                //     bottom: 10,
                //   ),
                //   child: TextButton.icon(
                //       onPressed: () {
                //         Get.to(() => const LoginScreen());
                //       },
                //       icon: Icon(Icons.person_add, color: Colors.grey[600]),
                //       label: Text('Add another account',
                //           style: TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.w600,
                //               color: Colors.grey[700]))),
                // ),
                
                // const Divider(height: 2, color: Colors.black45),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: TextButton.icon(
                    onPressed: () async {

                      // await Get.find<AuthService>().userSignOut(inboxController.currentAccountIndex);
                      await inboxController.executeInBackground();
                      await inboxController.signOutUser();
                    },
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  });
}

class AccountWidget extends StatelessWidget {
  const AccountWidget({
    required this.name,
    required this.mail,
    required this.imgPath,
    required Key key,
  }) : super(key: key);
  final String name, mail, imgPath;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InboxController>(builder: (inboxController) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 15,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black26,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage(imgPath),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:  TextStyle(
                      color: AppColor.blackColor,
                        fontSize: 16.sp, fontWeight: FontWeight.w700)),
                Text(mail,
                    style:  TextStyle(
                      color: Color(0xff6B6B6B),
                        fontSize: 14.sp, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
      );
    });
  }
}
// Widget buildAccountSetting(
//     {required String name,
//     required String email,
//     required String imgPath,
//     required String uid}) {
//   return GetBuilder<InboxController>(builder: (inboxController) {
//     InboxController inboxController = Get.put(InboxController());
//     final AuthService authService = Get.put(AuthService());
//     final accounts = inboxController.userAccounts;

//     // int index = inboxController.userAccounts
//     //     .indexWhere((element) => element.uid == uid);
//     int index = inboxController.userAccounts.indexWhere(
//         (account) => account.uid == inboxController.getCurrentAccountUid());
//     return Dialog(
//       elevation: 15,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             height: 70.h,
//             width: 250.w,
//             child: const Image(
//               image: AssetImage('assets/images/simplemail.png'),
//             ),
//           ),
//           Container(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AccountWidget(
//                   name: name,
//                   mail: email,
//                   imgPath: imgPath,
//                   key: const Key(''),
//                 ),
//                 const Divider(height: 2, color: Colors.black45),
//                 const SizedBox(height: 15),
//                 // Text('Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

//                 ListView.builder(
//                   itemCount: accounts.length,
//                   itemBuilder: (context, index) {
//                     if (accounts[index].uid ==
//                         inboxController.getCurrentAccountUid()) {
//                       // If it is, then return an empty Container for this item
//                       return Container();
//                     } else {
//                       return ListTile(
//                         leading: CircleAvatar(
//                             // backgroundImage: NetworkImage(accounts[index].email),
//                             backgroundImage:
//                                 NetworkImage(accounts[index].photoUrl)),
//                         title: Text(accounts[index].email),
//                         onTap: () async {
//                           Get.back();
//                           index = index;
//                           SharedPreferences sh =
//                               await SharedPreferences.getInstance();
//                           sh.setString('a', accounts[index].uid);

//                           await inboxController
//                               .switchAccount(accounts[index].uid);
//                           await Get.put(AuthService())
//                               .switchAccount(accounts[index].uid);

//                           print(accounts[index].uid);
//                           // Close the account switcher dialog
//                         },
//                       );
//                     }
//                   },
//                   shrinkWrap: true,
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   margin: const EdgeInsets.only(
//                     left: 10,
//                     bottom: 10,
//                   ),
//                   child: TextButton.icon(
//                       onPressed: () {
//                         Get.to(() => const LoginScreen());
//                       },
//                       icon: Icon(Icons.person_add, color: Colors.grey[600]),
//                       label: Text('Add another account',
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700]))),
//                 ),
//                 const Divider(height: 2, color: Colors.black45),
//                 const SizedBox(height: 15),
//                 Container(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 10,
//                   ),
//                   child: TextButton.icon(
//                     onPressed: () async {
//                       print(uid);
//                       // await Get.find<AuthService>().userSignOut(inboxController.currentAccountIndex);
//                       await inboxController.signOutUser(uid);
//                     },
//                     icon: const Icon(
//                       Icons.logout,
//                     ),
//                     label: Text(
//                       'Sign out',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black87.withOpacity(0.8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   });
// }

// class AccountWidget extends StatelessWidget {
//   const AccountWidget({
//     required this.name,
//     required this.mail,
//     required this.imgPath,
//     required Key key,
//   }) : super(key: key);
//   final String name, mail, imgPath;
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<InboxController>(builder: (inboxController) {
//       return Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 15,
//         ),
//         margin: const EdgeInsets.symmetric(
//           horizontal: 10,
//           vertical: 15,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: const [
//             BoxShadow(
//               blurRadius: 5,
//               color: Colors.black26,
//               offset: Offset(2, 0),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 17,
//               backgroundImage: NetworkImage(imgPath),
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name,
//                     style: const TextStyle(
//                         fontSize: 15, fontWeight: FontWeight.w600)),
//                 Text(mail,
//                     style: const TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
