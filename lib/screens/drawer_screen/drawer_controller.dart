import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/utils/colors.dart';

class DrawerNavController extends GetxController {
  int selectedIndex = 0;
  String? token;
  bool isLoading = false;

  setSelectedIndex(int value, HomeController homeController) {
    homeController.gmailDetail.clear();
    homeController.nextPageToken = null;
    homeController.setSelectedIndex(value);
    homeController.isListMoreLoading = false;
    selectedIndex = value;
    update();
  }

  Color? getTileColor(int index) {
    if (index == selectedIndex) {
      return AppColor.homeIcon;
    } else {
      return null;
    }
  }

 

  
}
