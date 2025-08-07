import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'native_util.dart';

const String mmAdJson = "mmAdJson";
const String mmFullClickbait = "mmFullClickbait";

class RemoteUtil {
  static RemoteUtil shareInstance = RemoteUtil._();

  RemoteUtil._();

  Map<String, dynamic> _adJson = {};

  String _bannerClickbait = "";

  late SharedPreferences isp;

  init() async {
    isp = await SharedPreferences.getInstance();

    _adJson = MuseConfig.adJsonIos;

    _bannerClickbait = isp.getString(mmFullClickbait) ?? "";
  }

  Future<void> initFirebaseRemoteSdk() async {
    var tempTime = DateTime.now();
    //获取云控字段
    try {
      await FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(fetchTimeout: const Duration(seconds: 15), minimumFetchInterval: const Duration(seconds: 30)),
      );
      await FirebaseRemoteConfig.instance.fetchAndActivate();
      FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
        var tempTime = DateTime.now();

        var isOk = await FirebaseRemoteConfig.instance.activate();

        if (isOk) {
          var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
          EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});
        }

        // Use the new config values here.
        var jsonString1 = FirebaseRemoteConfig.instance.getString(
          GetPlatform.isIOS ? "ad_json_ios" : "ad_json_and",
        );
        Map oldMap1 = jsonDecode(jsonString1);
        AppLog.i(oldMap1);
        //map key转为小写
        _adJson = oldMap1.map((key, value) => MapEntry(key.toLowerCase(), value));
      });

      //初始化facebook
      NativeUtils.instance.initFacebook();

      var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
      EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});

      //使用json
      var jsonString = FirebaseRemoteConfig.instance.getString(GetPlatform.isIOS ? "ad_json_ios" : "ad_json_and");
      AppLog.i("获取云控广告");
      AppLog.i(jsonString);

      if (jsonString.isNotEmpty) {
        Map oldMap = jsonDecode(jsonString);
        //map key转为小写
        _adJson = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
      }

      String bannerClickbait = FirebaseRemoteConfig.instance.getString("NVfull_Clickbait");
      if (bannerClickbait.isNotEmpty) {
        isp.setString(mmFullClickbait, bannerClickbait);
        _bannerClickbait = bannerClickbait;
      }
    } catch (e) {
      AppLog.e(e);
    }
  }

  Map<String, dynamic> get adJson {
    if (kDebugMode) return MuseConfig.adJsonIos;
    return _adJson;
  }

  //参数值：0、10、20、30……100 参数值=10：有10%的概率跳转
  int get adNativeScreenClick {
    if (_bannerClickbait.isEmpty) return 0;
    final Map<String, dynamic> config = jsonDecode(_bannerClickbait);
    return config["ScreenClick"] ?? 0;
  }

  //0、1、2、3……10  参数值=0，广告左上角直接展示正常关闭按钮
  int get adNativeCountDown {
    if (_bannerClickbait.isEmpty) return 0;
    final Map<String, dynamic> config = jsonDecode(_bannerClickbait);
    return config["Countdown"] ?? 0;
  }
}
