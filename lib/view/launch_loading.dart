import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_muse/const/bus.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/page/main/home/play.dart';
import 'package:music_muse/u_page/main/home/u_play.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/log.dart';

class LaunchLoadingPage extends GetView<LaunchLoadingPageController> {
  const LaunchLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    bus.isLaunchLoadingAdShowing = true;
    Get.lazyPut(() => LaunchLoadingPageController());
    return Scaffold(
      body: SizedBox(
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
                  MuseConfig.appName,
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

class LaunchLoadingPageController extends GetxController {
  var progress = 0.0.obs;
  Timer? _timer;
  Timer? _timer2;

  @override
  void onInit() {
    super.onInit();
    bus.isLaunchLoadingAdShowing = true;
    // if (Get.isRegistered<UserPlayInfoController>()) {
    //   Get.find<UserPlayInfoController>().hideFloatingWidget();
    // }
    // if (Get.isRegistered<PlayPageController>()) {
    //   Get.find<PlayPageController>().hideFloatingWidget();
    // }
    DateTime startDate = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      int diff = (DateTime.now().difference(startDate)).inMilliseconds;
      progress.value = diff / (10 * 1000);
      if (DateTime.now().difference(startDate).inSeconds >= 10) {
        _closePage();
      }
    });

    _timer2 = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!AdUtils.instance.adIsShowing) {
        AdUtils.instance.showAd("open",
            adScene: AdScene.openHot,
            onShow: ShowCallback(onShowFail: (adId, e) {
              AppLog.e("onShowFail currentRoute:${Get.currentRoute}");
              // _closePage();
            }, onShow: (adId) {
              _closePage();
            }, onClose: (adId) {
              _closePage();
            }));
      }
    });
  }

  _closePage() {
    progress.value = 1;
    _timer?.cancel();
    _timer = null;
    _timer2?.cancel();
    _timer2 = null;
    // if (bus.isLaunchLoadingAdShowing) {
    //   Get.back();
    // }
    Navigator.of(Get.context!).popUntil((route) {
      return route.settings.name != "LaunchLoad"; // 只保留非 LaunchLoad
    });

    bus.isLaunchLoadingAdShowing = false;
  }

  @override
  void onClose() {
    bus.isLaunchLoadingAdShowing = false;
    // final previous = Get.currentRoute;
    // if (!previous.contains("BOTTOMSHEET")) {
    //   Future.delayed(const Duration(seconds: 1)).then((v) {
    //     if (Get.isRegistered<UserPlayInfoController>()) {
    //       Get.find<UserPlayInfoController>().showFloatingWidget();
    //     }
    //     if (Get.isRegistered<PlayPageController>()) {
    //       Get.find<PlayPageController>().showFloatingWidget();
    //     }
    //   });
    // }
    super.onClose();
  }
}
