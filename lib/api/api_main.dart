import 'dart:convert';
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_muse/api/base_api.dart';
import 'package:music_muse/app.dart';
import 'package:music_muse/lang/my_tr.dart';
import 'package:music_muse/u_page/main/home/u_play.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:music_muse/util/toast.dart';
export 'base_api.dart';

class ApiMain extends BaseApi {
  ApiMain._internal() : super("");
  static final ApiMain _instance = ApiMain._internal();

  Map<String, dynamic> playbackMap = {};

  static ApiMain get instance {
    return _instance;
  }

  Map<String, dynamic> playJsonData = {
    "context": {
      "client": {"clientName": "ANDROID", "clientVersion": "19.11.43", "platform": "MOBILE"}
    },
    "params": "8AEB",
    "contentCheckOk": true,
    "racyCheckOk": true
  };

  ///格式String ：1,2
  String blackVideoIds = "";

  initFirebaseData() {
    try {
      var jsonStr = FirebaseRemoteConfig.instance.getString("musicmuse_play");
      var data = jsonDecode(jsonStr);
      playJsonData = data;

      //获取无版权的id
      blackVideoIds = FirebaseRemoteConfig.instance.getString("musicmuse_song_block");
    } catch (e) {
      print(e);
    }
  }

  Future<BaseModel> getData(String browseId, {String? params, Map? nextData, String? videoId}) async {
    // String countryCode = Get.deviceLocale?.countryCode ?? "";
    // String languageCode = Get.deviceLocale?.languageCode ?? "";
    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": _webRemixContext,
      "browseId": browseId,
    };

    if (params != null) {
      body["params"] = params;
    }
    if (videoId != null) {
      body["videoId"] = videoId;
    }

    var url = "https://music.youtube.com/youtubei/v1/browse?prettyPrint=false";

    if (nextData != null) {
      var continuation = nextData["continuation"] ?? "";
      var itct = nextData["clickTrackingParams"] ?? "";
      url += "&continuation=$continuation&type=next&itct=$itct";
    }

    AppLog.i("请求首页数据: ${(httpClient.baseUrl ?? "") + url}, header: $_header , param：$body");

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    if (result.code == HttpCode.success) {
      //请求成功
      EventUtils.instance.addEvent("source_get");
    }

