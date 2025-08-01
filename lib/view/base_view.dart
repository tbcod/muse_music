import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../util/download/download_util.dart';
import '../util/more_sheet_util.dart';
import '../util/tba/event_util.dart';

getDownloadAndMoreBtn(Map item, String type,
    {bool isSearch = false, bool locIsHome = false, double iconHeight = 50}) {
  // type分类
  //loc_playlist
  //net_playlist
  //search
  //liked
  //download
  //artist_more_song
  //artist
  //

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      //获取是否显示下载按钮
      if (FirebaseRemoteConfig.instance.getString("musicmuse_off_switch") ==
          "on")
        Obx(() {
          //获取下载状态
          var videoId = item["videoId"];

          if (DownloadUtils.instance.allDownLoadingData.containsKey(videoId)) {
            //有添加过下载
            var state =
                DownloadUtils.instance.allDownLoadingData[videoId]["state"];
            double progress =
                DownloadUtils.instance.allDownLoadingData[videoId]["progress"];

            // AppLog.e(
            //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");

            if (state == 1 || state == 3) {
              //下载中\下载暂停
              return InkWell(
                onTap: () {
                  DownloadUtils.instance.remove(videoId);
                },
                child: Container(
                  height: iconHeight,
                  // color: Colors.red,
                  width: 32.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(6.w),
                  child: Container(
                      width: 20.w,
                      height: 20.w,
                      // padding: EdgeInsets.all(5.w),
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 1.5,
                        backgroundColor: Color(0xffA995FF).withOpacity(0.35),
                        color: Color(0xffA995FF),
                      )),
                ),
              );
            } else if (state == 2) {
              return InkWell(
                onTap: () {
                  DownloadUtils.instance.remove(videoId);
                },
                child: Container(
                  height: iconHeight,
                  // color: Colors.red,
                  padding: EdgeInsets.all(6.w),
                  child: Image.asset(
                    "assets/oimg/icon_download_ok.png",
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              );
            }
          }

          return InkWell(
            onTap: () {
              if (type == "net_playlist" || type == "loc_playlist") {
                EventUtils.instance.addEvent("det_playlist_click",
                    data: {"detail_click": "dl"});
              }
              if (type == "artist_more_song" || type == "artist") {
                EventUtils.instance
                    .addEvent("det_artist_click", data: {"detail_click": "dl"});
              }

              if (type == "net_playlist" ||
                  type == "artist_more_song" ||
                  type == "artist") {
                DownloadUtils.instance.download(videoId, item,
                    clickType: isSearch ? "s_detail" : "h_detail");
                return;
              } else if (type == "loc_playlist" ||
                  type == "liked" ||
                  type == "download") {
                DownloadUtils.instance.download(videoId, item,
                    clickType: locIsHome ? "h_detail" : "library");
                return;
              }

              DownloadUtils.instance.download(videoId, item, clickType: type);
            },
            child: Container(
              height: iconHeight,
              // color: Colors.red,
              padding: EdgeInsets.all(6.w),
              child: Image.asset(
                "assets/oimg/icon_download_gray.png",
                width: 20.w,
                height: 20.w,
              ),
            ),
          );
        }),
      // SizedBox(
      //   width: 2.w,
      // ),
      InkWell(
        onTap: () {
          if (type == "net_playlist" || type == "loc_playlist") {
            EventUtils.instance
                .addEvent("det_playlist_click", data: {"detail_click": "more"});
          }
          if (type == "artist_more_song" || type == "artist") {
            EventUtils.instance
                .addEvent("det_artist_click", data: {"detail_click": "more"});
          }

          MoreSheetUtil.instance.showVideoMoreSheet(item, clickType: type);
        },
        child: Container(
          height: iconHeight,
          padding: EdgeInsets.all(6.w),
          child: Container(
            width: 20.w,
            height: 20.w,
            child: Image.asset("assets/oimg/icon_more.png"),
          ),
        ),
      )
    ],
  );
}
