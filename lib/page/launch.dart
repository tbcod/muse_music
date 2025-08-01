import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_muse/const/env.dart';
import 'package:music_muse/page/main_page.dart';
import 'package:music_muse/u_page/u_main.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/idfa_util.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/c_util.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchPage extends GetView<LaunchPageController> {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LaunchPageController());
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: 146.w,
              width: double.infinity,
              decoration: const BoxDecoration(
                  // color: Colors.red,
                  image: DecorationImage(
                image: AssetImage("assets/img/all_appbar_bg.png"),
                fit: BoxFit.fill,
              )),
            ),
            Positioned.fill(
                child: Column(
              children: [
                SizedBox(
                  height: Get.mediaQuery.padding.top,
                ),
                SizedBox(
                  height: 150.w,
                ),
                Image.asset(
                  "assets/img/icon_launcher.png",
                  fit: BoxFit.cover,
                  width: 56.w,
                  height: 56.w,
                ),
                SizedBox(
                  height: 8.w,
                ),
                Text(
                  Env.appName,
                  style: TextStyle(fontSize: 16.w),
                ),

                const Spacer(),
                //进度条

                Text(
                  "Resource loading…".tr,
                  style: TextStyle(color: Colors.black, fontSize: 14.w),
                ),

                SizedBox(
                  height: 16.w,
                ),
                Container(
                  width: 200.w,
                  height: 4.w,
                  child: Obx(() => LinearProgressIndicator(
                        value: controller.progress.value,
                        minHeight: 4.w,
                        borderRadius: BorderRadius.circular(2.w),
                        color: Colors.black,
                        backgroundColor: Colors.black.withOpacity(0.2),
                      )),
                ),

                SizedBox(
                  height: 100.w,
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class LaunchPageController extends GetxController {
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // IdfaUtil.instance.showIdfaDialog();
    bindData();
  }

  var isB = false;
  bindData() async {
    EventUtils.instance.addEvent("open_click");

    var sp = await SharedPreferences.getInstance();

    var isOpenUser = sp.getBool("isOpenUser") ?? false;
    if (isOpenUser) {
      //已经是用户模式，不用再请求
      isB = true;
      return;
    }

    var tempTime = DateTime.now();
    var result = await CUtil.instance.checkCloak();

    var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
    EventUtils.instance.addEvent("cloak_get", data: {"time": doTime});
    //命中黑名单：sardonic
    //正常模式：excerpt
    var okStr = GetPlatform.isIOS ? "excerpt" : "";

    if (result.data == okStr) {
      //缓存
      await sp.setBool("isOpenUser", true);
      isB = true;
    } else {
      isB = false;
    }
  }

  @override
  void onReady() async {
    super.onReady();

    loadAd();
    await countdown();
  }

  loadAd() async {
    AppLog.e("启动页加载广告");
    isAdShow = false;

    //判断第一次是否加载
    var sp = await SharedPreferences.getInstance();
    var isFirstLoadAd = sp.getBool("isFirstLoadAd") ?? true;

    var openAdStr =
        FirebaseRemoteConfig.instance.getString("musicmuse_open_ad");

    if (openAdStr.isEmpty) {
      //默认为close,
      openAdStr = "close";
    }

    if (isFirstLoadAd && openAdStr == "close") {
      AppLog.e("第一次不加载广告");
      sp.setBool("isFirstLoadAd", false);
      return;
    }
    AppLog.e("不是第一次启动或者开关打开了，即将加载广告");
    sp.setBool("isFirstLoadAd", false);

    AdUtils.instance.loadAd("open", onLoad: (adId, isOk, e) {
      AppLog.e("启动页加载广告结果$isOk");
      AppLog.e("$adId");
      AppLog.e("${e}");

      if (isOk) {
        if (isAdShow) {
          AppLog.e("已经显示过广告");
          return;
        }
        if (isToMain) {
          AppLog.e("已经跳转到首页");
          return;
        }

        //显示广告
        AdUtils.instance.showAd("open",
            onShow: ShowCallback(onShowFail: (adId, e) {
              toMainPage();
            }, onClose: (adId) {
              toMainPage();
            }, onShow: (adId) {
              isAdShow = true;
            }));
      }
    });
  }

  Future countdown() async {
    //倒计时7秒加载进度条

    int seconds = AdUtils.instance.adJson["timeout"] ?? 7;

    // seconds = seconds * 1000;
    for (int i = 0; i < seconds * 100; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      progress.value += 1 / seconds / 100;
    }

    if (!isAdShow) {
      //没有显示广告时才跳转
      toMainPage();
    }

    return true;
  }

  var isAdShow = false;
  var isToMain = false;
  toMainPage() async {
    if (!isToMain && !isClosed) {
      isToMain = true;
      progress.value = 1;

      if (!Env.isUser) {
        EventUtils.instance.addEvent("enter_home");
        EventUtils.instance.addEvent("home_source");
        Get.off(const UserMain());
        return;
      }

      var sp = await SharedPreferences.getInstance();

      var isOpenUser = sp.getBool("isOpenUser") ?? false;

      if (isOpenUser) {
        EventUtils.instance.addEvent("enter_home");
        EventUtils.instance.addEvent("home_source");
        Get.off(const UserMain());
        return;
      }
      EventUtils.instance.addEvent("enter_home");
      EventUtils.instance.addEvent("home_no");

      Get.off(isOpenUser ? const UserMain() : const MainPage());
    }
  }
}
