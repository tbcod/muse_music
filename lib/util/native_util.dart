import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:music_muse/util/log.dart';

class NativeUtils {
  NativeUtils._() : super();
  static final NativeUtils _instance = NativeUtils._();
  static NativeUtils get instance {
    return _instance;
  }

  static const channel = MethodChannel('player.musicmuse.nativemethod');

  initFacebook() async {
    // return;

    var jsonStr = FirebaseRemoteConfig.instance.getString("musicmuse_fabo_id");
    // AppLog.e("云控fb");
    if (jsonStr.isEmpty) {
      // AppLog.e("云控fb为空");
      return;
    }

    var jsonMap = jsonDecode(jsonStr);
    String fbid = jsonMap["id"] ?? "";
    String fbtoken = jsonMap["token"] ?? "";

    if (fbid.isEmpty || fbtoken.isEmpty) {
      AppLog.e("云控格式问题：$jsonMap");
      return;
    }

    var result = await channel
        .invokeMethod("initFacebook", {"fbid": fbid, "fbtoken": fbtoken});
    AppLog.e("原生返回的：$result");
  }
}
