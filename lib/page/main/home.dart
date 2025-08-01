import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_muse/const/app_color.dart';
import 'package:music_muse/const/db_key.dart';
import 'package:music_muse/page/main/home/add_lyrics.dart';
import 'package:music_muse/page/main/home/create_music_lyrics.dart';
import 'package:music_muse/page/main/home/list_add.dart';
import 'package:music_muse/page/main/home/list_info.dart';
import 'package:music_muse/page/main/home/lyrics_info.dart';
import 'package:music_muse/page/main/home/play.dart';
import 'package:music_muse/page/main/home/search.dart';
import 'package:music_muse/util/keep_view.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../util/idfa_util.dart';
import '../../view/my_shape.dart';
import 'home/add_list.dart';
import 'home/add_music.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => HomePageController());
    return Scaffold(
      backgroundColor: AppColor.mainColor,
      body: Container(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              AppBar(
                title: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Text(
                      "Create My Songs",
                      style: TextStyle(fontSize: 18.w),
                    ),
                    Spacer(),
                    InkWell(
                      child: Image.asset(
                        "assets/img/icon_add_home.png",
                        width: 24.w,
                        height: 24.w,
                      ),
                      onTap: () {
                        controller.showAddDialog();

                        IdfaUtil.instance.showIdfaDialog();
                        Future.delayed(Duration(seconds: 10)).then((e) {
                          IdfaUtil.instance.showIdfaDialog();
                        });
                      },
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),
              ),
              //搜索框
              InkWell(
                onTap: () {
                  IdfaUtil.instance.showIdfaDialog();
                  Get.to(SearchPage());
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  height: 44.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.w)),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/img/icon_search.png",
                        width: 20.w,
                        height: 20.w,
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Text(
                        "Search your songs",
                        style: TextStyle(fontSize: 14.w, color: AppColor.grey),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 24.w,
              ),

              //tabbar
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  height: 36.w,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        return Obx(() {
                          var isCheck = controller.tabIndex.value == i;
                          var tabTitle = controller.tabListTitle[i];
                          return InkWell(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                height: 36.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: isCheck
                                        ? Colors.black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18.w),
                                    border: Border.all(
                                        color: isCheck
                                            ? Colors.transparent
                                            : AppColor.grey)),
                                child: Row(
                                  children: [
                                    if (isCheck)
                                      Container(
                                        width: 6.w,
                                        height: 6.w,
                                        margin: EdgeInsets.only(right: 6.w),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3.w),
                                            color: Colors.white),
                                      ),
                                    Text(
                                      tabTitle,
                                      style: TextStyle(
                                          color: isCheck
                                              ? Colors.white
                                              : AppColor.grey),
                                    ),
                                  ],
                                )),
                            onTap: () {
                              IdfaUtil.instance.showIdfaDialog();
                              controller.tabIndex.value = i;
                              controller.tabC?.jumpToPage(i);
                            },
                          );
                        });
                      },
                      separatorBuilder: (_, i) {
                        return SizedBox(
                          width: 16.w,
                        );
                      },
                      itemCount: controller.tabListTitle.length)),

              SizedBox(
                height: 16.w,
              ),
              Expanded(
                  child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: Color(0xfff9f9f9),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.w))),
                child: PageView(controller: controller.tabC, children: [
                  KeepStateView(
                      child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: getTbaListView(1))),
                  KeepStateView(
                      child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: getTbaListView(2))),
                  KeepStateView(
                      child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: getTbaListView(3))),
                ]),
              )),
            ],
          ),
        ),
      ),
    );
  }

  getEmptyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SizedBox(
        //   height: 94.w,
        // ),
        Image.asset(
          "assets/img/icon_empty.png",
          width: 140.w,
          height: 140.w,
        ),
        Text(
          "No content now, Create songs you like",
          style: TextStyle(fontSize: 14.w),
        ),
        SizedBox(height: 32.w),
        InkWell(
          onTap: () {
            controller.showAddDialog();
          },
          child: Container(
            height: 48.w,
            width: 112.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.w),
                color: Colors.white,
                border: Border.all(color: Color(0xff141414), width: 1.w)),
            child: Text(
              "Create",
              style: TextStyle(fontSize: 14.w),
            ),
          ),
        )
      ],
    );
  }

  getTbaListView(int type) {
    if (type == 1) {
      //歌词
      return Container(
        child: Obx(() => controller.list1.isEmpty
            ? getEmptyView()
            : ListView.separated(
                padding: EdgeInsets.only(bottom: 70.w),
                itemBuilder: (_, i) {
                  return getList1Item(i);
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 10.w,
                  );
                },
                itemCount: controller.list1.length)),
      );
    } else if (type == 2) {
      return Container(
        child: Obx(() => controller.list2.isEmpty
            ? getEmptyView()
            : ListView.separated(
                padding: EdgeInsets.only(top: 21.w, bottom: 70.w),
                itemBuilder: (_, i) {
                  return getList2Item(i);
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 8.w,
                  );
                },
                itemCount: controller.list2.length)),
      );
    } else if (type == 3) {
      return Container(
        child: Obx(() => controller.list3.isEmpty
            ? getEmptyView()
            : ListView.separated(
                padding: EdgeInsets.only(
                    top: 21.w, left: 16.w, right: 0, bottom: 70.w),
                itemBuilder: (_, i) {
                  return getList3Item(i);
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 32.w,
                  );
                },
                itemCount: controller.list3.length)),
      );
    }

    return Container();
  }

  getList1Item(int i) {
    var item = controller.list1[i];

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
            // CustomPaint(
            //   painter: IrregularRoundedRectanglePainter(),
            //   size: Size(double.infinity, 100),
            // ),

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
                    Spacer()
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
    var item = controller.list2[i];
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
            .setDataAndPlay({"item": item, "list": controller.list2});
        Get.to(PlayPage());
      },
      child: Obx(() {
        var isCheck =
            Get.find<PlayPageController>().nowData["id"] == item["id"];
        return Container(
          // height: 52.w,
          padding:
              EdgeInsets.only(left: 16.w, right: 0.w, top: 5.w, bottom: 5.w),
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
                    // color: Colors.black,
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

  getList3Item(int i) {
    Map item = controller.list3[i];

    Uint8List? cover = item["cover"];

    var typeIndex = item["type"];

    var isMusic = typeIndex == 1;

    List childList = item["list"] ?? [];

    // var data = {
    //   "id": id,
    //   "title": titleC.text,
    //   "saveTime": DateTime.now(),
    //   "type": typeIndex,
    //   "cover": coverData.value
    // };

    return InkWell(
      onTap: () {
        Get.to(ListInfo(), arguments: item["id"]);
      },
      child: Container(
        height: 56.w,
        width: double.infinity,
        child: Row(
          children: [
            //封面

            Container(
              width: 66.w,
              height: 56.w,
              child: Stack(
                children: [
                  //底部view
                  Align(
                      alignment: Alignment.centerRight,
                      child: isMusic
                          ? Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                  color: Color(0xff191919),
                                  borderRadius: BorderRadius.circular(25.w)))
                          : Container(
                              width: 46.w,
                              height: 46.w,
                              margin: EdgeInsets.only(right: 6.w),
                              decoration: BoxDecoration(
                                  color: Color(0xff141414).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4.w)),
                            )),

                  Container(
                    height: 56.w,
                    width: 56.w,
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(6.w)),
                    child: cover == null
                        ? Image.asset("assets/img/icon_music_cover.png")
                        : Image.memory(
                            cover,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 12.w,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item["title"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.w),
                ),
                SizedBox(
                  height: 12.w,
                ),
                Text(
                  "${childList.length} songs",
                  style: TextStyle(
                      fontSize: 12.w,
                      color: Color(0xff141414).withOpacity(0.75)),
                )
              ],
            )),
            SizedBox(
              width: 35.w,
            ),

            InkWell(
                onTap: () {
                  showMoreListView(item);
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
      ),
    );
  }

  showMoreView(Map item) async {
    IdfaUtil.instance.showIdfaDialog();

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
                        //删除
                        var box = await Hive.openBox(DBKey.tracksData);
                        await box.delete(item["id"]);
                        ToastUtil.showToast(msg: "Delete successfully".tr);
                        controller.bindData();
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
      barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
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
                  var titleList = ["Edit", "Delete"];
                  var iconList = ["more2", "more3"];

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
                        //编辑
                        Get.to(AddList(), arguments: item["id"]);
                      } else if (i == 1) {
                        //删除
                        var box = await Hive.openBox(DBKey.listData);
                        await box.delete(item["id"]);
                        ToastUtil.showToast(msg: "Delete successfully".tr);
                        controller.bindData();
                      }
                    },
                  );
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 16.w,
                  );
                },
                itemCount: 2),
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
      barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
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
                                ToastUtil.showToast(msg: "Enter name".tr);
                                return;
                              }
                              //保存信息
                              var box = await Hive.openBox(DBKey.tracksData);

                              var id = item["id"];
                              var data = Map.of(item);
                              data["title"] = inputC.text;
                              await box.put(id, data);
                              //刷新首页数据
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
}

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var tabListTitle = ["Lyrics", "Tracks", "List"];
  var tabIndex = 0.obs;

  PageController? tabC;

  var list1 = [].obs;
  var list2 = [].obs;
  var list3 = [].obs;

  @override
  void onInit() {
    super.onInit();
    // tabC = TabController(length: 3, vsync: this);
    //
    // tabC?.addListener(() {
    //   tabIndex.value = tabC?.index ?? 0;
    // });
    tabC = PageController();
    tabC?.addListener(() {
      tabIndex.value = (tabC?.page ?? 0).round();
    });

    bindData();
  }

  bindData() async {
    var box1 = await Hive.openBox(DBKey.lyricsData);
    list1.value = box1.values.toList();

    var box2 = await Hive.openBox(DBKey.tracksData);
    list2.value = box2.values.toList();

    var box3 = await Hive.openBox(DBKey.listData);
    list3.value = box3.values.toList();
  }

  void showAddDialog() async {
    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(left: 24.w, top: 30.w, right: 24.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xffEAE8F9), Color(0xfffafafa)])),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "Please Selected",
                  style: TextStyle(fontSize: 20.w),
                ),
                Spacer(),
                InkWell(
                  child: Icon(
                    Icons.close,
                    size: 24.w,
                  ),
                  onTap: () {
                    Get.back();
                  },
                )

                // IconButton(
                //     onPressed: () {
                //       Get.back();
                //     },
                //     icon: Icon(Icons.close))
              ],
            ),
            SizedBox(
              height: 24.w,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  return InkWell(
                    child: Container(
                        height: 68.w,
                        padding: EdgeInsets.only(left: 32.w, right: 20.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                width: 1.w,
                                color: Color(0xff1f1f1f).withOpacity(0.08)),
                            borderRadius: BorderRadius.circular(12.w)),
                        child: Stack(
                          children: [
                            Positioned.fill(
                                child: Row(
                              children: [
                                Image.asset(
                                  "assets/img/icon_s_${i + 1}.png",
                                  width: 42.w,
                                  height: 42.w,
                                ),
                                // Spacer(),
                                // Text(
                                //   tabListTitle[i],
                                //   style: TextStyle(fontSize: 16.w),
                                // ),
                                Spacer(),
                                Image.asset(
                                  "assets/img/icon_s_right.png",
                                  width: 24.w,
                                  height: 24.w,
                                ),
                              ],
                            )),
                            Center(
                              child: Text(
                                tabListTitle[i],
                                style: TextStyle(fontSize: 16.w),
                              ),
                            )
                          ],
                        )),
                    onTap: () async {
                      Get.back();
                      if (i == 0) {
                        Get.to(AddLyrics());
                      } else if (i == 1) {
                        // Get.to(AddMusic());
                        await Future.delayed(Duration(milliseconds: 400));
                        showAddTrackDialog();
                      } else if (i == 2) {
                        Get.to(AddList());
                      }
                    },
                  );
                },
                separatorBuilder: (_, i) {
                  return SizedBox(
                    height: 20.w,
                  );
                },
                itemCount: tabListTitle.length),
            SizedBox(
              height: Get.mediaQuery.padding.bottom + 20.w,
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

  void showAddTrackDialog() async {
    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(left: 24.w, top: 24.w, right: 12.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffEAE8F9), Color(0xfffafafa)])),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "Please Selected",
                  style: TextStyle(fontSize: 20.w),
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close))
              ],
            ),
            SizedBox(
              height: 24.w,
            ),
            //录音或上传
            GridView.count(
              childAspectRatio: 166 / 86,
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 11.w,
              physics: NeverScrollableScrollPhysics(),
              children: [0, 1].map((e) {
                var iconList = ["record", "upload"];
                var titleList = ["Record", "Upload"];

                return InkWell(
                  onTap: () {
                    Get.back();

                    if (e == 0) {
                      //添加歌词和录音
                      Get.to(AddLyrics());
                    } else if (e == 1) {
                      //添加mp3歌曲
                      pickMp3();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.w),
                        border: Border.all(
                            color: Color(0xff1f1f1f).withOpacity(0.08))),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(
                        //   Icons.home,
                        //   size: 24.w,
                        // ),
                        Image.asset(
                          "assets/img/icon_${iconList[e]}.png",
                          width: 24.w,
                          height: 24.w,
                        ),

                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          titleList[e],
                          style: TextStyle(fontSize: 16.w),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(
              height: Get.mediaQuery.padding.bottom + 20.w,
            )
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
//关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }

  void pickMp3() async {
    // FilePickerResult? result = await FilePicker.platform
    //     .pickFiles(type: FileType.custom, allowedExtensions: ["mp3"]);

    //33以下版本请求权限
    //文件权限
    if (GetPlatform.isAndroid) {
      var lastStatus = await Permission.storage.status;
      if (lastStatus.isPermanentlyDenied) {
        //永久拒绝后
        AppSettings.openAppSettings();
        return;
      }
      var thisStatus = await Permission.storage.request();
      if (thisStatus.isDenied) {
        return;
      }
    } else {
      //ios权限
      // var lastStatus = await Permission.photos.status;
      // AppLog.e(lastStatus);
      // if (lastStatus.isPermanentlyDenied) {
      //   //永久拒绝后
      //   AppSettings.openAppSettings();
      //   return;
      // }
      // var thisStatus = await Permission.photos.request();
      // if (thisStatus.isDenied) {
      //   return;
      // }
    }

    try {
      //记录音乐播放状态
      var lastState = Get.find<PlayPageController>().player.state;
      Duration? lastP =
          await Get.find<PlayPageController>().player.getCurrentPosition();
      //停止音乐
      if (lastState == PlayerState.playing || lastState == PlayerState.paused) {
        Get.find<PlayPageController>().player.stop();
      }

      // FilePickerResult? result = await FilePicker.platform
      //     .pickFiles(type: FileType.audio, withData: true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          withData: true,
          allowedExtensions: ["mp3", "wav", "aac", "ogg"]);

      //恢复音乐
      try {
        Get.find<PlayPageController>()
            .playMusic(Get.find<PlayPageController>().nowIndex);
        if (lastP != null) {
          Get.find<PlayPageController>().player.seek(lastP);
        }
        if (lastState == PlayerState.playing) {
          Get.find<PlayPageController>().player.resume();
        } else {
          Get.find<PlayPageController>().player.pause();
        }
      } catch (e) {
        AppLog.e(e);
      }

      if (result == null) {
        return;
      }

      var file = result.files.single;

      final metadata = await MetadataRetriever.fromFile(File(file.path!));
      String? trackName = metadata.trackName;
      // List<String>? trackArtistNames = metadata.trackArtistNames;
      // String? albumName = metadata.albumName;
      // String? albumArtistName = metadata.albumArtistName;
      // int? trackNumber = metadata.trackNumber;
      // int? albumLength = metadata.albumLength;
      // int? year = metadata.year;
      // String? genre = metadata.genre;
      // String? authorName = metadata.authorName;
      // String? writerName = metadata.writerName;
      // int? discNumber = metadata.discNumber;
      // String? mimeType = metadata.mimeType;
      // int? trackDuration = metadata.trackDuration;
      // int? bitrate = metadata.bitrate;
      Uint8List? albumArt = metadata.albumArt;
      AppLog.e(metadata);

      //添加歌曲
      var box = await Hive.openBox(DBKey.tracksData);
      var id = Uuid().v8();

      //名字
      var musicName = "";
      if (trackName?.isEmpty ?? true) {
        musicName = file.name;
      } else {
        musicName = trackName!;
      }

      var itemData = {
        "id": id,
        "saveTime": DateTime.now(),
        "title": musicName,
        "cover": albumArt,
        "fileData": file.bytes,
      };

      AppLog.e(itemData["id"]);
      AppLog.e(file.bytes?.length ?? "null");
      await box.put(id, itemData);

      ToastUtil.showToast(msg: "Upload successfully".tr);
      //刷新数据
      bindData();
    } catch (e) {
      AppLog.e(e);
    }
  }
}
