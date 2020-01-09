import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(SampleApp());
}

class SampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Shared App Handler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleAppPage(),
    );
  }
}

class WebViewContainer extends StatefulWidget {
  @override
  createState() => _WebViewContainerState();

  WebViewContainer() {
    print("WebViewContainer");
  }
}

class _WebViewContainerState extends State<WebViewContainer> {
  _WebViewContainerState(){
    print("_WebViewContainerState");
  }
  static const platform = const MethodChannel('app.channel.shared.data');
  //String dataShared = "No data";
  WebViewController _controller;

  @override
  void initState() {
    super.initState();
    print("initState");
    getSharedText();
  }

  getSharedText() async {
    print("in getSharedText()");
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null && _controller != null) {
      print("sharedData");
      _controller.loadUrl(Uri.parse(sharedData).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
                child: WebView(
              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
            ))
          ],
        ));
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  static const platform = const MethodChannel('app.channel.shared.data');
  String dataShared = "No data";

  @override
  void initState() {
    super.initState();
    getSharedText();
    print("initState()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(dataShared)));
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }
}

