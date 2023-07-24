import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:simplemail/Models/email_reply.dart';
import 'package:simplemail/screens/compose/controller/compose_controller.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/utils/colors.dart';
import 'package:simplemail/utils/config.dart';

class SummaryReplyScreen extends StatefulWidget {
  const SummaryReplyScreen(
      {required this.senderEmail,
      required this.loggedInEmail,
      required this.subject,
      required this.originalMessage});
  @override
  State<SummaryReplyScreen> createState() => _EmailReplyScreenState();

  final String senderEmail;
  final String loggedInEmail;
  final String subject;
  final String originalMessage;
}

class _EmailReplyScreenState extends State<SummaryReplyScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  FocusNode toFocusNode = FocusNode();
  FocusNode ccFocusNode = FocusNode();
  FocusNode bccFocusNode = FocusNode();
  FocusNode fromFocusNode = FocusNode();
  FocusNode subjectFocusNode = FocusNode();
  FocusNode bodyFocusNode = FocusNode();

  final List<String> menuTabItems = [
    'Schedule send',
    "Confidential Mode",
    "Discard",
    "Settings",
    "help and feedback"
  ];

  bool isLoading = false;
  bool isExpanded = false;
  bool isPressed = false;

  String currentState = 'all';
  bool reloadigCustom = false;
  bool reloadigPositive = false;
  bool reloadigNegative = false;
  bool isSummariseLoading = false;
  bool isSummariseBackLoading = false;
  bool isCustomLoading = false;
  bool isCustomBackLoading = false;
  bool isPositiveLoading = false;
  bool isPositiveBackLoading = false;
  bool isNegativeLoading = false;
  bool isNegativeBackLoading = false;
  bool isNeutralLoading = false;
  bool isNeutralBackLoading = false;

  HomeController homeController = HomeController();

  Future<void> _submit() async {
    final to = _toController.text.trim();
    final cc = _ccController.text.trim();
    final bcc = _bccController.text.trim();
    final from = _fromController.text.trim();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();

    await homeController.replyToGmailMessage(
        homeController.gmailMessage.threadId!,
        homeController.gmailMessage.id!,
        to,
        from,
        cc,
        bcc,
        subject,
        body);
    // Get.offAll((int i) => GmailMessageBody(
    //       message: homeController.gmailDetail[i],
    //     ));
    Get.back();
    Get.snackbar(
      'Success',
      'Email sent successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void initState() {
    super.initState();
    _toController.text = widget.senderEmail.split(RegExp(r'@|\<')).first;
    _fromController.text = widget.loggedInEmail;
    _subjectController.text = 'Re: ${widget.subject}';
    _bodyController.text =
        '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (homeController) {
          return Scaffold(
              backgroundColor: AppColor.whiteColor,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: AppColor.whiteColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  color: AppColor.blackColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.attachment_outlined),
                    iconSize: 24,
                    color: AppColor.blackColor,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    iconSize: 24,
                    color: Colors.blue,
                    onPressed: _submit,
                  ),
                  InkWell(
                    child: PopupMenuButton(
                      color: AppColor.whiteColor,
                      iconSize: 24,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColor.blackColor,
                      ),
                      itemBuilder: (context) => menuTabItems
                          .map(
                            (itemName) => PopupMenuItem(
                              value: itemName,
                              child: Text(itemName),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        readOnly: true,
                        enabled: true,
                        controller: _toController,
                        focusNode: toFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: Text(
                            AppText.to,
                            style: TextStyle(
                                color: AppColor.grey, fontSize: 16.sp),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.expand_more),
                            color: AppColor.blackColor,
                            onPressed: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 10.h),
                          prefixIconConstraints: const BoxConstraints(),
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      isExpanded
                          ? Column(children: [
                            TextFormField(
                              readOnly: true,
                              autofocus: true,
                              controller: _ccController,
                              focusNode: ccFocusNode,
                              decoration: InputDecoration(
                                prefixIcon: Text(
                                  AppText.cc,
                                  style: TextStyle(
                                      color: AppColor.grey,
                                      fontSize: 16.sp),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.h, horizontal: 10.w),
                                prefixIconConstraints:
                                    const BoxConstraints(),
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: TextFormField(
                                autofocus: true,
                                readOnly: true,
                                controller: _bccController,
                                focusNode: bccFocusNode,
                                decoration: InputDecoration(
                                  prefixIcon: Text(
                                    AppText.bcc,
                                    style: TextStyle(
                                        color: AppColor.grey,
                                        fontSize: 16.sp),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15.h, horizontal: 10.w),
                                  prefixIconConstraints:
                                      const BoxConstraints(),
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ])
                          : const SizedBox(),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextFormField(
                          controller: _fromController,
                          style: TextStyle(color: AppColor.blackColor),
                          readOnly: true,
                          enabled: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 10.w),
                            prefixIconConstraints: const BoxConstraints(),
                            prefixIcon: Text(
                              AppText.from,
                              style: TextStyle(
                                  color: AppColor.grey, fontSize: 16.sp),
                            ),
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextFormField(
                          controller: _subjectController,
                          focusNode: subjectFocusNode,
                          decoration: InputDecoration(
                            hintText: AppText.subject,
                            hintStyle: TextStyle(color: AppColor.grey),
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(),
                      Expanded(
                        child: Container(
                          height: 500.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColor.homeBackgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              controller: _bodyController,
                              focusNode: bodyFocusNode,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: AppText.composeEmail,
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  overflow: TextOverflow.visible,
                                  color: AppColor.blackColor,
                                ),
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                              expands: true,
                              // minLines: null,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      aiFeautres(),
                    ],
                  ),
                ),
              ));
        });
  }

  aiFeautres() {
    switch (currentState) {
      case 'all':
        return showButton();

      case 'ai':
        return hideButton();
      case 'custom':
        return custom(); 
      case 'positive':
        return regpositive();
      case 'negative':
        return regnegative(); 
            case 'neutral':
        return regnetural(); 
      default:
         return Container(
          child: const Text("Default"),
        );
    }
  }

  Widget custom() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.composeButton,
              ),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  // _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.whiteColor,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () async {
                setState(() {
                  reloadigCustom = true;
                });
                EmailReply emailReply = await ComposeController()
                    .customReply('', _bodyController.text.toString());
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    reloadigCustom = false;
                  });
                });
              },
              child: reloadigCustom == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.whiteColor,
                    )),
        ),
      ],
    );
  }

  Widget regpositive() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  // _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.homeIcon,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () async {
                setState(() {
                  reloadigCustom = true;
                });
                EmailReply emailReply = await ComposeController()
                    .positive('', _bodyController.text.toString(), "Positive");
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    reloadigCustom = false;
                  });
                });
              },
              child: reloadigCustom == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.homeIcon,
                    )),
        ),
      ],
    );
  }

  Widget regnegative() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  // _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.homeIcon,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () async {
                setState(() {
                  reloadigCustom = true;
                });
                EmailReply emailReply = await ComposeController()
                    .negative('', _bodyController.text.toString(), "Negative");
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    reloadigCustom = false;
                  });
                });
              },
              child: reloadigCustom == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.homeIcon,
                    )),
        ),
      ],
    );
  }

  Widget regnetural() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  // _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.homeIcon,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () async {
                setState(() {
                  reloadigCustom = true;
                });
                EmailReply emailReply = await ComposeController()
                    .netural('', _bodyController.text.toString(), "Netural");
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    reloadigCustom = false;
                  });
                });
              },
              child: reloadigCustom == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.homeIcon,
                    )),
        ),
      ],
    );
  }

  Widget positive() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  // _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.whiteColor,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () async {
                setState(() {
                  reloadigPositive = true;
                });
                _bodyController.text = await ComposeController()
                    .positive('', _bodyController.text.toString(), 'Positive');

                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    currentState = 'positive';
                    reloadigPositive = false;
                    isPositiveBackLoading = true;
                  });
                });
              },
              child: reloadigPositive == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.whiteColor,
                    )),
        ),
      ],
    );
  }

  Widget negative() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.whiteColor,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () async {
                setState(() {
                  reloadigNegative = true;
                });
                _bodyController.text = await ComposeController()
                    .negative('', _bodyController.text.toString(), 'Negative');
                // Add your logic here that takes some time
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    currentState = 'negative';
                    reloadigNegative = false;
                    // isNegativeBackLoading = true;
                  });
                });
              },
              child: reloadigNegative == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.whiteColor,
                    )),
        ),
      ],
    );
  }

  Widget neutral() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  _bodyController.clear();
                  // isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.whiteColor,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () async {
                setState(() {
                  reloadigCustom = true;
                });
                EmailReply emailReply = await ComposeController()
                    .customReply('', _bodyController.text.toString());
                // Add your logic here that takes some time
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
                // Add your logic here that takes some time
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    reloadigCustom = false;
                  });
                });
              },
              child: reloadigCustom == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Icon(
                      Icons.autorenew,
                      color: AppColor.whiteColor,
                    )),
        ),
      ],
    );
  }

  Widget showButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () {
                setState(() {
                  currentState = 'ai';
                });
              },
              child: Text(
                AppText.aiReply,
                style: TextStyle(color: AppColor.whiteColor),
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () async {
                setState(() {
                  isCustomLoading = true;
                });
                EmailReply emailReply = await ComposeController()
                    .customReply('', _bodyController.text.toString());
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  setState(() {
                    currentState = 'custom';
                    isCustomLoading = false;
                    isCustomBackLoading = true;
                  });
                });
              },
              child: isCustomLoading == true
                  ? Container(
                      width: 24.w,
                      height: 24.h,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Text(
                      AppText.customAiReply,
                      style: TextStyle(color: AppColor.whiteColor),
                    )),
        ),
      ],
    );
  }

  Widget hideButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppColor.composeButton),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  // _bodyController.clear();
                  isPressed = !isPressed;
                });
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColor.whiteColor,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.composeButton),
            onPressed: () async {
              setState(() {
                isPositiveLoading = true;
              });
              EmailReply emailReply = await ComposeController()
                  .positive('', _bodyController.text.toString(), 'Positive');

              _subjectController.text = emailReply.subject;
              _bodyController.text = emailReply.email;
              // Add your logic here that takes some time
              await Future.delayed(const Duration(seconds: 1)).then((value) {
                setState(() {
                  currentState = 'positive';
                  isPositiveLoading = false;
                  isPositiveBackLoading = true;
                });
              });
            },
            child: isPositiveLoading == true
                ? Container(
                    width: 24.w,
                    height: 24.h,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(),
                  )
                : Text(
                    AppText.positive,
                    style: TextStyle(color: AppColor.whiteColor),
                  ),
          ),
        ),
        SizedBox(width: 2.w),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.composeButton),
            onPressed: () async {
              setState(() {
                isNegativeLoading = true;
              });
              EmailReply emailReply = await ComposeController()
                  .negative('', _bodyController.text.toString(), 'Negative');
              _subjectController.text = emailReply.subject;
              _bodyController.text = emailReply.email;
              // Add your logic here that takes some time
              await Future.delayed(const Duration(seconds: 1)).then((value) {
                setState(() {
                  currentState = 'negative';
                  isNegativeLoading = false;
                  isNegativeBackLoading = true;
                });
              });
            },
            child: isNegativeLoading == true
                ? Container(
                    width: 24.w,
                    height: 24.h,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(),
                  )
                : Text(
                    AppText.negative,
                    style: TextStyle(color: AppColor.whiteColor),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: AppColor.composeButton),
            onPressed: () async {
              setState(() {
                isNeutralLoading = true;
              });
              EmailReply emailReply = await ComposeController()
                  .netural('', _bodyController.text.toString(), "Neutral");
              // Add your logic here that takes some time
              _subjectController.text = emailReply.subject;
              _bodyController.text = emailReply.email;
              // Add your logic here that takes some time
              await Future.delayed(const Duration(seconds: 1)).then((value) {
                setState(() {
                  currentState = 'neutral';
                  isNeutralLoading = false;
                  isNegativeBackLoading = true;
                });
              });
            },
            child: isNeutralLoading == true
                ? Container(
                    width: 24.w,
                    height: 24.h,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(),
                  )
                : Text(
                    AppText.neutral,
                    style: TextStyle(color: AppColor.whiteColor),
                  ),
          ),
        ),
      ],
    );
  }
}
