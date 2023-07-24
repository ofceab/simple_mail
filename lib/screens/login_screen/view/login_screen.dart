import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/services/auth_service.dart';
import 'package:simplemail/utils/config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthService>(
        init: AuthService(),
        builder: (context) {
          return Scaffold(
              backgroundColor: AppColor.loginBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        _buildLogo(),
                        _buildAppName(),
                        SizedBox(
                          height: 100,
                        ),
                        _buildSignInButtons(),
                        _buildTermsAndPrivacy(),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  Widget _buildLogo() {
    return Image(
      image: const AssetImage('assets/images/logo.png'),
      height: 102.h,
      width: 123.w,
    );
  }

  Widget _buildAppName() {
    return Image(
      image: const AssetImage('assets/images/simplemail.png'),
      height: 95.h,
      width: 249.w,
    );
  }

  Widget _buildSignInButtons() {
    return Column(
      children: [
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
          width: double.infinity.w,
          height: 45.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5,
              backgroundColor: AppColor.loginBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.w),
                ),
              ),
            ),
            onPressed: () async {
              await AuthService().signInWithGoogle();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/gmail.png',
                  height: 40.h,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Login with Gmail',
                  style: TextStyle(color: AppColor.blackColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity.w,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5,
              backgroundColor: AppColor.loginBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.w)),
              ),
            ),
            onPressed: () {
              final snackBar = SnackBar(
                content: const Text(
                  'Soon You will be avialable to use ',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red.shade600,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                margin:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/outlook.png',
                  height: 30.h,
                ),
                SizedBox(
                  width: 12.w,
                ),
                Text(
                  AppText.comingSoon,
                  style: TextStyle(color: AppColor.blackColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Column(
      
      children: [
        SizedBox(
          height: 80.h,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 0),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text:
                      'By using our simple mail service and connecting your mailbox,you agree to our ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://simplemail.ai/privacy-statement/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Could not launch $url');
                      }
                    },
                ),
                const TextSpan(
                  text:
                      '. To learn more about how we collect and use your information, please review our ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://simplemail.ai/privacy-statement/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Could not launch $url');
                      }
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AuthService>(
//         init: AuthService(),
//         builder: (context) {
//           return Scaffold(
//               backgroundColor: AppColor.whiteColor,
//               body: SafeArea(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(16.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.all(16.w),
//                           child: SizedBox(
//                             height: 300.h,
//                             width: double.infinity,
//                             child: const Image(
//                                 image: AssetImage('assets/images/logo.png')),
//                           ),
//                         ),
//                         Image(
//                           image: const AssetImage('assets/images/simplemail.png'),
//                           height: 95.h,
//                           width: 249.w,
//                         ),
//                          SizedBox(
//                           height: 10.h,
//                         ),
//                         SizedBox(
//                           width: 210.w,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               elevation: 5,
//                               backgroundColor: AppColor.whiteColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(20.w),
//                                 ),
//                               ),
//                             ),
//                             onPressed: () async {
//                               await AuthService().signInWithGoogle();
//                             },
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/images/gmail.png',
//                                   height: 40.h,
//                                 ),
//                                 SizedBox(width: 10.w),
//                                 Text(
//                                   'Login with Gmail',
//                                   style: TextStyle(color: AppColor.blackColor),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 210.w,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               elevation: 5,
//                               backgroundColor: AppColor.whiteColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(20.w)),
//                               ),
//                             ),
//                             onPressed: () {},
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/images/outlook.png',
//                                   height: 30.h,
//                                 ),
//                                 SizedBox(
//                                   width: 5.w,
//                                 ),
//                                 Text(
//                                   AppText.comingSoon,
//                                   style: TextStyle(color: AppColor.blackColor),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 80.h,
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 0),
//                           child: RichText(
//                             text: const TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text:
//                                       'By using our simple mail service and connecting your mailbox, you agree to our ',
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                                 TextSpan(
//                                   text: 'Terms and Conditions',
//                                   style: TextStyle(color: Colors.blue),
//                                 ),
//                                 TextSpan(
//                                   text:
//                                       '. To learn more about how we collect and use your information, please review our ',
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                                 TextSpan(
//                                   text: 'Privacy Policy',
//                                   style: TextStyle(color: Colors.blue),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ));
//         });
//   }
// }
