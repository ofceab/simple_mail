import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/screens/home_screen/widgets/utils.dart';
import 'package:simplemail/utils/colors.dart';

class ListItems extends StatefulWidget {
  int i;
  String date;
  String from;
  var subject;
  String snippet;
  final bool isRead;
  final bool isStarred;
  ListItems({
    required this.i,
    required this.date,
    required this.from,
    required this.subject,
    required this.snippet,
    required this.isRead,
    required this.isStarred,
    Row? trailing,
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
  State<ListItems> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  InboxController inboxController = Get.put(InboxController());
  late bool isStarred;
  @override
  void initState() {
    isStarred = widget.isStarred;

    print("widget ${widget.i} is started value $isStarred");
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    String prasedFrom = extractNameFromEmail(widget.from);
    Color color = generateRandomColor(widget.from);
    double deviceWidth = MediaQuery.of(context).size.width;
    // double fontSize = deviceWidth < 400 ? 12 : 14;

    TextStyle titleStyle = widget.isRead
        ? TextStyle(
            color: AppColor.titleText,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp)
        : TextStyle(
            color: AppColor.unreadTitleText,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          );

    TextStyle subjectStyle = widget.isRead
        ? TextStyle(
            color: AppColor.subtitleText,
            fontWeight: FontWeight.w400,
            fontSize: 16.sp)
        : TextStyle(
            color: AppColor.unreadsubtitleText,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          );
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
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    overflow: TextOverflow.ellipsis,
                    prasedFrom,
                    // split(RegExp(r'@|\<')).first
                    // length > 25 ? '${prasedFrom.substring(0, 24)}...' : prasedFrom,

                    maxLines: 1,
                    style: titleStyle,
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
            ),
            SizedBox(
              height: 2.h,
            ),
            Text(
              widget.subject,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: subjectStyle,
            ),
          ],
        ),
        subtitle: Text(
          widget.snippet,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
              color: AppColor.snippet,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400),
        ),
        trailing: IconButton(
          icon: Icon(
            isStarred ? Icons.star : Icons.star_border,
          ),
          onPressed: () async {
            if (isStarred) {
              await inboxController.removeStarMessage(
                  index: widget.i,
                  messageId: inboxController.gmailDetail[widget.i].id!,
                  context: context,
                  updateList: true);
            } else {
              await inboxController.starMessage(
                  index: widget.i,
                  messageId: inboxController.gmailDetail[widget.i].id!,
                  context: context,
                  updateList: true);
            }

            setState(() {
              isStarred = !isStarred;
            });
          },
          padding: EdgeInsets.all(0),
          constraints: BoxConstraints(),
          iconSize: 25,
          color: isStarred ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Color generateRandomColor(String name) {
    int hash = name.hashCode;
    Random random = Random(hash);
    return ListItems.colorList[random.nextInt(ListItems.colorList.length)];
  }
}
