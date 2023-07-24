library social_embed_webview;

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:simplemail/screens/home_screen/widgets/social-media-generic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

class SocialEmbed extends StatefulWidget {
  final SocialMediaGenericEmbedData socialMediaObj;
  final Color? backgroundColor;
  const SocialEmbed(
      {Key? key, required this.socialMediaObj, this.backgroundColor})
      : super(key: key);

  @override
  _SocialEmbedState createState() => _SocialEmbedState();
}

class _SocialEmbedState extends State<SocialEmbed> with WidgetsBindingObserver {
  double _height = 300;
  late final webview.WebViewController wbController;
  InAppWebViewController? inappWebViewController;
  late String htmlBody;

  @override
  void initState() {
    super.initState();
    // htmlBody = ;
    if (widget.socialMediaObj.supportMediaControll) {
      WidgetsBinding.instance.addObserver(this);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _height = MediaQuery.of(context).size.height;
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        wbController.evaluateJavascript(widget.socialMediaObj.stopVideoScript);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        wbController.evaluateJavascript(widget.socialMediaObj.pauseVideoScript);
        break;
    }
  }

  @override
  void dispose() {
    if (widget.socialMediaObj.supportMediaControll)
      WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;
    log(widget.socialMediaObj.htmlBody);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: _height * .9,
      width: width,
      child: InAppWebView(
        initialData: InAppWebViewInitialData(data: getHtmlBody2(width * .45)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            supportZoom: false,
            javaScriptEnabled: true,
            disableVerticalScroll: true,
          ),
        ),
        onCreateWindow: _createWindow,
        onConsoleMessage: (controller, consoleMessage) =>
            _onMessageConsole(height, controller, consoleMessage),
      ),
    );

    final wv = webview.WebView(
        initialUrl: htmlToURI(getHtmlBody()),
        // initialUrl: htmlToURI(getHtmlBody()),
        javascriptChannels:
            <webview.JavascriptChannel>[_getHeightJavascriptChannel()].toSet(),
        javascriptMode: webview.JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy:
            webview.AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: (wbc) {
          wbController = wbc;
        },
        onPageFinished: (str) {
          final color = colorToHtmlRGBA(getBackgroundColor(context));
          wbController.evaluateJavascript(
              'document.body.style= "background-color: $color"');
          if (widget.socialMediaObj.aspectRatio == null)
            wbController
                .evaluateJavascript('setTimeout(() => sendHeight(), 0)');
        },
        navigationDelegate: (navigation) async {
          final url = navigation.url;
          if (navigation.isForMainFrame && await canLaunch(url)) {
            launch(url);
            return webview.NavigationDecision.prevent;
          }
          return webview.NavigationDecision.navigate;
        });
    final ar = widget.socialMediaObj.aspectRatio;
    return (ar != null)
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 1.5,
              maxWidth: 300,
            ),
            child: AspectRatio(aspectRatio: ar, child: wv),
          )
        : SizedBox(height: _height, width: double.infinity, child: wv);
  }

  Future<bool?> _createWindow(controller, createWindowAction) async {
    inappWebViewController ??= controller;
    return true;
  }

  webview.JavascriptChannel _getHeightJavascriptChannel() {
    return webview.JavascriptChannel(
        name: 'PageHeight',
        onMessageReceived: (webview.JavascriptMessage message) {
          _setHeight(double.parse(message.message));
        });
  }

  void _onMessageConsole(
      double height, InAppWebViewController controller, consoleMessage) {
    _height = double.tryParse(consoleMessage.message) ?? height;
    setState(() {});
  }

  void _setHeight(double height) {
    setState(() {
      _height = height + widget.socialMediaObj.bottomMargin;
    });
  }

  Color getBackgroundColor(BuildContext context) {
    return widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  }

  String getHtmlBody() => """
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            *{box-sizing: border-box;margin:0px; padding:0px;}
            #widget {
      width:100vw;
      height:100vh;
      box-sizing:border-box;
      transform: scale(0.7);
    }
          </style>
          
        </head>
        <body>
          <div id="widget">${widget.socialMediaObj.htmlBody}</div>
          ${(widget.socialMediaObj.aspectRatio == null) ? dynamicHeightScriptSetup : ''}
          ${(widget.socialMediaObj.canChangeSize) ? dynamicHeightScriptCheck : ''}
        </body>
        <script>
          const divWidget=document.getElementById("widget");
        function outPutContainerSize() {
          console.log(divWidget.offsetHeight);
        }
        new ResizeObserver(outPutContainerSize).observe(divWidget)
        outPutContainerSize()
    </script>
      </html>
    """;

  String getHtmlBody2(double customWidth) => """
      <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your Email Title</title>
  <style>
    #email {
      padding:0 !important;
      margin:0 !important;
      /*width:${customWidth}px !important;*/
      height: 0vh !important;
      transform: scale(0.8);
    }
  </style>
</head>
<body>
   <div id="email">
   ${widget.socialMediaObj.htmlBody}
   </div>
   <script>
          const divWidget=document.getElementById("email");
        function outPutContainerSize() {
          console.log(divWidget.scrollHeight);
        }
        new ResizeObserver(outPutContainerSize).observe(divWidget)
        outPutContainerSize()
    </script>
</body>
</html>

    """;

  static const String dynamicHeightScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
      const sendHeight = () => PageHeight.postMessage(widget.clientHeight);
    </script>
  """;

  static const String dynamicHeightScriptCheck = """
    <script type="text/javascript">
      const onWidgetResize = (widgets) => sendHeight();
      const resize_ob = new ResizeObserver(onWidgetResize);
      resize_ob.observe(widget);
    </script>
  """;
}

String htmlToURI(String code) {
  return Uri.dataFromString(code,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
      .toString();
}

String colorToHtmlRGBA(Color c) {
  return 'rgba(${c.red},${c.green},${c.blue},${c.alpha / 255})';
}
