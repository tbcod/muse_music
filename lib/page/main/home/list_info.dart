import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:music_muse/const/app_color.dart';
import 'package:music_muse/const/db_key.dart';
import 'package:music_muse/page/main/home.dart';
import 'package:music_muse/page/main/home/list_add.dart';
import 'package:music_muse/page/main/home/play.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/toast.dart';

import 'add_list.dart';
import 'create_music_lyrics.dart';
import 'lyrics_info.dart';

class ListInfo extends GetView<ListInfoController> {
  const ListInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ListInfoController());
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: 146.w,
              width: double.infinity,
              decoration: BoxDecoration(
                  // color: Colors.red,
                  image: DecorationImage(
                image: AssetImage("assets/img/all_appbar_bg.png"),
                fit: BoxFit.fill,
              )),
            ),
            Positioned.fill(
                child: Column(
              children: [
                AppBar(
                  actions: [
                    IconButton(
                      onPressed: () {
                        showMoreListView(controller.infoData);
                      },
                      // icon: Image.asset(
                      //   "assets/img/icon_edit.png",
                      //   width: 24.w,
                      //   height: 24.w,
                      // )
                      icon: Icon(Icons.more_vert),
                    )
                  ],
                ),
                Expanded(
                    child: Obx(() => controller.infoData.isEmpty
                        ? Container()
                        : Container(
                            child: MediaQuery.removePadding(
                              removeTop: true,
                              context: context,
                              child: Column(
                                children: [
                                  Container(
                                    height: 142.w,
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.w),
                                    child: Row(
                                      children: [
                                        //封面
                                        Container(
                                          height: 142.w,
                                          width: 172.w,
                                          child: Stack(
                                            children: [
                                              //底部
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: controller
                                                            .infoData["type"] ==
                                                        1
                                                    ? Container(
                                                        width: 132.w,
                                                        height: 132.w,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        66.w),
                                                            color:
                                                                Colors.black),
                                                      )
                                                    : Container(
                                                        width: 128.w,
                                                        height: 128.w,
                                                        margin: EdgeInsets.only(
                                                            right: 20.w),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                    0xff141414)
                                                                .withOpacity(
                                                                    0.15),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.w)),
                                                      ),
                                              ),

                                              //封面
                                              Container(
                                                width: 142.w,
                                                height: 142.w,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.w)),
                                                child: Image.memory(
                                                  controller.infoData["cover"],
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),

                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.infoData["title"],
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16.w),
                                            ),
                                            SizedBox(
                                              height: 20.w,
                                            ),
                                            Obx(() => Text(
                                                  "${controller.list.length} songs",
                                                  style: TextStyle(
                                                      fontSize: 12.w,
                                                      color: Color(0xff141414)
                                                          .withOpacity(0.75)),
                                                )),
                                          ],
                                        )),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24.w,
                                  ),
                                  Obx(() => controller.list.isEmpty
                                      ? Container()
                                      : Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w),
                                          child: Row(
                                            children: [
                                              Obx(() => Text(
                                                    "Playlist  (${controller.list.length})  ",
                                                    style: TextStyle(
                                                        fontSize: 20.w),
                                                  )),
                                              //播放全部按钮
                                              if (controller.infoData["type"] ==
                                                  1)
                                                InkWell(
                                                  onTap: () {
                                                    // if (!controller.isMusic) {
                                                    //   ToastUtil.showToast(
                                                    //       msg: "仅支持音乐歌单");
                                                    //   return;
                                                    // }

                                                    Get.find<
                                                            PlayPageController>()
                                                        .setDataAndPlay({
                                                      "item":
                                                          controller.list[0],
                                                      "list": controller.list
                                                    });
                                                    Get.to(PlayPage());
                                                  },
                                                  child: Container(
                                                    height: 26.w,
                                                    decoration: BoxDecoration(
                                                        color: Color(0xffCBBFFF)
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    13.w)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6.w),
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          "assets/img/icon_list_play.png",
                                                          width: 14.w,
                                                          height: 14.w,
                                                        ),
                                                        SizedBox(
                                                          width: 2.w,
                                                        ),
                                                        Text(
                                                          "Play All",
                                                          style: TextStyle(
                                                              fontSize: 10.w,
                                                              color: Color(
                                                                  0xff824EFF)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        )),
                                  SizedBox(
                                    height: 14.w,
                                  ),
                                  Expanded(child: Obx(() {
                                    if (controller.list.isEmpty) {
                                      //空布局
                                      return Container(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 40.w,
                                            ),
                                            Image.asset(
                                              "assets/img/icon_empty.png",
                                              width: 140.w,
                                              height: 140.w,
                                            ),
                                            Text(
                                              "No content now, Add songs you like",
                                              style: TextStyle(fontSize: 14.w),
                                            ),
                                            SizedBox(height: 32.w),
                                            InkWell(
                                              onTap: () {
                                                Get.to(ListAddPage(),
                                                    arguments: controller.id);
                                              },
                                              child: Container(
                                                height: 48.w,
                                                width: 112.w,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.w),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color:
                                                            Color(0xff141414),
                                                        width: 1.w)),
                                                child: Text(
                                                  "Add",
                                                  style:
                                                      TextStyle(fontSize: 14.w),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                Get.mediaQuery.padding.bottom +
                                                    8.w +
                                                    50.w),
                                        itemBuilder: (_, i) {
                                          if (controller.isMusic) {
                                            return getList2Item(i);
                                          }
                                          return getList1Item(i);
                                        },
                                        separatorBuilder: (_, i) {
                                          return SizedBox(height: 18.w);
                                        },
                                        itemCount: controller.list.length);
                                  }))
                                ],
                              ),
                            ),
                          )))
              ],
            ))
          ],
        ),
      ),
    );
  }

  getList1Item(int i) {
    var item = controller.list[i];

    return InkWell(
      onTap: () {
        Get.to(LyricsInfo(), arguments: item);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24.w)),
        child: Stack(
          children: [
            Container(
              height: 112.w,
              width: double.infinity,
              // color: Colors.grey,
              // constraints: BoxConstraints(minHeight: 100.w, maxHeight: 150),
              decoration: BoxDecoration(
                  image: DecorationImage(

                      //686*224
                      // centerSlice: Rect.fromLTWH(40, 40, 350, 70),
                      image: AssetImage("assets/img/home_item_bg.png"),
                      fit: BoxFit.fill)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 12.w, right: 16.w, top: 16.w, bottom: 10.w),
                      child: Text(
                        item["title"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.w, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 12.w, right: 72.w),
                      child: Text(item["lyrics"] ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.w)),
                    ),
                    // SizedBox(
                    //   height: 22.w,
                    // )
                  ]),
            ),
            Positioned(
              bottom: 5.w,
              right: 0,
              child: Container(
                height: 28.w,
                width: 64.w,
                child: Image.asset(
                  "assets/img/home_item_play.png",
                  fit: BoxFit.fill,
                ),
                // color: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }

  getList2Item(int i) {
    var item = controller.list[i];
    // var itemData = {
    //   "id": id,
    //   "saveTime": DateTime.now(),
    //   "title": musicName,
    //   "cover": albumArt,
    //   "fileData": file.bytes,
    // };
    Uint8List? fileData = item["fileData"];
    Uint8List? cover = item["cover"];

    return InkWell(
      onTap: () {
        Get.find<PlayPageController>()
            .setDataAndPlay({"item": item, "list": controller.list});
        Get.to(PlayPage());
      },
      child: Obx(() {
        var isCheck =
            Get.find<PlayPageController>().nowData["id"] == item["id"];
        return Container(
          // height: 52.w,
          padding: EdgeInsets.only(left: 16.w, right: 0, top: 5.w, bottom: 5.w),
          width: double.infinity,
          decoration: BoxDecoration(
              color: isCheck ? Color(0xfff4f4f4) : Colors.transparent),
          child: Row(
            children: [
              //封面
              Container(
                height: 52.w,
                width: 52.w,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6.w)),
                child: cover == null
                    ? Image.asset("assets/img/icon_music_cover.png")
                    : Image.memory(cover),
              ),
              SizedBox(
                width: 12.w,
              ),
              Expanded(
                  child: Text(
                item["title"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14.w,
                    color: isCheck ? Color(0xff8569FF) : Colors.black),
              )),
              SizedBox(
                width: 35.w,
              ),

              InkWell(
                  onTap: () {
                    showMoreView(item);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    child: Image.asset(
                      "assets/img/icon_music_more.png",
                      width: 24.w,
                      height: 24.w,
                    ),
                  ))
            ],
          ),
        );
      }),
    );
  }

  showMoreView(Map item) async {
    //底部弹出更多

    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();

    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffEAE8F9), Color(0xfffafafa)])),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  var titleList = ["Create Lyric", "Edit", "Delete"];
                  var iconList = ["more1", "more2", "more3"];

                  return InkWell(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/img/icon_${iconList[i]}.png",
                            width: 24.w,
                            height: 24.w,
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                          Text(titleList[i])
                        ],
                      ),
                    ),
                    onTap: () async {
                      Get.back();
                      if (i == 0) {
                        //歌曲创建歌词
                        Get.to(CreateMusicLyrics(), arguments: item["id"]);
                      } else if (i == 1) {
                        //编辑
                        await Future.delayed(Duration(milliseconds: 400));
                        showRenameView(item);
                      } else if (i == 2) {
                        //删除歌单歌曲
                        // var box = await Hive.openBox(DBKey.tracksData);
                        // await box.delete(item["id"]);
                        // controller.bindData();
                        controller.list.remove(item);
                        var box = await Hive.openBox(DBKey.listData);
                        var data = Map.from(controller.infoData);
                        data["list"] = controller.list;

                        await box.put(controller.id, data);
                        //刷新首页
                        Get.find<HomePageController>().bindData();
                      }
                    },
                  );
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 16.w,
                  );
                },
                itemCount: 3),
            SizedBox(
              height: 32.w,
            ),
            Container(
              height: 1.w,
              width: double.infinity,
              color: Color(0xff121212).withOpacity(0.05),
            ),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.w),
                width: double.infinity,
                alignment: Alignment.center,
                // color: Colors.red,
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Color(0xff121212).withOpacity(0.75)),
                ),
              ),
            ),
            SizedBox(
              height: Get.mediaQuery.padding.bottom,
            )
          ],
        ),
      ),
      backgroundColor: Color(0xfffafafa),
      barrierColor: Colors.black.withOpacity(0.43),
    );
