import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/login_screen/view/login_screen.dart';
import 'package:simplemail/screens/onboarding_screen/controller/onboarding_controller.dart';
import 'package:simplemail/utils/colors.dart';
import 'package:simplemail/utils/config.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController pageController = PageController(initialPage: 0);
  late Timer timer;
  // double blurValue = 10;
  late OnboardingController onboardingController;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    onboardingController = Get.put(OnboardingController());
 startTimer();
pageController.addListener(() {
    onboardingController.currentPage = pageController.page!.round();
  });
    // timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
    //   if (onboardingController.currentPage < 3) {
    //     onboardingController.currentPage++;
    //   } else {
    //     onboardingController.currentPage = 0;
    //   }

    //   pageController.animateToPage(
    //     onboardingController.currentPage,
    //     duration: const Duration(milliseconds: 350),
    //     curve: Curves.easeIn,
    //   );
    // });
    super.initState();
  }

void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (onboardingController.currentPage < 3) {
        onboardingController.currentPage++;
      } else {
        onboardingController.currentPage = 0;
      }

      pageController.animateToPage(
        onboardingController.currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: onboardingController,
        builder: (context) {
          return Scaffold(
            backgroundColor: Color(0xFFB5BCF8),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(
                          currentPage: context.currentPage,
                          numPages: context.numPages),
                    ),
                    SizedBox(height: 40.h),
                    Expanded(
                      child: PageView(
                        physics: const ClampingScrollPhysics(),
                        controller: pageController,
                        onPageChanged: (int page) async {
                          context.currentPage = page;
                          context.updateUi();

                          if (context.currentPage ==
                              onboardingController.numPages - 1) {
                            // final SharedPreferences prefs =
                            //     await SharedPreferences.getInstance();
                            // prefs.setBool('isOnboardingShowed', true);
                            Future.delayed(const Duration(seconds: 5), () {
                              Get.off(() => const LoginScreen());
                            });
                          }
                        },
                        children: [
                          Column(
                            children: [
                              Text(
                                "Click on 'UnreadSnap'to get all the\nunread Mails summarised for you",
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 18.sp),
                              ),
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/onboarding0.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Taking auto reply to the next level. AI\nchoose right words for you depending\non your input and the situation.',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    // fontWeight: FontWeight.bold,
                                    color: AppColor.whiteColor),
                              ),
                              Expanded(
                                child: Center(
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/images/onboarding1.png',
                                      ),
                                      Positioned(
                                        bottom: 150.h,
                                        right: 70.w,
                                        child: Text(
                                          "Click on 'AI reply'",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.sp,
                                              color: AppColor.whiteColor),
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 80.h,
                                          right: 20.w,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF7A85DE),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0),
                                            child: const Text(
                                              'AI reply',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Custom Reply customises replies. Data\nwill prompt our AI. Error-free.',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    // fontWeight: FontWeight.bold,
                                    color: AppColor.whiteColor),
                              ),
                              Expanded(
                                child: Center(
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/images/onboarding1.png',
                                      ),
                                      Positioned(
                                        bottom: 140.h,
                                        right: 30.w,
                                        child: Text(
                                          "Click on 'Custom AI reply'",
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 18.sp,
                                              color: AppColor.whiteColor),
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 80.h,
                                          right: 50.w,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF7A85DE),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0),
                                            child: const Text(
                                              'Custom AI reply',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // context.currentPage != context.numPages - 1
                    //     ? Container(
                    //         padding: EdgeInsets.symmetric(horizontal: 20.r),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           mainAxisSize: MainAxisSize.max,
                    //           children: <Widget>[
                    //             TextButton(
                    //               onPressed: () => pageController.jumpToPage(2),
                    //               child: Text(
                    //                 AppText.skipButton,
                    //                 style: TextStyle(
                    //                   color: AppColor.blackColor,
                    //                   fontSize: 25.sp,
                    //                 ),
                    //               ),
                    //             ),
                    //             TextButton(
                    //                 child: Text(
                    //                   AppText.nextButton,
                    //                   style: TextStyle(
                    //                     color: AppColor.blackColor,
                    //                     fontSize: 25.sp,
                    //                   ),
                    //                 ),
                    //                 onPressed: () {
                    //                   pageController.nextPage(
                    //                       duration:
                    //                           const Duration(milliseconds: 100),
                    //                       curve: Curves.easeInOut);
                    //                 }),
                    //           ],
                    //         ),
                    //       )
                    //     : const Text(''),
                    // Column(
                    //   children: [
                    //     context.currentPage == context.numPages - 1
                    //         ? SizedBox(
                    //             width: 200.w,
                    //             child: ElevatedButton(
                    //               style: ElevatedButton.styleFrom(
                    //                 shape: const StadiumBorder(),
                    //                 backgroundColor: AppColor.continueButton,
                    //                 // minimumSize: Size(200.w, 60.h)
                    //               ),
                    //               onPressed: () async {
                    //                 final SharedPreferences prefs =
                    //                     await SharedPreferences.getInstance();
                    //                 prefs.setBool('isOnboardingShowed', true);
                    //                 Get.off(() => const LoginScreen());
                    //               },
                    //               child: Center(
                    //                 child: Padding(
                    //                   padding:
                    //                       EdgeInsets.fromLTRB(0, 0, 0, 5.h),
                    //                   child: Text(
                    //                     AppText.continueButton,
                    //                     style: TextStyle(
                    //                       color: AppColor.whiteColor,
                    //                       fontSize: 30.sp,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           )
                    //         : const Text(''), // Conditional expression
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

List<Widget> _buildPageIndicator(
    {required int numPages, required int currentPage}) {
  List<Widget> list = [];
  for (int i = 0; i < numPages; i++) {
    list.add(i == currentPage ? _indicator(true) : _indicator(false));
  }
  return list;
}

Widget _indicator(bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: EdgeInsets.symmetric(horizontal: 8.w),
    height: 2.h,
    width: isActive ? 80.w : 40.w,
    decoration: BoxDecoration(
      color: isActive ? Color(0xFF7A85DE) : AppColor.whiteColor,
      borderRadius: BorderRadius.all(Radius.circular(12.w)),
    ),
  );
}
