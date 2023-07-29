library social_embed_webview;

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:simplemail/screens/home_screen/widgets/social-media-generic.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

class _HtmlBodyProperty {
  final double height;
  final double width;
  final double top;
  final double left;
  const _HtmlBodyProperty(this.height, this.width, this.top, this.left);
  factory _HtmlBodyProperty.fromJson(Map<String, dynamic> json) {
    return _HtmlBodyProperty(
        double.tryParse(json['height'].toString()) ?? 0,
        double.tryParse(json['width'].toString()) ?? 0,
        double.tryParse(json['top'].toString()) ?? 0,
        double.tryParse(json['left'].toString()) ?? 0);
  }
}

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
  late _HtmlBodyProperty _htmlContentProperty;
  late final webview.WebViewController wbController;
  InAppWebViewController? inappWebViewController;
  late String htmlBody;
  bool _isAlreadyReloaded = false;

  @override
  void initState() {
    super.initState();
    // htmlBody = ;
    if (widget.socialMediaObj.supportMediaControll) {
      WidgetsBinding.instance.addObserver(this);
    }
    _htmlContentProperty = const _HtmlBodyProperty(0, 0, 0, 0);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _htmlContentProperty = _HtmlBodyProperty(
    //       MediaQuery.of(context).size.height,
    //       MediaQuery.of(context).size.width,
    //       0,
    //       0);
    //   setState(() {});
    // });
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
    if (widget.socialMediaObj.supportMediaControll) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;
    final html = parser.parse(widget.socialMediaObj.htmlBody);
    final header = html.querySelector('head')?.innerHtml ?? '';
    final body = html.querySelector('body')?.innerHtml ?? '';
    // final azerty =
    //     parser.parse(getHtmlBody2(width, _htmlContentProperty, header, body));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: _htmlContentProperty.height == 0
          ? height
          : _htmlContentProperty.height,
      width: width,
      child: InAppWebView(
        initialData: InAppWebViewInitialData(
            data: getHtmlBody2(width, _htmlContentProperty, header, body)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            supportZoom: false,
            javaScriptEnabled: true,
            disableVerticalScroll: false,
          ),
        ),
        onCreateWindow: _createWindow,
        onConsoleMessage: (controller, consoleMessage) =>
            _onMessageConsole(height, controller, consoleMessage),
      ),
    );

    // final wv = webview.WebView(
    //     initialUrl: htmlToURI(getHtmlBody2(width * .45)),
    //     javascriptChannels: <webview.JavascriptChannel>{
    //       _getHeightJavascriptChannel()
    //     },
    //     javascriptMode: webview.JavascriptMode.unrestricted,
    //     initialMediaPlaybackPolicy:
    //         webview.AutoMediaPlaybackPolicy.always_allow,
    //     onWebViewCreated: (wbc) {
    //       wbController = wbc;
    //     },
    //     onPageFinished: (str) {
    //       final color = colorToHtmlRGBA(getBackgroundColor(context));
    //       wbController.evaluateJavascript(
    //           'document.body.style= "background-color: $color"');
    //       if (widget.socialMediaObj.aspectRatio == null)
    //         wbController
    //             .evaluateJavascript('setTimeout(() => sendHeight(), 0)');
    //     },
    //     navigationDelegate: (navigation) async {
    //       final url = navigation.url;
    //       if (navigation.isForMainFrame && await canLaunch(url)) {
    //         launch(url);
    //         return webview.NavigationDecision.prevent;
    //       }
    //       return webview.NavigationDecision.navigate;
    //     });
    // final ar = widget.socialMediaObj.aspectRatio;
    // return (ar != null)
    //     ? ConstrainedBox(
    //         constraints: BoxConstraints(
    //           maxHeight: MediaQuery.of(context).size.height / 1.5,
    //           maxWidth: 300,
    //         ),
    //         child: AspectRatio(aspectRatio: ar, child: wv),
    //       )
    //     : SizedBox(height: _height, width: double.infinity, child: wv);
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
      double height, InAppWebViewController controller, consoleMessage) async {
    final screenSize = MediaQuery.of(context).size;
    _injectCss(consoleMessage, screenSize, controller);
  }

  void _injectCss(consoleMessage, Size screenSize,
      InAppWebViewController controller) async {
    if (!_isAlreadyReloaded) {
      _htmlContentProperty =
          _HtmlBodyProperty.fromJson(json.decode(consoleMessage.message));
      _isAlreadyReloaded = true;
      double scaleFactor = 1;
      if (_htmlContentProperty.width > 0) {
        scaleFactor = (screenSize.width *
            .9 /
            (_htmlContentProperty.width == 0
                ? 0.1
                : _htmlContentProperty.width));
      }

      final sizeDifference =
          (_htmlContentProperty.width - screenSize.width * .9).roundToDouble();

      final topOffset = -_htmlContentProperty.top;
      setState(() {});
      controller.injectCSSCode(source: """
    body {
      transform: scale($scaleFactor);
    }

     body>div {
  position: fixed;
  top: ${topOffset}px !important;
  left:${sizeDifference != 0 ? '-${(sizeDifference / 2)}px' : '0'};
  right:${sizeDifference != 0 ? '${(sizeDifference / 2)}px' : '0'};
    """);
    } else {
      log(consoleMessage.message);
      final data = await controller.getHtml();
      // log(data ?? "");
    }
  }

  void _setHeight(double height) {
    setState(() {
      // _height = height + widget.socialMediaObj.bottomMargin;
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

  String getHtmlBody2(
    double customWidth,
    _HtmlBodyProperty htmlProperty,
    String header,
    String body,
  ) {
    return """
      <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  $header
  <style>
  body {
  padding: 0 !important;
  margin:0 !important;
  box-sizing: border-box !important;
  width: 100vw !important;
  }

 body>div {
  padding:0  !important;
  margin:0 auto !important;
  height: 100vh !important;
  max-width:90% !important;
  }
  </style>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">
</head>
<body>
    $body
   <script>
          const body=document.querySelector("body");
          const div=document.querySelector("body> div");
          const table=document.querySelector("table");
          const mainContent=table!=null?table:div!=null?div:null;

          function getOffset(el) {
  const rect = el.getBoundingClientRect();
  return {
    left: rect.left + window.scrollX,
    top: rect.top + window.scrollY
  };
}
        function outPutContainerSize() {
          const rect = mainContent.getBoundingClientRect();
          console.log(JSON.stringify(
            {
              height:body.scrollHeight,
              width:mainContent.scrollWidth,
              top:rect.top,
              left:rect.left
              }));
        }
        new ResizeObserver(outPutContainerSize).observe(div!=null?div:table!=null?table:null)
        outPutContainerSize()
    </script>
</body>
</html>

    """;
  }

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
