import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/home_screen/view/home_screen.dart';
import 'package:simplemail/screens/login_screen/view/login_screen.dart';
import 'package:simplemail/screens/onboarding_screen/view/onboarding_screen.dart';
import 'package:simplemail/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLoggedIn = false;
  bool? isOnboardingShowed = false;
  checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = (prefs.getBool('isLoggedIn') == null)
        ? false
        : prefs.getBool('isLoggedIn');
    isOnboardingShowed = (prefs.getBool('isOnboardingShowed') == null)
        ? false
        : prefs.getBool('isOnboardingShowed');
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
    Timer(const Duration(seconds: 1), () {
      isLoggedIn == false
          ? isOnboardingShowed!
              ? Get.offAll(() => const LoginScreen())
              : Get.offAll(() => const Onboarding())
          : Get.offAll(() => HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.splashBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 600.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: const AssetImage('assets/images/logo_foreground.png'),
                      height: 85.h,
                      width: 93.w,
                    ),
                    Image(
                      image: const AssetImage('assets/images/simplemail.png'),
                      height: 95.h,
                      width: 249.w,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
