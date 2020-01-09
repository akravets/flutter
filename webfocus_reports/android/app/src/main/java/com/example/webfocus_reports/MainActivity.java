package com.example.webfocus_reports;

import android.content.Intent;
import android.os.Bundle;

import java.nio.ByteBuffer;

import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.ActivityLifecycleListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private String sharedText;

  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();

    //handleSendText(String.valueOf(intent.getData()));

    sharedText = String.valueOf(intent.getData());

    /*
    if (Intent.ACTION_SEND.equals(action) && type != null) {
      if ("text/plain".equals(type)) {
        handleSendText(intent.getData()); // Handle text being sent
        console.log()
      }
    }
    */

    new MethodChannel(getFlutterView(), "app.channel.shared.data").setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.contentEquals("getSharedText")) {
          result.success(sharedText);
          sharedText = null;
        }
      }
    });
  }

  void handleSendText(Intent intent) {
    sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
  }
}