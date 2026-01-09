import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/util/log.dart';

class NativeUtils {
  NativeUtils._() : super();
  static final NativeUtils _instance = NativeUtils._();

  static NativeUtils get instance {
    return _instance;
  }

  static const channel = MethodChannel('player.musicmuse.nativemethod');


  void init(BuildContext context) {
    channel.setMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'idfa':
          AppLog.i(methodCall.arguments);
          break;
        default:
          break;
      }
    });
  }


  /// 进入A面时就调用（只调用一次）
  Future<void> gbToAPage() async {
    channel.invokeMethod('gbToAPage');
  }

  /// 进入B面时就调用（只调用一次）
  Future<void> gbToBPage() async {
    channel.invokeMethod('gbToBPage');
  }

  /// 进入B面时就调用（只调用一次)
  Future<void> gbToBPage2() async {
    channel.invokeMethod('gbToBPage2');
  }

  /// 点击项目右上角或其他地方打开web游戏调用（每次点击按钮调用）
  Future<void> gbToH5Page() async {
    channel.invokeMethod('gbToH5Page');
  }

  Future<void> gbToIDFA(String idfa) async {
    channel.invokeMethod('gbToIDFA', {"val": idfa});
  }

  Future<void> gbToDistinctId(String distinctId) async {
    channel.invokeMethod('gbToDistinctId', {"val": distinctId});
  }

  test() async {
    var result = await channel.invokeMethod("testTT");
  }

  initFacebook() async {
    // return;

    var jsonMap = {};
    try {
      var jsonStr = FirebaseRemoteConfig.instance.getString("muse_fb_id");
      if (jsonStr.isEmpty) {
        jsonStr = FirebaseRemoteConfig.instance.getString("musicmuse_fabo_id");
      }
      if (jsonStr.isNotEmpty) {
        jsonMap = jsonDecode(jsonStr);
      }
    } catch (e) {
      AppLog.e(e.toString());
    }

    String fbId = jsonMap["id"] ?? "";
    String fbToken = jsonMap["token"] ?? "";

    if (fbId.isEmpty || fbToken.isEmpty) {
      fbId = MuseConfig.fbIdDef;
      fbToken = MuseConfig.fbTokenDef;
    }

    var result = await channel.invokeMethod("initFacebook", {"fbid": fbId, "fbtoken": fbToken});
    AppLog.i("原生返回的：$result, fb id:$fbId,fb token:$fbToken");
  }
}