    return result;
  }

  Future<BaseModel> getVideoInfo(String videoId, {bool toastBlack = true}) async {
    var url = "https://music.youtube.com/youtubei/v1/player";
    // var url = "https://www.youtube.com/youtubei/v1/player";

    initFirebaseData();

    if (blackVideoIds.split(";").contains(videoId)) {
      //在黑名单内，不允许下载、播放、缓存等
      if (toastBlack) {
        ToastUtil.showToast(msg: "playCopyrightStr".tr);
      }
      return BaseModel(code: -1, message: "playCopyrightStr".tr);
    }

    // Map<String, dynamic> body = {
    //   "context": {
    //     "client": {
    //       'clientName': 'ANDROID_VR',
    //       'clientVersion': '1.56.21',
    //     }
    //   },
    //   "videoId": videoId,
    // };

    Map<String, dynamic> body = Map.of(playJsonData);
    body["videoId"] = videoId;

    BaseModel result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);

    //判断是否有链接
    String videoUrl = result.data?["streamingData"]?["formats"]?.first?["url"] ?? "";
    if ((result.code != HttpCode.success) || videoUrl.isEmpty) {
      return getVideoInfoYoutube(videoId);
    }
    return result;
  }

  Future<BaseModel> getVideoInfoYoutube(String videoId) {
    var url = "https://www.youtube.com/youtubei/v1/player";

    Map<String, dynamic> body = Map.of(playJsonData);
    body["videoId"] = videoId;
    // Map<String, dynamic> body = {
    //   "context": {
    //     "client": {
    //       'clientName': 'ANDROID_VR',
    //       'clientVersion': '1.56.21',
    //     }
    //   },
    //   "videoId": videoId
    // };

    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getSearchList(String input) {
    var url = "https://music.youtube.com/youtubei/v1/music/get_search_suggestions";
    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {"context": _webRemixContext, "input": input};
    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getSearchResult(String input, {String params = "", Map? nextData}) {
    var url = "https://music.youtube.com/youtubei/v1/search";
    if (nextData != null) {
      url += "?continuation=${nextData["continuation"]}";
    }
    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {"context": _webRemixContext, "query": input, "params": params};
    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getVideoNext(String videoId, {bool isMoreVideo = false, String continuation = ""}) {
    var url = "https://music.youtube.com/youtubei/v1/next";

    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": _webRemixContext,
      "continuation": continuation,
      "videoId": videoId,
    };
    if (isMoreVideo) {
      body.remove("videoId");
      body["playlistId"] = "RDAMVM$videoId";
    }

    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getYoutubeData(String browseId, {String? params, Map? nextData, String? videoId}) async {
    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": _hl,
          "gl": _gl,
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        }
      },
      "browseId": browseId,
      "params": params,
      "videoId": videoId
    };

    var url = "https://www.youtube.com/youtubei/v1/browse";

    if (nextData != null) {
      body["continuation"] = nextData["continuation"] ?? "";
      body["clickTracking"] = {"clickTrackingParams": nextData["clickTrackingParams"] ?? ""};
    }

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    if (result.code == HttpCode.success) {
      //请求成功
      EventUtils.instance.addEvent("source_get");
    }

    return result;
  }

  Future<BaseModel> getYoutubeNext(String videoId, {String continuation = ""}) async {
    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": _hl,
          "gl": _gl,
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        }
      },
      "videoId": videoId,
      "continuation": continuation
    };

    // body.remove(continuation.isEmpty?"continuation":"videoId");

    var url = "https://www.youtube.com/youtubei/v1/next";

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    return result;
  }

  Future<BaseModel> youtubeSearch(String word, {String? continuation}) async {
    var nowTime = DateTime.now();
    String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": _hl,
          "gl": _gl,
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        }
      },
      "query": word,
      "continuation": continuation
    };

    if (continuation == null || continuation.isEmpty) {
      body.remove("continuation");
    }

    var url = "https://www.youtube.com/youtubei/v1/search";

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    return result;
  }

  Future<void> postYoutubePlaybackInfo({required bool isWatchOnly}) async {
    UserPlayInfoController controller = Get.find<UserPlayInfoController>();
    if (controller.player == null) return;
    final videoId = controller.nowData["videoId"];
    if (videoId == null) return;
    final cnp = _generateRandomId;
    final playlistId = controller.playlistId;
    if (playbackMap[videoId] == null) {
      Map<String, dynamic> body = {
        "context": _webRemixContext,
        "videoId": videoId,
        "cpn": cnp,
        "playbackContext": {
          "contentPlaybackContext": {
            "html5Preference": "HTML5_PREF_WANTS",
            "referer": "https://music.youtube.com/",
            "vis": 1,
            "autoplay": true,
            "autonav": true,
            "autoCaptionsDefaultOn": false
          },
          "devicePlaybackCapabilities": {
            "supportXhr": true,
            "supportsVp9Encoding": true,
          }
        },
      };
      if (controller.playlistId.isNotEmpty) {
        var playlistId = controller.playlistId;
        if (controller.playlistId.startsWith("VL")) {
          playlistId = controller.playlistId.replaceAll("VL", "");
        }
        body['playlistId'] = playlistId;
      }

      var url = "https://music.youtube.com/youtubei/v1/player?prettyPrint=false";
      var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
      final data = result.data;
      final playbackUrl = data?["playbackTracking"]?["videostatsPlaybackUrl"]?['baseUrl'];
      final watchTimeUrl = data?["playbackTracking"]?["videostatsWatchtimeUrl"]?['baseUrl'];
      AppLog.i("postYoutube player title:${controller.nowData["title"]},videoId:$videoId, url:$url, body:$body, header:$_header");
      // AppLog.i("postYoutubePlaybackInfo watchTimeUrl:$watchTimeUrl, body:$body, $_header");
      if (playbackUrl == null || watchTimeUrl == null) return;
      playbackMap[videoId] = {"playlistId": playlistId, "playbackUrl": playbackUrl, "watchTimeUrl": watchTimeUrl, "cpn": cnp};
    }

    final info = playbackMap[videoId];
    if (info != null) {
      double et = (controller.player?.value.position.inMilliseconds ?? 0) / 1000;
      if (et <= 0.001) {
        et = 0.001;
      }
      double st = info['positionSec'] ?? 0;
      if (st > et) {
        return;
      }
      info['positionSec'] = et;
      if (!isWatchOnly) {
        await _postPlaybackUrl(info['playbackUrl'], playlistId: info['playlistId'], cmt: et, cpn: info['cpn'] ?? cnp);
      } else {
        _postWatchTime(info['watchTimeUrl'], playlistId: info['playlistId'], st: st, et: et, cpn: info['cpn'] ?? cnp);
      }
    }
  }

