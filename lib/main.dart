import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simplemail/splash_screen.dart';
import 'package:simplemail/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");

  FlutterError.onError = (details) {
    print(details);
  };
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.robotoTextTheme(
              const TextTheme(
                bodyText1: TextStyle(color: Colors.black, fontSize: 18),
                bodyText2: TextStyle(color: Colors.black54, fontSize: 16),
                headline1: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            primaryColor: AppColor.whiteColor,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
