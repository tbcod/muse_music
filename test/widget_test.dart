// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_muse/api/api_main.dart';

import 'package:music_muse/main.dart';
import 'package:music_muse/util/log.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

void main() async {
  // print(await getDData([
  //   "VuNIsY6JdUw",
  //   "H5v3kku4y6Q",
  //   "saGYMhApaH8",
  //   "Il0S8BoucSA",
  //   "A_g3lMcWVy0",
  //   "l6_w3887Rwo",
  //   "p38WgakuYDo",
  //   "OD3F7J2PeYU",
  //   "pw0PVm1CcH8",
  //   "kTbRnDwkR0Y",
  //   "Oa_RSwwpPaA",
  //   "o5thu6-7y3Q",
  // ]));

  var ebase64 = "";

//榜单
  var list1 = [
    {
      "title": "Top Songs United States",
      "cover":
          "https://i.ytimg.com/vi/kPa7bsKwL-c/hqdefault.jpg?sqp=-oaymwEXCNACELwBSFryq4qpAwkIARUAAIhCGAE=&rs=AOn4CLBnYo3mcD9yf7AmL4orirUREYJg9Q",
      "browseId": "VLPLO7-VO1D0_6No4YpDVJxBT5wMkbHX_MuG",
      "playlistId": "PLO7-VO1D0_6No4YpDVJxBT5wMkbHX_MuG"
    },
    {
      "title": "Top Songs Mexico",
      "cover":
          "https://i.ytimg.com/vi/_ymicn0_GYc/hqdefault.jpg?sqp=-oaymwEnCNACELwBSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLDAzyrCNXAr7ljFt7Inhrs-lx4mmA",
      "browseId": "VLPLOwSo8kHs4XSRN8vCTpTApd4eoSuDG58N",
      "playlistId": "PLOwSo8kHs4XSRN8vCTpTApd4eoSuDG58N"
    },
    {
      "title": "Top Songs Brazil",
      "cover":
          "https://i.ytimg.com/vi/ZsN_0_6yEXk/hqdefault.jpg?sqp=-oaymwEnCNACELwBSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLDsrRSv7pCmXtHMjUWTHw8pbUM0XQ",
      "browseId": "VLPLSJkIg_k31H92tDIbGCSK1x2eRqPoVJV-",
      "playlistId": "PLSJkIg_k31H92tDIbGCSK1x2eRqPoVJV-"
    },
    {
      "title": "Top songs global weekly",
      "cover":
          "https://i.ytimg.com/vi/ekr2nIex040/hqdefault.jpg?sqp=-oaymwEnCNACELwBSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLBRSqFFz5z7JDdmHE_tOSScjzIDXQ",
      "browseId": "VLPLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx",
      "playlistId": "PLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx"
    },
    {
      "title": "Top songs global daily",
      "cover":
          "https://i.ytimg.com/vi/ekr2nIex040/hqdefault.jpg?sqp=-oaymwEXCNACELwBSFryq4qpAwkIARUAAIhCGAE=&rs=AOn4CLBTFFuwNIgpiD5RRS7tRo5uQutX5Q",
      "browseId": "VLPL3oW2tjiIxvQpeIgr2Bhno4vQdfpI9Ax5",
      "playlistId": "PL3oW2tjiIxvQpeIgr2Bhno4vQdfpI9Ax5"
    },
  ];
//歌曲
  var list2 = [];
//歌手
  var list3 = [
    {
      "title": "Taylor Swift",
      "subtitle": "",
      "cover":
          "https://lh3.googleusercontent.com/yjSBybGLwZIXsQSKo66IBdeObxQENOtmjLsl5BvJC7qYHOJqpOKcV1dcc8GPZKhBHWrSCBAxZyml4g=w120-h120-p-l90-rj",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
      "browseId": "UCPC0L1d253x-KuMNwa05TpA",
      "youtubeId": "UCqECaJ8Gagnn7YCbPEzWH6g"
    },
    {
      "title": "Bad Bunny",
      "subtitle": "",
      "cover":
          "https://lh3.googleusercontent.com/XE2cp2mnVX1H1k8yX80VrnkYDJ4f53m2q9gflVkjdCeaOC75oAih0EEO5X4Xw_OGf1lRSg6rg1CfmA=w120-h120-p-l90-rj",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
      "browseId": "UCiY3z8HAGD6BlSNKVn2kSvQ",
      "youtubeId": "UCmBA_wu8xGg1OfOkfW13Q0Q"
    },
    {
      "title": "Harry Styles",
      "subtitle": "",
      "cover":
          "https://lh3.googleusercontent.com/zBbc8tVV6vaav8EihQfJz2xVvpHMiN1OTOM8TLWNNd-vg13IvTKZu8a6A_6cYxm92WvNtwnnpRSC7PY=w120-h120-p-l90-rj",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
      "browseId": "UCVacQ2t5GUZ2t_J3Ia9BynA",
      "youtubeId": "UCZFWPqqPkFlNwIxcpsLOwew"
    },
    {
      "title": "Xavi",
      "subtitle": "",
      "cover":
          "https://lh3.googleusercontent.com/bxEbQnwprEouo6jHJIwKDs70Gfkbb7zb4qc_-WeiuVKBQdYhNr6cmlSXepa5hI3RCI2Iy_h3sr9-eS7m=w120-h120-p-l90-rj",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
      "browseId": "UCfmeXjlCXi37LGF7O2VT2zA",
      "youtubeId": "UCx0lY_L_o5vFPQaLAdBasmQ"
    },
    {
      "title": "Justin Bieber",
      "subtitle": "",
      "cover":
          "https://lh3.googleusercontent.com/iVttpMqOcjor_Rt64WqL0iB8YJ3At97IGNer6qzhYQ7ffoqzVL7pEmxJXmItcZ2Sj_aRT_dewAg1ORg=w120-h120-p-l90-rj",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
      "browseId": "UCGvj8kfUV5Q6lzECIrGY19g",
      "youtubeId": "UCIwFjwMjI0y7PDBVEO9-bkQ"
    },
    {
      "title": "Eminem",
      "subtitle": "",
      "cover":
          "https://lh3.googleusercontent.com/a-/ALV-UjWo1izECUGSCILjKRTOd7gm2au6GxQ3sB0W6yewIv6G5IjHxuu_=w120-h120-l90-rj",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
      "browseId": "UCedvOgsKFzcK3hA5taf3KoQ",
      "youtubeId": "UCfM3zsQsOnfWNUppiycmBuw"
    }
  ];
  // var base64Str = encode(list);
  // print(base64Str);
  // List listdata = decode(ebase64);
  // print(listdata.toString());

  // print(listdata.toString());
}