//UG2M_4YDaSgS8mVI
//qiPN2z1uzGROFbTt
//T9VDhD-I17X9aTsu
  Future _postPlaybackUrl(String? url, {required String cpn, String? playlistId, required double cmt}) async {
    if (url == null || !url.contains("http")) return;
    url = url.replaceFirst("s.youtube.com", "music.youtube.com");
    url = url.replaceAll("&fexp=&",
        "&fexp=v1%2C24004644%2C27005591%2C53408%2C34656%2C106030%2C18644%2C14869%2C75925%2C26895%2C9252%2C3479%2C12457%2C573%2C23206%2C15179%2C2%2C51819%2C2795%2C20480%2C3727%2C591%2C5345%2C700%2C64%2C4324%2C2314%2C3082%2C5385%2C1563%2C13228%2C4176%2C1863%2C487%2C2644%2C375%2C723%2C3306%2C868%2C1059%2C7110%2C3008%2C529%2C1696%2C684%2C2210%2C855%2C336%2C2300%2C6515%2C648%2C636%2C1461%2C2739&");
    String path = "&cpn=$cpn"
        "&ver=2"
        // "&c=WEB_REMIX"
        "&c=ANDROID_MUSIC"
        "&hl=$_hl2"
        "&cr=$_gl"
        "&volume=100"
        "&cmt=$cmt"
        "&muted=0";
    if (playlistId != null && playlistId.isNotEmpty) {
      if (playlistId.startsWith("VL")) {
        playlistId = playlistId.replaceAll("VL", "");
      }
      String p = "&list=$playlistId&referrer=${Uri.encodeFull('https://music.youtube.com/playlist?list=$playlistId')}";
      path = path + p;
    }
    url = url + path;

    BaseModel result = await httpRequest(url, method: HttpMethod.get, contentType: "application/json", headers: _header);

    AppLog.i("postPlaybackUrl:$url, result:${result.code}");
  }

  _postWatchTime(String? url, {required String cpn, String? playlistId, required double st, required double et}) async {
    if (url == null || !url.contains("http")) return;
    url = url.replaceFirst("s.youtube.com", "music.youtube.com");
    url = url.replaceAll("&fexp=", "");
    var path = "&cpn=$cpn"
        "&ver=2"
        "&c=WEB_REMIX"
        "&cplatform=DESKTOP"
        "&cver=$_webRemixVersion"
        "&volume=100"
        "&hl=$_hl2"
        "&cr=$_gl"
        "&cmt=$et"
        "&muted=0"
        "&state=playing"
        "&st=$st" //开始时间
        "&et=$et"; //结束时间

    if (playlistId != null && playlistId.isNotEmpty) {
      if (playlistId.startsWith("VL")) {
        playlistId = playlistId.replaceAll("VL", "");
      }
      String p = "&list=$playlistId&referrer=${Uri.encodeComponent('https://music.youtube.com/playlist?list=$playlistId')}";
      path = path + p;
    }
    url = url + path;

    BaseModel result = await httpRequest(url, method: HttpMethod.get, contentType: "application/json", headers: _header);

    AppLog.i("postWatchTime:$url, result:${result.code}");
  }

  Map<String, String> get _header {
    Map<String, String> header = {
      "X-Youtube-Client-Name": '67',
      "X-Youtube-Client-Version": _webRemixVersion,
      "Referer": "https://music.youtube.com/",
      "Origin": "https://music.youtube.com"
      // "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
      // "X-Youtube-Bootstrap-Logged-In": "false"
    };
    if (Get.find<Application>().visitorData.isNotEmpty) {
      header["X-Goog-Visitor-Id"] = Get.find<Application>().visitorData;
    }
    return header;
  }

  String get _hl {
    final locale = WidgetsBinding.instance.window.locale;
    return "en";
    if (locale.countryCode == null) {
      return locale.languageCode;
    }
    return locale.toString();
    return "${locale.languageCode}-${locale.countryCode}";
  }

  String get _hl2 {
    final locale = WidgetsBinding.instance.window.locale;
    if (locale.countryCode == null) {
      return locale.languageCode;
    }
    return locale.toString();
    // return "${locale.languageCode}_${locale.countryCode}";
  }

  String get _gl {
    final locale = WidgetsBinding.instance.window.locale;
    final c = locale.countryCode ?? 'US';
    if (c == "CN") {
      return "JP";
    }
    return c;
  }

  Map<String, dynamic> get _webRemixContext {
    Map<String, dynamic> content = {
      "client": {
        // "hl": MyTranslations.locale.languageCode,
        "hl": _hl,
        "gl": _gl,
        "clientName": "WEB_REMIX",
        "clientVersion": _webRemixVersion,
        "platform": "DESKTOP",
        "originalUrl": "https://music.youtube.com/"
      }
    };
    if (Get.find<Application>().visitorData.isNotEmpty) {
      content["visitorData"] = Get.find<Application>().visitorData;
    }
    return content;
  }

  String get _webRemixVersion {
    return '1.20250804.03.00';
  }

  String get _generateRandomId {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const separators = ['_'];

    final rand = Random.secure();
    final buffer = StringBuffer();

    final r = Random().nextInt(10) + 2;

    // 生成随机字符
    for (int i = 0; i < 16; i++) {
      // 随机插入一个分隔符（可选）
      if (i == r && rand.nextBool()) {
        buffer.write(separators[rand.nextInt(separators.length)]);
      } else {
        buffer.write(chars[rand.nextInt(chars.length)]);
      }
    }

    return buffer.toString();
  }
}
