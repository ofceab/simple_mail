
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:simplemail/Models/email_reply.dart';
import 'package:simplemail/Models/gmail_message.dart';
import 'package:simplemail/screens/compose/controller/compose_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/draft/draft_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/inbox/inbox_controller.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/utils/colors.dart';
import 'package:simplemail/utils/config.dart';

class DraftReplyScreen extends StatefulWidget {
  const DraftReplyScreen(
      {required this.i,
      required this.senderEmail,
      required this.loggedInEmail,
      required this.subject,
      required this.cc,
      required this.bcc,
      required this.originalMessage,
      required this.gmailMessage});
  @override
  State<DraftReplyScreen> createState() => _DraftReplyScreenState();
  final int i;
  final GmailMessage gmailMessage;
  final String senderEmail;
  final String cc;
  final String bcc;
  final String loggedInEmail;
  final String subject;
  final String originalMessage;
}

class _DraftReplyScreenState extends State<DraftReplyScreen> {
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


  bool isPressed = false;
  bool isLoading = false;
  bool isExpanded = false;
  late final int i;

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
  InboxController inboxController = Get.put(InboxController());
  DraftController draftController = Get.put(DraftController());

  Future<void> _submit() async {
    final to = widget.senderEmail;
    final cc = widget.cc;
    final bcc = widget.bcc;
    final from = _fromController.text.trim();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();

    await draftController.updateDraft(
        widget.gmailMessage.id!, to, from, cc, bcc, subject, body);

    if (widget.gmailMessage != null && widget.gmailMessage.id != null) {
      await homeController.replyToGmailMessage(widget.gmailMessage.threadId!,
          widget.gmailMessage.id!, to, from, cc, bcc, subject, body);
    } else {
      print('Error: homeController.gmailMessage or its id is null');
      return;
    }
    // draftController.discardDraftMessage(
    //                                         draftController
    //                                             .draftMessages.drafts![i],
    //                                         draftController
    //                                             .draftMessages.drafts![i].id!);

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
    _toController.text = widget.senderEmail;
    _ccController.text = widget.cc;
    _bccController.text = widget.bcc;
    _fromController.text = widget.loggedInEmail;
    _subjectController.text = widget.subject;
    _bodyController.text = widget.originalMessage;
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
                  onPressed: () async {
                    final to = widget.senderEmail;
                    final cc = widget.cc;
                    final bcc = widget.bcc;
                    final from = _fromController.text.trim();
                    final subject = _subjectController.text.trim();
                    final body = _bodyController.text.trim();
                    await draftController.updateDraft(widget.gmailMessage.id!,
                        to, from, cc, bcc, subject, body);
                    Get.back();
                    //     String to = toController.text.trim();
                    // String cc = ccController.text.trim();
                    // String bcc = bccController.text.trim();
                    // String from = fromController.text.trim();
                    // String subject = subjectController.text.trim();
                    // String body = bodyController.text.trim();

                    // await draftController.createDraftMessage(to, subject, body);
                    // if (to.isNotEmpty ||
                    //     cc.isNotEmpty ||
                    //     bcc.isNotEmpty ||
                    //     from.isNotEmpty ||
                    //     subject.isNotEmpty ||
                    //     body.isNotEmpty) {
                    //   await draftController.createDraftMessage(
                    //       to,cc, bcc, subject, body);}
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.attachment_outlined),
                    iconSize: 24,
                    color: AppColor.blackColor,
                    onPressed: () {
                      final snackBar = SnackBar(
                        content: const Text(
                          'This feature will be added soon !! ',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade600,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        margin: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 8.0),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    iconSize: 24,
                    color: AppColor.blackColor,
                    onPressed: _submit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    iconSize: 24,
                    color: AppColor.blackColor,
                    onPressed: () {
                      draftController.discardDraftMessage(
                          draftController.draftMessages.drafts![widget.i],
                          draftController.draftMessages.drafts![widget.i].id!);

                      Get.back();
                    },
                  ),
               
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 1, 16, 1),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
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
                        onFieldSubmitted: (value) {
                          toFocusNode.unfocus();
                          FocusScope.of(context).requestFocus(toFocusNode);
                        },
                      ),
                      isExpanded
                          ? Container(
                              child: Column(children: [
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
                                  onFieldSubmitted: (value) {
                                    ccFocusNode.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(ccFocusNode);
                                  },
                                ),
                                TextFormField(
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
                                  onFieldSubmitted: (value) {
                                    bccFocusNode.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(bccFocusNode);
                                  },
                                ),
                              ]),
                            )
                          : const SizedBox(),
                      const Divider(),
                      TextFormField(
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
                        onFieldSubmitted: (value) {
                          fromFocusNode.unfocus();
                          FocusScope.of(context).requestFocus(fromFocusNode);
                        },
                      ),
                      const Divider(),
                      TextFormField(
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
                        onFieldSubmitted: (value) {
                          subjectFocusNode.unfocus();
                          FocusScope.of(context).requestFocus(fromFocusNode);
                        },
                      ),
                      const SizedBox(),
                      Expanded(
                        child: Container(
                          height: 500.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.w),
                              color: AppColor.homeBackgroundColor),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 0),
                            child: TextFormField(
                              autofocus: true,
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
                EmailReply emailReply = await ComposeController().customReply(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${_bodyController.text}');
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
                EmailReply emailReply = await ComposeController().positive(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                    "Positive");
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
                EmailReply emailReply = await ComposeController().negative(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                    "Negative");
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
                EmailReply emailReply = await ComposeController().netural(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                    "Netural");
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
            ),
          ),
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
                  reloadigPositive = true;
                });
                EmailReply emailReply = await ComposeController().positive(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                    'Positive');
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
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
                      color: AppColor.homeIcon,
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
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  _bodyController.clear();
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
                  reloadigNegative = true;
                });
                EmailReply emailReply = await ComposeController().negative(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                    'Negative');
                _subjectController.text = emailReply.subject;
                _bodyController.text = emailReply.email;
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
                      color: AppColor.homeIcon,
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
                backgroundColor: AppColor.whiteColor,
              ),
              onPressed: () {
                setState(() {
                  currentState = 'all';
                  _bodyController.clear();
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
                EmailReply emailReply = await ComposeController().netural(
                    '',
                    '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                    "Netural");
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
                      color: AppColor.homeIcon,
                    )),
        ),
      ],
    );
  }

  Widget showButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: AppColor.whiteColor,
          ),
          onPressed: () async {
            setState(() {
              isSummariseLoading = true;
            });
            _bodyController.text = await ComposeController().summariseEmail('',
                '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}');
            await Future.delayed(const Duration(seconds: 1)).then((value) {
              setState(() {
                isSummariseLoading = false;
                isSummariseBackLoading = true;
              });
            });
          },
          child: isSummariseLoading == true
              ? Container(
                  width: 24.w,
                  height: 24.h,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Image.asset(
                      'assets/images/summarise.png',
                      fit: BoxFit.cover,
                      height: 20.h,
                      width: 20.w,
                      color: AppColor.composeButton,
                    ),
                    Text(
                      AppText.summarise,
                      style: TextStyle(color: AppColor.subtitleText),
                    ),
                  ],
                ),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: AppColor.whiteColor,
            ),
            onPressed: () {
              setState(() {
                currentState = 'ai';
              });
            },
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/aireply.svg',
                  fit: BoxFit.cover,
                  height: 20.h,
                  width: 20.w,
                  color: AppColor.composeButton,
                ),
                Text(
                  AppText.aiReply,
                  style: TextStyle(color: AppColor.subtitleText),
                ),
              ],
            )),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: AppColor.whiteColor,
            ),
            onPressed: () async {
              setState(() {
                isCustomLoading = true;
              });
              EmailReply emailReply = await ComposeController().customReply('',
                  '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${_bodyController.text}');
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
                : Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/customreply.svg',
                        fit: BoxFit.cover,
                        height: 20.h,
                        width: 20.w,
                        color: AppColor.composeButton,
                      ),
                      Text(
                        AppText.customAiReply,
                        style: TextStyle(color: AppColor.subtitleText),
                      ),
                    ],
                  )),
      ],
    );
  }

  Widget hideButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  isPressed = !isPressed;
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
                isPositiveLoading = true;
              });
              EmailReply emailReply = await ComposeController().positive(
                  '',
                  '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                  'Positive');
              print(emailReply.subject);
              _subjectController.text = emailReply.subject;
              _bodyController.text = emailReply.email;

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
                    style: TextStyle(color: AppColor.homeIcon),
                  ),
          ),
        ),
        SizedBox(width: 2.w),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: AppColor.whiteColor,
            ),
            onPressed: () async {
              setState(() {
                isNegativeLoading = true;
              });
              EmailReply emailReply = await ComposeController().negative(
                  '',
                  '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                  'Negative');
              _subjectController.text = emailReply.subject;
              _bodyController.text = emailReply.email;
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
                    style: TextStyle(color: AppColor.homeIcon),
                  ),
          ),
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
                isNeutralLoading = true;
              });
              EmailReply emailReply = await ComposeController().netural(
                  '',
                  '\n\nOn ${DateTime.now().toString()}, ${widget.senderEmail} wrote:\n${widget.originalMessage}',
                  'Neutral');
              _subjectController.text = emailReply.subject;
              _bodyController.text = emailReply.email;
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
                    style: TextStyle(color: AppColor.homeIcon),
                  ),
          ),
        ),
      ],
    );
  }
}
