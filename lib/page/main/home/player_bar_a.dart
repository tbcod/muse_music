import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_muse/page/main/home/add_lyrics.dart';
import 'package:music_muse/page/main/home/create_music_lyrics.dart';
import 'package:music_muse/page/main/home/lyrics_info.dart';
import 'package:music_muse/page/main/home/play.dart';

class PlayerBarA extends StatelessWidget {
  const PlayerBarA({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PlayPageController>()) {
      Get.put(PlayPageController());
    }
    PlayPageController controller = Get.find();
    // final isPlaying = controller.isPlaying;
    // final player = controller.player;
    // final nowData = controller.nowData;
    // final nowIndex = controller.nowIndex;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(const PlayPage());
                    },
                    child: Obx(() {
                      if (controller.nowData.isEmpty) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8.w),
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: const Color(0xff474747).withOpacity(0.06), blurRadius: 5.w, spreadRadius: 2.w)],
                            borderRadius: BorderRadius.circular(12.w)),
                        child: Row(
                          children: [
                            //封面
                            Obx(() {
                              Uint8List? cover = controller.nowData["cover"];
                              return Container(
                                height: 36.w,
                                width: 36.w,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w)),
                                child: cover == null
                                    ? Image.asset(
                                        "assets/img/icon_music_cover.png",
                                        fit: BoxFit.cover,
                                      )
                                    : Image.memory(
                                        cover,
                                        fit: BoxFit.cover,
                                      ),
                              );
                            }),

                            SizedBox(
                              width: 12.w,
                            ),
                            //标题
                            Expanded(
                                child: Obx(() => Text(
                                      controller.nowData["title"] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ))),

                            //按钮
                            Obx(() => InkWell(
                                  child: Container(
                                    width: 32.w,
                                    height: 32.w,
                                    child: Image.asset(controller.isPlaying.value ? "assets/img/icon_b_pause.png" : "assets/img/icon_b_play.png"),
                                  ),
                                  onTap: () async {
                                    if (controller.isPlaying.value) {
                                      await controller.player.pause();
                                    } else {
                                      await controller.player.resume();

                                      //暂停其他页面的播放
                                      if (Get.isRegistered<AddLyricsController>()) {
                                        if (Get.find<AddLyricsController>().isPlaying.value) {
                                          Get.find<AddLyricsController>().pausePlay();
                                        }
                                      }
                                      if (Get.isRegistered<LyricsInfoController>()) {
                                        if (Get.find<LyricsInfoController>().isPlaying.value) {
                                          Get.find<LyricsInfoController>().pausePlay();
                                        }
                                      }
                                      if (Get.isRegistered<CreateMusicLyricsController>()) {
                                        if (Get.find<CreateMusicLyricsController>().isPlaying.value) {
                                          Get.find<CreateMusicLyricsController>().pausePlay();
                                        }
                                      }
                                    }
                                    // isPlaying.toggle();
                                  },
                                )),

                            SizedBox(
                              width: 6.w,
                            ),
                            Obx(() {
                              return InkWell(
                                child: Container(
                                  width: 32.w,
                                  height: 32.w,
                                  child: Image.asset(
                                    "assets/img/icon_b_next.png",
                                    color: controller.canNext.value ? Colors.black : Colors.grey,
                                  ),
                                ),
                                onTap: () {
                                  if (!controller.canNext.value) {
                                    return;
                                  }
                                  controller.playMusic(controller.nowIndex + 1);
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ),
                  //进度条

                  Positioned(
                      left: 16.w,
                      bottom: 1.w,
                      right: 16.w,
                      child: Obx(() => LinearProgressIndicator(
                            minHeight: 2.w,
                            borderRadius: BorderRadius.circular(1.w),
                            backgroundColor: Color(0xffAF9DFD).withOpacity(0.2),
                            color: Color(0xffAF9DFD).withOpacity(0.75),
                            value: controller.sliderValue.value,
                          )))
                ],
              ),
            )),
      ],
    );
  }
}
