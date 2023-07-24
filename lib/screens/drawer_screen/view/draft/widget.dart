import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/screens/home_screen/widgets/utils.dart';
import 'package:simplemail/utils/colors.dart';

class DraftListItems extends StatefulWidget {
  int i;
  String date;
  String from;
  dynamic subject;
  String snippet;
  final bool isRead;

  DraftListItems({
    required this.i,
    required this.date,
    required this.from,
    required this.subject,
    required this.snippet,
    required this.isRead,
  });

  static final List<Color> colorList = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    // Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  @override
  State<DraftListItems> createState() => _DraftListItemsState();
}

class _DraftListItemsState extends State<DraftListItems> {
  InboxController inboxController = Get.put(InboxController());
  late final int i;
  bool isStarred = false;


  @override
  Widget build(
    BuildContext context,
  ) {
    String prasedFrom = extractNameFromEmail(widget.from);
    Color color = generateRandomColor(widget.from);
    double deviceWidth = MediaQuery.of(context).size.width;
    // double fontSize = deviceWidth < 400 ? 12 : 14;
    const starred = false;

    // TextStyle titleStyle = widget.isRead
    //     ? TextStyle(
    //         color: AppColor.titleText,
    //         fontWeight: FontWeight.w600,
    //         fontSize: 16.sp)
    //     : TextStyle(
    //         color: AppColor.unreadTitleText,
    //         fontWeight: FontWeight.w700,
    //         fontSize: 17.sp,
    //       );

    // TextStyle subjectStyle = widget.isRead
    //     ? TextStyle(
    //         color: AppColor.subtitleText,
    //         fontWeight: FontWeight.w400,
    //         fontSize: 16.sp)
    //     : TextStyle(
    //         color: AppColor.unreadsubtitleText,
    //         fontWeight: FontWeight.w700,
    //         fontSize: 14.sp,
    //       );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Text(widget.from[0].toUpperCase()),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Draft',
                    overflow: TextOverflow.ellipsis,
                    // prasedFrom,
                    // split(RegExp(r'@|\<')).first
                    // length > 25 ? '${prasedFrom.substring(0, 24)}...' : prasedFrom,

                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    widget.date,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                        color: AppColor.homeIcon),
                  ),
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                widget.subject,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: AppColor.subtitleText, fontSize: 15.sp),
              ),
            ],
          ),
          subtitle: Text(
            widget.snippet,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: AppColor.snippet,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400),
          ),
          trailing: IconButton(
            icon: Icon(
              isStarred ? Icons.star : Icons.star_border,
            ),
            onPressed: () async {
              if (isStarred) {
                await inboxController.removeStarMessage(
                  index: i,
                    messageId: inboxController.gmailDetail[widget.i].id!,context: context);
              } else {
                await inboxController.starMessage(
                  index: widget.i,
                    messageId: inboxController.gmailDetail[widget.i].id!, context: context);
              }

              setState(() {
                isStarred = !isStarred; // Toggle the star state
              });
            },
            padding: const EdgeInsets.all(0),
            constraints:
                const BoxConstraints(), // This will remove any additional constraints
            iconSize: 18.0, // Adjust the icon size as needed
            color: isStarred
                ? Colors.blue
                : Colors.grey, // Change color based on star state
            // Adjust the color as needed
          ),),
    );
  }

  Color generateRandomColor(String name) {
    int hash = name.hashCode;
    Random random = Random(hash);
    return DraftListItems
        .colorList[random.nextInt(DraftListItems.colorList.length)];
    // Color.fromRGBO(
    //   random.nextInt(256),
    //   random.nextInt(256),
    //   random.nextInt(256),
    //   1,
    // );
  }
}
