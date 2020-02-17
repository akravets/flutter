import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:f_logs/f_logs.dart';

void main() {
  runApp(SampleApp());
}

class SampleApp extends StatelessWidget {
	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
		title: 'Webfocus Reports',
		theme: ThemeData(
			primarySwatch: Colors.blue,
		),
		home: WebViewContainer(),
		);
	}
}

class WebViewContainer extends StatefulWidget {
	@override
	createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> with WidgetsBindingObserver {
	static const platform = const MethodChannel('com.iwaysoftware.webFocusMobile/report');
	String _fileName = "";
	FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

	
	@override
	void initState() {
		if(_fileName == ""){
			writeLog('@@@@@@@@@CHECK1', "INIT_STATE: fileName is null");
			super.initState();
			WidgetsBinding.instance.addObserver(this);

			writeLog("initState()", "Initializing...");
			getSharedText();
		}
	}

	@override
	void didChangeAppLifecycleState(AppLifecycleState state) {
		writeLog("didChangeAppLifecycleState()", "state: $state");
		if (state == AppLifecycleState.resumed) {
			writeLog("RESUMED!", "state: $state");
			getSharedText();
		}
  }

  getSharedText() async {
		writeLog("getSharedText()", "Entering method...");
		var data = await platform.invokeMethod("getReportFile");
		writeLog("getSharedText()", "Got data...");

		// controller returns data in the form of {fileName}###{payload}
		int indexOfSeparator = data.indexOf("###");

		if (indexOfSeparator < 0) {
			writeLog("getSharedText()", "No ### detected, wrong file. Returning...");
			return;
		}

		String fileName = data.substring(0, indexOfSeparator);
		String content = data.substring(indexOfSeparator + 3);

		
		setState(() {
			writeLog('@@@@@@@@@CHECK2', "SET_STATE: $fileName");
			if(_fileName != fileName){
				writeLog('@@@@@@@@@CHECK3', "SET_STATE: DIFFERENT FILENAME");
				_fileName = fileName;
				writeLog("getSharedText()", "Setting fileName in state: $fileName");
			}
		});
		

		final file = await _localFile(fileName);

		await writeData(file, content);

		writeData(file, content).then((f){
			writeLog("getSharedText()", "Reloading webView with file ${file.path}");
			flutterWebviewPlugin.reloadUrl('file://${file.path}');
		});
  }

  Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();
		writeLog("_localPath()", "Got localPath: $directory.path");
		return directory.path;
  }

  Future<File> _localFile(String filename) async {
		final path = await _localPath;
		return File('$path/$filename.html');
  }

  Future<File> writeData(File file, String content) async {
		writeLog("writeData()", "Writing file to device");
		return file.writeAsString(content);
  }

  @override
  Widget build(BuildContext context) {
		writeLog("build()", "Building UI...");
		FLog.exportLogs();
		/*
		return Scaffold(
			appBar: AppBar(title: Text("Test")),
			body: Text("TEST!!!"),
		);
		*/
		
		return WebviewScaffold(
			url: 'about:blank',
			withJavascript: true,
			appBar: AppBar(title: Text("$_fileName")));
  }

  writeLog(String methodName, String text){
		FLog.info(
		className: "WebFOCUS",
		methodName: methodName,
		text: text);
  }
}
