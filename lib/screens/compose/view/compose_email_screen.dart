
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simplemail/screens/compose/controller/compose_controller.dart';
import 'package:simplemail/screens/drawer_screen/view/draft/draft_controller.dart';
import 'package:simplemail/screens/home_screen/controller/home_controller.dart';
import 'package:simplemail/utils/colors.dart';
import 'package:simplemail/utils/config.dart';

class ComposeScreen extends StatefulWidget {
  ComposeScreen({super.key, required this.email});
  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
  String email;
}

class _ComposeScreenState extends State<ComposeScreen> {
  TextEditingController toController = TextEditingController();
  TextEditingController ccController = TextEditingController();
  TextEditingController bccController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController summaryController = TextEditingController();

  FocusNode toFocusNode = FocusNode();
  FocusNode ccFocusNode = FocusNode();
  FocusNode fromFocusNode = FocusNode();
  FocusNode bccFocusNode = FocusNode();
  FocusNode subjectFocusNode = FocusNode();
  FocusNode bodyFocusNode = FocusNode();

  bool isPressed = false;
  bool _showTextIcons = false;
  bool _isBold = false;
  bool _showIcons = false;
  bool _isLoading = false;
  String bodyValue = '';
  bool isExpanded = false;

  ComposeController composeController = ComposeController();
  DraftController draftController = Get.put(DraftController());

  Future<void> _submit() async {
    final to = toController.text.trim();
    final cc = ccController.text.trim();
    final bcc = bccController.text.trim();
    final from = widget.email;
    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();

    await Get.put(HomeController())
        .sendGmailMessage(to, from, cc, bcc, subject, body);
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

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  String? validateEmailDate(String? value, ComposeController controller) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    value!.isNotEmpty && !regex.hasMatch(value)
        ? controller.showSendFuc(false)
        : controller.showSendFuc(true);
    return null;
  }

  int _currentIndex = 0;
  final tabs = [
    Center(child: Text('Home')),
    Center(child: Text('Search')),
    Center(child: Text('Profile')),
  ];