//关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }

  showRenameView(Map item) async {
    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();

    var inputC = TextEditingController();
    inputC.text = item["title"] ?? "";

    await Get.bottomSheet(
        Container(
          padding: EdgeInsets.only(top: 24.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffEAE8F9), Color(0xfffafafa)])),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "Rename",
                  style: TextStyle(fontSize: 20.w),
                ),
              ),
              SizedBox(
                height: 16.w,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CupertinoTextField(
                  controller: inputC,
                  autofocus: true,
                  placeholder: "Enter name\n\n\n\n",
                  maxLines: 5,
                  maxLength: 100,
                  style: TextStyle(fontSize: 14.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.w),
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: 32.w,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                        child: InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              height: 48.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.w),
                                  border: Border.all(
                                      color:
                                          Color(0xff824EFF).withOpacity(0.75),
                                      width: 2.w)),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize: 14.w,
                                    color: Color(0xff824EFF).withOpacity(0.75)),
                              ),
                            ))),
                    SizedBox(
                      width: 23.w,
                    ),
                    Expanded(
                        child: InkWell(
                            onTap: () async {
                              if (inputC.text.trim().isEmpty) {
                                ToastUtil.showToast(msg: "Enter name");
                                return;
                              }
                              //保存信息
                              var box = await Hive.openBox(DBKey.tracksData);

                              var id = item["id"];
                              var data = Map.of(item);
                              data["title"] = inputC.text;
                              await box.put(id, data);
                              //刷新首页数据
                              Get.find<HomePageController>().bindData();
                              controller.bindData();
                              //刷新播放列表
                              Get.find<PlayPageController>().reloadList();

                              Get.back();
                            },
                            child: Container(
                              height: 48.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff824EFF).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24.w),
                              ),
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                    fontSize: 14.w, color: Colors.white),
                              ),
                            ))),
                  ],
                ),
              ),
              SizedBox(
                height: 24.w,
              ),
              SizedBox(
                height: Get.mediaQuery.padding.bottom,
              ),
            ],
          ),
        ),
        barrierColor: Colors.black.withOpacity(0.43),
        backgroundColor: Color(0xfffafafa),
        isScrollControlled: true);