Future<List> getDData(List listId) async {
  var list = [];

  for (String videoId in listId) {
    BaseModel result = await ApiMain.instance.getVideoNext(videoId);
    if (result.code != HttpCode.success) {
      continue;
    }
    //解析音乐

    // var browseId =
    //     result.data["contents"]["singleColumnMusicWatchNextResultsRenderer"]
    //                         ["tabbedRenderer"]["watchNextTabbedResultsRenderer"]
    //                     ["tabs"][0]["tabRenderer"]["content"]
    //                 ["musicQueueRenderer"]["content"]["playlistPanelRenderer"]
    //             ["contents"][0]["playlistPanelVideoRenderer"]["longBylineText"]
    //         ["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"];

    var title = result.data["contents"]
                            ["singleColumnMusicWatchNextResultsRenderer"]
                        ["tabbedRenderer"]
                    ["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]
                ["content"]["musicQueueRenderer"]["content"]
            ["playlistPanelRenderer"]["contents"][0]
        ["playlistPanelVideoRenderer"]["title"]["runs"][0]["text"];
    //歌手
    var subtitle = result.data["contents"]
                            ["singleColumnMusicWatchNextResultsRenderer"]
                        ["tabbedRenderer"]
                    ["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]
                ["content"]["musicQueueRenderer"]["content"]
            ["playlistPanelRenderer"]["contents"][0]
        ["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]["text"];

    //封面
    var cover = result.data["contents"]
                            ["singleColumnMusicWatchNextResultsRenderer"]
                        ["tabbedRenderer"]
                    ["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]
                ["content"]["musicQueueRenderer"]["content"]
            ["playlistPanelRenderer"]["contents"][0]
        ["playlistPanelVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"];

    list.add({
      {
        "title": title,
        "subtitle": subtitle,
        "cover": cover,
        "type": "MUSIC_VIDEO_TYPE_ATV",
        "videoId": videoId
      }
    });
  }

  return list;
}

String encode(List data) {
  //反转后再base64
  String str = jsonEncode(data).split("").reversed.join("");
  var base64Str = base64.encode(utf8.encode(str));

  return base64Str;
}

List decode(String data) {
  //base64后再反转
  var str = utf8.decode(base64.decode(data));
  var jsonData = jsonDecode(str.split("").reversed.join(""));
  return jsonData;
}
