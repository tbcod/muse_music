import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:music_muse/api/api_main.dart';
import 'package:music_muse/api/base_dio_api.dart';
import 'package:music_muse/app.dart';
import 'package:music_muse/const/db_key.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/dialog_util.dart';
import 'package:music_muse/util/format_data.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:music_muse/util/toast.dart';

class UserSearchController extends GetxController with StateMixin {
  var list = [].obs;
  var historyList = [].obs;

  //搜索结果
  var resultList = [];
  var tabList = [].obs;

  var showSuggestions = false.obs;

  var tabKey = GlobalKey();

  var inputC = TextEditingController();

  // Map<String, dynamic> bestResultList = {};

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindHistoryData();

    //好评引导
    MyDialogUtils.instance.showRateDialog();

    EventUtils.instance.addEvent("search_home");
  }

  void getSearchList(String str) async {
    BaseModel result = await ApiMain.instance.getSearchList(str);
    if (result.code == HttpCode.success) {
      //解析搜索联想词

      //第一条为联想词，第二条为有图片的联想
      List oldList = result.data["contents"].first["searchSuggestionsSectionRenderer"]["contents"];
      var newList = [];
      for (var item in oldList) {
        List childTextList = item["searchSuggestionRenderer"]["suggestion"]["runs"];
        var itemTextView = RichText(
            text: TextSpan(
                children: childTextList
                    .map((e) => TextSpan(text: e["text"], style: TextStyle(fontSize: 14.w, color: Colors.black, fontWeight: e["bold"] == true ? FontWeight.bold : FontWeight.normal)))
                    .toList()));
        var itemText = item["searchSuggestionRenderer"]["navigationEndpoint"]["searchEndpoint"]["query"];

        newList.add({"view": itemTextView, "text": itemText});
      }
      list.value = newList;
      showSuggestions.value = list.isNotEmpty;
    }
  }

  saveHistory(String data) async {
    var box = await Hive.openBox(DBKey.mySearchHistoryData);

    if (data.isEmpty) {
      return;
    }

    await box.put(data, {"str": data, "date": DateTime.now()});

    bindHistoryData();
  }

  Future bindHistoryData() async {
    var box = await Hive.openBox(DBKey.mySearchHistoryData);
    var oldList = box.values.toList();

    //时间降序
    oldList.sort((a, b) {
      DateTime aDate = a["date"];
      DateTime bDate = b["date"];
      return bDate.compareTo(aDate);
    });
    if (oldList.length > 10) {
      historyList.value = oldList.sublist(0, 10);
    } else {
      historyList.value = oldList;
    }

    AppLog.e("共有以下条数历史记录");
    AppLog.e(historyList.length);
  }

  String youtubeMoreToken = "";

  void toSearch(String str) async {
    //收起键盘
    Get.focusScope?.unfocus();

    await Future.delayed(const Duration(milliseconds: 500));

    EventUtils.instance.addEvent("search_content", data: {"content": str});

    //保存搜索历史记录
    saveHistory(str);

    AdUtils.instance.showAd("behavior", adScene: AdScene.search);

    if (Get.find<Application>().typeSo == "yt") {
      //youtube的搜索

      // LoadingUtil.showLoading();
      isLoading.value = true;
      var result = await ApiMain.instance.youtubeSearch(str);
      isLoading.value = false;
      showSuggestions.value = false;
      lastWords = str;
      // LoadingUtil.hideAllLoading();
      if (result.code != HttpCode.success) {
        change("", status: RxStatus.error());
        return;
      }

      //解析数据
      var oldList = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"] ?? [];
      //更多数据token
      try {
        youtubeMoreToken = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][1]["continuationItemRenderer"]?["continuationEndpoint"]
                ?["continuationCommand"]?["token"] ??
            "";
      } catch (e) {
        AppLog.e(e);
        youtubeMoreToken = "";
      }

      var newList = [];
      for (Map item in oldList) {
        if (item.containsKey("videoRenderer")) {
          //视频
          AppLog.e(item);

          var videoId = item["videoRenderer"]["videoId"];
          var cover = item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
          var title = item["videoRenderer"]["title"]["runs"][0]["text"];
          var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
          var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";

          newList.add({"title": title, "subtitle": subtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": "Video"});
        } else {
          //reelShelfRenderer
          //lockupViewModel
          //shelfRenderer
          //channelRenderer

          AppLog.e(item.keys);
        }
      }

      ytList.value = newList;
      change("", status: RxStatus.success());

      EventUtils.instance.addEvent("search_result");

      return;
    }

    //设置上方tab
    tabList.value = ["All".tr];
    tabList.addAll(["Tracks".tr, "Video".tr, "Artist".tr, "Album".tr, "Playlist".tr]);

    //清空搜索记录
    resultList.clear();
    // bestResultList.clear();

    Map<String, dynamic> bestResultList = {};

    //搜索结果
    // LoadingUtil.showLoading();
    isLoading.value = true;
    var result = await ApiMain.instance.getSearchResult(str);
    // LoadingUtil.hideAllLoading();
    isLoading.value = false;

    if (result.code == HttpCode.success) {
      //解析搜索结果
      try {
        List tabs = result.data["contents"]?["tabbedSearchResultsRenderer"]?["tabs"] ?? [];
        List oldList = tabs.firstOrNull?["tabRenderer"]?["content"]?["sectionListRenderer"]?["contents"] ?? [];

        for (Map item in oldList) {
          if (item.containsKey("musicCardShelfRenderer")) {
            try {
              //精准搜索
              final musicCardShelfRenderer = item["musicCardShelfRenderer"];

              List runs = item["musicCardShelfRenderer"]?["title"]?["runs"] ?? [];
              if (runs.isEmpty) continue;

              final title = runs.first["text"];

              List childSubtitleList = item["musicCardShelfRenderer"]["subtitle"]["runs"] ?? [];
              var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

              var cover = musicCardShelfRenderer["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

              var type = runs.first["navigationEndpoint"]?["watchEndpoint"]?["watchEndpointMusicSupportedConfigs"]?["watchEndpointMusicConfig"]?["musicVideoType"];
              var videoId = runs.first["navigationEndpoint"]?["watchEndpoint"]?["videoId"];
              if (videoId == null || type == null) {
                type = runs.first["navigationEndpoint"]?["browseEndpoint"]?["browseEndpointContextSupportedConfigs"]?["browseEndpointContextMusicConfig"]?["pageType"];
                videoId = runs.first["navigationEndpoint"]["browseEndpoint"]["browseId"];
              }

              List contents = [];

              List list = musicCardShelfRenderer["contents"] ?? [];
              for (Map item2 in list) {
                if (item2.containsKey("messageRenderer")) {
                  // contents.add({
                  //   "title": item2["messageRenderer"]?["text"]?["runs"][0]["text"],
                  //   "type": "more",
                  // });
                  continue;
                }
                if (item2.containsKey("musicResponsiveListItemRenderer")) {
                  final musicResponsiveListItemRenderer = item2["musicResponsiveListItemRenderer"];
                  List flexColumns = musicResponsiveListItemRenderer?["flexColumns"] ?? [];
                  if (flexColumns.isEmpty) continue;
                  var cover = musicResponsiveListItemRenderer["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
                  final title = flexColumns.first["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
                  final vid = flexColumns.first["musicResponsiveListItemFlexColumnRenderer"]["te"
                      "xt"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["videoId"];
                  final type = flexColumns.first["musicResponsiveListItemFlexColumnRenderer"]["te"
                      "xt"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];
                  var subTitle = "";
                  if (flexColumns.length > 1) {
                    List runs = flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"] ?? [];
                    subTitle = runs.map((e) => e["text"]).toList().join("");
                  }

                  contents.add({
                    "title": title,
                    "subtitle": subTitle,
                    "cover": cover,
                    "videoId": vid,
                    "type": type,
                  });
                }
              }

              bestResultList = {
                "header": {
                  "title": title,
                  "subtitle": childSubtitle,
                  "cover": cover,
                  "videoId": videoId,
                  "browseId":videoId,
                  "type": type,
                },
                "content": contents,
                "type": "best",
              };
              resultList.add(bestResultList);
            } catch (e) {
              AppLog.e(e);
              continue;
            }

            if (item.containsKey("itemSectionRenderer")) {
              //didYouMean，没有内容
              continue;
            }
          }

          if (item.containsKey("musicShelfRenderer")) {
            List childList = item["musicShelfRenderer"]?["contents"] ?? [];

            //解析childList
            var newChildList = FormatMyData.instance.getAllSearchList(childList);
            resultList.addAll(newChildList);
            // resultList.add({
            //   "title": "list",
            //   "list": newChildList,
            //   "type": "content",
            // });
          }
        }
        // AppLog.e(resultList);

        showSuggestions.value = false;
        change("", status: RxStatus.success());

        EventUtils.instance.addEvent("search_result");
      } catch (e) {
        AppLog.e(e.toString());
      }
    } else {
      showSuggestions.value = false;
      change("", status: RxStatus.error());
    }

    lastWords = str;

    await searchOtherList(str);
  }

  // void toSearch(String str) async {
  //   //收起键盘
  //   Get.focusScope?.unfocus();
  //
  //   await Future.delayed(const Duration(milliseconds: 500));
  //
  //   EventUtils.instance.addEvent("search_content", data: {"content": str});
  //
  //   //保存搜索历史记录
  //   saveHistory(str);
  //
  //   AdUtils.instance.showAd("behavior", adScene: AdScene.search);
  //
  //   if (Get.find<Application>().typeSo == "yt") {
  //     //youtube的搜索
  //
  //     LoadingUtil.showLoading();
  //     var result = await ApiMain.instance.youtubeSearch(str);
  //     showSuggestions.value = false;
  //     lastWords = str;
  //     LoadingUtil.hideAllLoading();
  //     if (result.code != HttpCode.success) {
  //       change("", status: RxStatus.error());
  //       return;
  //     }
  //
  //     //解析数据
  //     var oldList = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][0]
  //             ["itemSectionRenderer"]["contents"] ??
  //         [];
  //     //更多数据token
  //     try {
  //       youtubeMoreToken = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][1]
  //               ["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
  //           "";
  //     } catch (e) {
  //       print(e);
  //       youtubeMoreToken = "";
  //     }
  //
  //     var newList = [];
  //     for (Map item in oldList) {
  //       if (item.containsKey("videoRenderer")) {
  //         //视频
  //         AppLog.e(item);
  //
  //         var videoId = item["videoRenderer"]["videoId"];
  //         var cover = item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
  //         var title = item["videoRenderer"]["title"]["runs"][0]["text"];
  //         var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
  //         var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";
  //
  //         newList.add({"title": title, "subtitle": subtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": "Video"});
  //       } else {
  //         //reelShelfRenderer
  //         //lockupViewModel
  //         //shelfRenderer
  //         //channelRenderer
  //
  //         AppLog.e(item.keys);
  //       }
  //     }
  //
  //     ytList.value = newList;
  //     change("", status: RxStatus.success());
  //
  //     EventUtils.instance.addEvent("search_result");
  //
  //     return;
  //   }
  //
  //   //设置上方tab
  //   tabList.value = ["All".tr];
  //   tabList.addAll(["Tracks".tr, "Video".tr, "Artist".tr, "Album".tr, "Playlist".tr]);
  //
  //   //清空搜索记录
  //   resultList.clear();
  //   //搜索结果
  //   LoadingUtil.showLoading();
  //   var result = await ApiMain.instance.getSearchResult(str);
  //   LoadingUtil.hideAllLoading();
  //
  //   if (result.code == HttpCode.success) {
  //     //解析搜索结果
  //     try {
  //       var oldList = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"];
  //
  //       for (Map item in oldList) {
  //         if (item.containsKey("musicCardShelfRenderer")) {
  //           //精准搜索
  //           String bigTitle = item["musicCardShelfRenderer"]["header"]["musicCardShelfHeaderBasicRenderer"]["title"]["runs"][0]["text"];
  //           // List childList = item["musicShelfRenderer"]["contents"];
  //
  //           var childTitle = item["musicCardShelfRenderer"]["title"]["runs"][0]["text"];
  //
  //           List childSubtitleList = item["musicCardShelfRenderer"]["subtitle"]["runs"];
  //           var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");
  //
  //           var cover = item["musicCardShelfRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
  //
  //           try {
  //             var type = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]
  //                 ["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];
  //             var videoId = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["videoId"];
  //             resultList.add({
  //               "title": bigTitle,
  //               "list": [
  //                 {"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "type": type}
  //               ],
  //               "type": type
  //             });
  //           } catch (e) {
  //             print(e);
  //
  //             var type = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]
  //                 ["browseEndpointContextSupportedConfigs"]["browseEndpointContextMusicConfig"]["pageType"];
  //             var browseId = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"];
  //             resultList.add({
  //               "title": bigTitle,
  //               "list": [
  //                 {"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": type}
  //               ],
  //               "type": type
  //             });
  //           }
  //
  //           continue;
  //         }
  //
  //         if (item.containsKey("itemSectionRenderer")) {
  //           //didYouMean，没有内容
  //           continue;
  //         }
  //
  //         //列表
  //         String bigTitle = item["musicShelfRenderer"]["title"]["runs"][0]["text"];
  //         List childList = item["musicShelfRenderer"]["contents"];
  //
  //         //解析childList
  //         var newChildList = FormatMyData.instance.getAllSearchList(childList);
  //         resultList.add({"title": bigTitle, "list": newChildList, "type": newChildList.first["type"]});
  //       }
  //
  //       // AppLog.e(resultList);
  //
  //       showSuggestions.value = false;
  //       change("", status: RxStatus.success());
  //
  //       EventUtils.instance.addEvent("search_result");
  //     } catch (e) {
  //       AppLog.e(e.toString());
  //     }
  //   } else {
  //     showSuggestions.value = false;
  //     change("", status: RxStatus.error());
  //   }
  //
  //   lastWords = str;
  //
  //   await searchOtherList(str);
  // }

  Future moreYoutubeSearch() async {
    AppLog.e(youtubeMoreToken);

    if (youtubeMoreToken.isEmpty) {
      AppLog.e("没有更多了");
      return;
    }

    var str = lastWords;

    var result = await ApiMain.instance.youtubeSearch(str, continuation: youtubeMoreToken);
    showSuggestions.value = false;
    lastWords = str;
    LoadingUtil.hideAllLoading();
    if (result.code != HttpCode.success) {
      change("", status: RxStatus.error());
      return;
    }

    //解析数据

    var oldList = result.data["onResponseReceivedCommands"][0]["appendContinuationItemsAction"]["continuationItems"][0]["itemSectionRenderer"]["contents"] ?? [];
    //更多数据token
    try {
      youtubeMoreToken = result.data["onResponseReceivedCommands"][0]["appendContinuationItemsAction"]["continuationItems"][1]["continuationItemRenderer"]?["continuationEndpoint"]
              ?["continuationCommand"]?["token"] ??
          "";
    } catch (e) {
      print(e);
      youtubeMoreToken = "";
    }

    var newList = [];
    for (Map item in oldList) {
      if (item.containsKey("videoRenderer")) {
        //视频
        var videoId = item["videoRenderer"]["videoId"];
        var cover = item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
        var title = item["videoRenderer"]["title"]["runs"][0]["text"];
        var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
        var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";
        newList.add({"title": title, "subtitle": subtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": "Video"});
      } else {
        AppLog.e(item.keys);
      }
    }

    ytList.addAll(newList);
  }

  Future searchOtherList(String str) async {
    await Future.wait([searchSong(str), searchVideo(str), searchArtist(str), searchAlbum(str), searchPlaylist(str)]);
  }

  var songList = [].obs;
  var songNextData = {};
  var videoList = [].obs;
  var videoNextData = {};
  var artistList = [].obs;
  var artistNextData = {};
  var albumList = [].obs;
  var albumNextData = {};
  var playlistList = [].obs;
  var playlistNextData = {};

  var lastWords = "";

  var ytList = [].obs;

  var inputFocusNode = FocusNode();
  var showClearBtn = false.obs;

  Future searchSong(String str) async {
    //搜索结果
    songList.clear();
    songNextData = {};
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIIAWoMEAMQBBAOEAoQCRAF");

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
      for (Map item in contents) {
        if (item.containsKey("musicShelfRenderer")) {
          oldList = item["musicShelfRenderer"]?["contents"] ?? [];
          songNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
        }
      }

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        // var childSubtitle =
        //     childSubtitleList.map((e) => e["text"]).toList().join("");
        var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "type": ""});
      }
      songList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreSong() async {
    if (songNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIIAWoMEAMQBBAOEAoQCRAF", nextData: songNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      songNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "type": ""});
      }
      songList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchVideo(String str) async {
    videoList.clear();
    videoNextData = {};
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIQAWoMEAMQBBAOEAoQCRAF");

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
      for (Map item in contents) {
        if (item.containsKey("musicShelfRenderer")) {
          oldList = item["musicShelfRenderer"]?["contents"] ?? [];
          videoNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
        }
      }

      if (oldList.isEmpty) {
        return;
      }

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        // var childSubtitle =
        //     childSubtitleList.map((e) => e["text"]).toList().join("");
        var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
        var timeStr = childSubtitleList.lastOrNull?["text"] ?? "";

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "timeStr": timeStr, "videoId": videoId, "type": ""});
      }
      videoList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreVideo() async {
    if (videoNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIQAWoMEAMQBBAOEAoQCRAF", nextData: videoNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      videoNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        // var childSubtitle =
        //     childSubtitleList.map((e) => e["text"]).toList().join("");
        var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
        var timeStr = childSubtitleList.lastOrNull?["text"] ?? "";

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": ""});
      }
      videoList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchArtist(String str) async {
    artistList.clear();
    artistNextData = {};
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIgAWoMEAMQBBAOEAoQCRAF");

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
      for (Map item in contents) {
        if (item.containsKey("musicShelfRenderer")) {
          oldList = item["musicShelfRenderer"]?["contents"] ?? [];
          artistNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
        }
      }

      if (oldList.isEmpty) {
        return;
      }

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

        // var videoId = item["musicResponsiveListItemRenderer"]
        //     ["playlistItemData"]["videoId"];

        var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
      }
      artistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreArtist() async {
    if (artistNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIgAWoMEAMQBBAOEAoQCRAF", nextData: artistNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      artistNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        // var videoId = item["musicResponsiveListItemRenderer"]
        // ["playlistItemData"]["videoId"];

        var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
      }
      artistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchAlbum(String str) async {
    albumList.clear();
    albumNextData = {};
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIYAWoMEAMQBBAOEAoQCRAF");

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
      for (Map item in contents) {
        if (item.containsKey("musicShelfRenderer")) {
          oldList = item["musicShelfRenderer"]?["contents"] ?? [];
          albumNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
        }
      }

      if (oldList.isEmpty) {
        return;
      }

      // albumNextData = result.data["contents"]["tabbedSearchResultsRenderer"]
      //                 ["tabs"][0]["tabRenderer"]["content"]
      //             ["sectionListRenderer"]["contents"][0]["musicShelfRenderer"]
      //         ["continuations"]?[0]["nextContinuationData"] ??
      //     {};

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

        // var videoId = item["musicResponsiveListItemRenderer"]
        //     ["playlistItemData"]["videoId"];

        var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
      }
      albumList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreAlbum() async {
    if (albumNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: "EgWKAQIYAWoMEAMQBBAOEAoQCRAF", nextData: albumNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      albumNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        // var videoId = item["musicResponsiveListItemRenderer"]
        // ["playlistItemData"]["videoId"];

        var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
      }
      albumList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchPlaylist(String str) async {
    playlistList.clear();
    playlistNextData = {};
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: "EgeKAQQoAEABagwQAxAEEA4QChAJEAU=");

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
      for (Map item in contents) {
        if (item.containsKey("musicShelfRenderer")) {
          oldList = item["musicShelfRenderer"]?["contents"] ?? [];
          playlistNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
        }
      }

      if (oldList.isEmpty) {
        return;
      }

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

        // var videoId = item["musicResponsiveListItemRenderer"]
        //     ["playlistItemData"]["videoId"];

        var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
      }
      playlistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future morePlaylist() async {
    if (playlistNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: "EgeKAQQoAEABagwQAxAEEA4QChAJEAU=", nextData: playlistNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      playlistNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

      var childList = [];
      for (Map item in oldList) {
        var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

        List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

        var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
        // var videoId = item["musicResponsiveListItemRenderer"]
        // ["playlistItemData"]["videoId"];

        var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
        childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
      }
      playlistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  toIndex(int index) {
    DefaultTabController.of(tabKey.currentContext!).animateTo(index);
  }
}