  void onTabTapped(int index) {
    // Call your function here. For example:
    if (index == 0) {
      homeFunction();
    } else if (index == 1) {
      searchFunction();
    } else if (index == 2) {
      profileFunction();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void homeFunction() {
    print("Home function called");
  }

  void searchFunction() {
    print("Search function called");
  }

  void profileFunction() {
    print("Profile function called");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComposeController>(
        init: ComposeController(),
        builder: (composeController) {
          return Scaffold(
            backgroundColor: Color(0xFFF2F3FF),
            appBar: AppBar(
              elevation: 0,
              centerTitle: false,
              backgroundColor: Color(0xFFF2F3FF),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 24,
                color: AppColor.blackColor,
                onPressed: () async {
                  Get.back();
                  String to = toController.text.trim();
                  String cc = ccController.text.trim();
                  String bcc = bccController.text.trim();
                  String from = fromController.text.trim();
                  String subject = subjectController.text.trim();
                  String body = bodyController.text.trim();

                  if (to.isNotEmpty ||
                      cc.isNotEmpty ||
                      bcc.isNotEmpty ||
                      from.isNotEmpty ||
                      subject.isNotEmpty ||
                      body.isNotEmpty) {
                    await draftController.createDraftMessage(
                        to, cc, bcc, subject, body);
                  }
                },
              ),

              title: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "New Mail",
                      style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        color: Color(0xFF7A85DE),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 16, 2),
                  child: AnimatedOpacity(
                      opacity: composeController.showSend ? 1 : 0.3,
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: composeController.showSend ? _submit : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A85DE),
                          primary: Theme.of(context).primaryColor,
                          shape: StadiumBorder()
                            ),
                        child: Row(
                          children: [
                            Text(
                              "Send",
                              style: TextStyle(
                                color: AppColor.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.send,
                              color: AppColor.whiteColor,
                              size: 16,
                            ),
                          ],
                        ),
                      )

                    ),
                ),
             
              ],
             
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: TextFormField(
                      autofocus: true,
                      controller: toController,
                      focusNode: toFocusNode,
                      onChanged: (s) {
                        validateEmailDate(s, composeController);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Text(
                          AppText.to,
                          style:
                              TextStyle(color: AppColor.grey, fontSize: 16.sp),
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
                            vertical: 15.h, horizontal: 10.w),
                        prefixIconConstraints: const BoxConstraints(),
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        toFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(toFocusNode);
                      },
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      autovalidateMode: AutovalidateMode.always,
                      validator: validateEmail,
                    ),
                  ),
                  isExpanded
                      ? Column(children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                            child: TextFormField(
                              autofocus: true,
                              controller: ccController,
                              focusNode: ccFocusNode,
                              decoration: InputDecoration(
                                prefixIcon: Text(
                                  AppText.cc,
                                  style: TextStyle(
                                      color: AppColor.grey, fontSize: 16.sp),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.h, horizontal: 10.w),
                                prefixIconConstraints: const BoxConstraints(),
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                ccFocusNode.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(ccFocusNode);
                              },
                              onEditingComplete: () =>
                                  FocusScope.of(context).nextFocus(),
                              autovalidateMode: AutovalidateMode.always,
                              validator: validateEmail,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                            child: TextFormField(
                              autofocus: true,
                              controller: bccController,
                              focusNode: bccFocusNode,
                              decoration: InputDecoration(
                                prefixIcon: Text(
                                  AppText.bcc,
                                  style: TextStyle(
                                      color: AppColor.grey, fontSize: 16.sp),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.w, horizontal: 10.h),
                                prefixIconConstraints: const BoxConstraints(),
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                bccFocusNode.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(bccFocusNode);
                              },
                              onEditingComplete: () =>
                                  FocusScope.of(context).nextFocus(),
                              autovalidateMode: AutovalidateMode.always,
                              validator: validateEmail,
                            ),
                          ),
                        ])
                      : const SizedBox(),
                  const Divider(),
   

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: TextFormField(
                      controller: subjectController,
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
                        FocusScope.of(context).requestFocus(bodyFocusNode);
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 550.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: AppColor.whiteColor),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(2.w, 1.h, 1.w, 2.h),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: bodyController,
                            focusNode: bodyFocusNode,
                            style: TextStyle(
                              fontWeight:
                                  _isBold ? FontWeight.bold : FontWeight.normal,
                            ),
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
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
              bottomNavigationBar: Container(
              height: 120,
              color: Color(0xFFF2F3FF),
              child: isPressed == false
                  ? showButton(composeController, () async {
                      setState(() {
                        _isLoading = true;
                      });
                      bodyValue = bodyController.text;

                      String text = await composeController.composeMail(
                          subjectController.text, bodyController.text);

                      List<String> emailLines = text.split("\n");

                      String subject = '';
                      String emailContent = "";
                      for (String line in emailLines) {
                        if (line.startsWith("Subject:")) {
                          subject = line.substring(8);
                          subjectController.text = subject;
                        } else {
                          emailContent += "$line\n";
                        }
                      }
                      bodyController.text = emailContent;
                      setState(() {});

                      setState(() {
                        _isLoading = false;

                        isPressed = !isPressed;
                      });
                    })
                  : hideButton(() {
                      setState(() {
                        bodyController.clear();
                        bodyController.text = bodyValue;
                        subjectController.clear();
                        isPressed = !isPressed;
                      });
                    }, () async {
                      setState(() {
                        _isLoading = true;
                      });
                      String text = await composeController.composeMail(
                          subjectController.text, bodyController.text);

                      List<String> emailLines = text.split("\n");

                      String subject = '';
                      String emailContent = "";
                      for (String line in emailLines) {
                        if (line.startsWith("Subject:")) {
                          subject = line.substring(8);
                          subjectController.text = subject;
                        } else {
                          emailContent += "$line\n";
                        }
                      }
                      bodyController.text = emailContent;

                      setState(() {
                        _isLoading = false;
                      });
                    }),
            ),
          );
        });
  }

  Widget showButton( ComposeController composeController, void Function()? onPressed) {
return Expanded(
      child: Row(
       children: <Widget>[
          _isLoading == false
              ? Row(
                  children: [
                    if (_showTextIcons)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        color: Color(0xFF7A85DE),
                        onPressed: () {
                          setState(() {
                            _showTextIcons = !_showTextIcons;
                          });
                        },
                      ),
                    if (!_showTextIcons) ...[
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        color:
                            _currentIndex == 0 ? Colors.grey : Color(0xFF7A85DE),
                        onPressed: () => setState(() => _currentIndex = 0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color:
                            _currentIndex == 1 ? Colors.grey : Color(0xFF7A85DE),
                        onPressed: () => setState(() => _currentIndex = 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_fields),
                        color:
                            _currentIndex == 2 ? Colors.grey : Color(0xFF7A85DE),
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2;
                            _showTextIcons = !_showTextIcons;
                          });
                        },
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.format_bold),
                        color: Color(0xFF7A85DE),
                        onPressed: () {
                          setState(() {
                            _isBold = !_isBold;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_italic),
                        color: Color(0xFF7A85DE),
                        onPressed: () {
     
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_underlined),
                        color: Color(0xFF7A85DE),
                        onPressed: () {
      
                        },
                      ),
                    ],
                  ],
                )
              : IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert),
                ),
    
      
          const SizedBox(
            width: 60,
          ),
          if (!_showTextIcons) ...[
            _isLoading == true
                ? Container(
                    width: 24.w,
                    height: 24.h,
                    padding: EdgeInsets.all(2.w),
                    child: const CircularProgressIndicator(
                      color: Color(0xFF7A85DE),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF7A85DE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(Icons.edit),
                    label: Text('Compose with AI'),
                  ),
          ],
        ],
      ),
    );
  }

  Widget hideButton( void Function()? onPressed, void Function()? onRegenratePressed) {
    return Row(
   
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _showIcons = !_showIcons;
            });
          },
          color: Color(0xFF7A85DE),
          icon: _showIcons ? Icon(Icons.arrow_back) : Icon(Icons.more_vert),
        ),
        SizedBox(
          width: 60.w,
        ),
        _showIcons
            ? Row(
                children: [
                  Container(
                    height: 40,
                    child: const VerticalDivider(
                      color: Color(0xFF7A85DE),
                      thickness: .5,
                      width: 5,
                    ),
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    color: _currentIndex == 0 ? Colors.grey : Color(0xFF7A85DE),
                    onPressed: () => setState(() => _currentIndex = 0),
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: _currentIndex == 1 ? Colors.grey : Color(0xFF7A85DE),
                    onPressed: () => setState(() => _currentIndex = 1),
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_fields),
                    color: _currentIndex == 2 ? Colors.grey : Color(0xFF7A85DE),
                    onPressed: () {
                      _currentIndex = 2;
                    },
                  ),
                ],
              )
            : Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: const Color(0xFF7A85DE),
                    ),
                    onPressed: onPressed,
                    icon: Icon(
                      Icons.undo,
                      color: AppColor.whiteColor,
                    ),
                    label: Text(
                      'previous',
                      style: TextStyle(
                          color: AppColor.whiteColor, fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  _isLoading == true
                      ? Container(
                          width: 24.w,
                          height: 24.h,
                          padding: EdgeInsets.all(2.w),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF7A85DE),
                          ),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: const Color(0xFF7A85DE)),
                          onPressed: onRegenratePressed,
                          icon: Icon(
                            Icons.autorenew,
                            color: AppColor.whiteColor,
                          ),
                          label: Text(
                            'Re-genrate',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                ],
              )
      ],
    );
  }
}
