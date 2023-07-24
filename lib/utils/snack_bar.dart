import 'package:flutter/material.dart';
import 'package:simplemail/utils/colors.dart';

void openSnackbar(context, snackMessage, color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: AppColor.snackbar,
    action: SnackBarAction(
      label: "OK",
      textColor: AppColor.whiteColor,
      onPressed: (() {}),
    ),
    content: Text(
      snackMessage,
      style: const TextStyle(fontSize: 14),
    ),
  ));
}