//关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }

  showMoreListView(Map item) async {
    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();

    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffEAE8F9), Color(0xfffafafa)])),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  var titleList = ["Edit Playlist", "Edit", "Delete"];
                  var iconList = ["more1", "more2", "more3"];

                  return InkWell(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/img/icon_${iconList[i]}.png",
                            width: 24.w,
                            height: 24.w,
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                          Text(titleList[i])
                        ],
                      ),
                    ),
                    onTap: () async {
                      Get.back();
                      if (i == 1) {
                        //编辑
                        Get.to(AddList(), arguments: item["id"]);
                      } else if (i == 2) {
                        //删除歌单
                        var box = await Hive.openBox(DBKey.listData);
                        await box.delete(item["id"]);
                        ToastUtil.showToast(msg: "Delete successfully");
                        // controller.bindData();
                        //刷新首页
                        Get.find<HomePageController>().bindData();
                        Get.back();
                      } else if (i == 0) {
                        Get.to(ListAddPage(), arguments: controller.id);
                      }
                    },
                  );
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 16.w,
                  );
                },
                itemCount: 3),
            SizedBox(
              height: 32.w,
            ),
            Container(
              height: 1.w,
              width: double.infinity,
              color: Color(0xff121212).withOpacity(0.05),
            ),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.w),
                width: double.infinity,
                alignment: Alignment.center,
                // color: Colors.red,
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Color(0xff121212).withOpacity(0.75)),
                ),
              ),
            ),
            SizedBox(
              height: Get.mediaQuery.padding.bottom,
            )
          ],
        ),
      ),
      backgroundColor: Color(0xfffafafa),
      barrierColor: Colors.black.withOpacity(0.43),
    );
//关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }
}

class ListInfoController extends GetxController {
  var infoData = {}.obs;
  var id = "";
  var isMusic = false;
  var list = [].obs;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments ?? "";
    bindData();
  }

  bindData() async {
    var box = await Hive.openBox(DBKey.listData);
    infoData.value = box.get(id);
    isMusic = infoData["type"] == 1;

    //list数据
    List oldList = infoData["list"] ?? [];
    var idList = oldList.map((e) {
      return e["id"];
    }).toList();

    Box box2;
    if (isMusic) {
      box2 = await Hive.openBox(DBKey.tracksData);
    } else {
      box2 = await Hive.openBox(DBKey.lyricsData);
    }

    list.clear();
    for (int i = 0; i < idList.length; i++) {
      list.add(box2.get(idList[i]));
    }
    // list.value = infoData["list"] ?? [];
    AppLog.e(list.length);
  }
}
