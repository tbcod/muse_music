import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_muse/page/main/home.dart';
import 'package:music_muse/page/main/home/play.dart';
import 'package:music_muse/page/main/setting.dart';
import 'package:music_muse/u_page/u_main.dart';
import 'package:music_muse/util/keep_view.dart';
import 'package:music_muse/util/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/ad/ad_util.dart';
import '../util/idfa_util.dart';
import '../util/tba/c_util.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MainPageController());
    return WillPopScope(
      onWillPop: () async {
        if (GetPlatform.isIOS) {
          return true;
        }

        // 返回桌面逻辑
        AppLog.e("back");
        AndroidIntent intent =
            const AndroidIntent(action: 'android.intent.action.MAIN', category: "android.intent.category.HOME", flags: [Flag.FLAG_ACTIVITY_NEW_TASK]);
        intent.launch();
        AppLog.e("back1");

        // await SystemNavigator.pop();

        return false;
      },
      child: Scaffold(
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
              currentIndex: controller.nowIndex.value,
              backgroundColor: Colors.white,
              onTap: (index) {
                IdfaUtil.instance.showIdfaDialog();
                controller.nowIndex.value = index;
                controller.pageC.jumpToPage(index);
              },
              unselectedItemColor: const Color(0xffC4C5D5),
              selectedItemColor: const Color(0xff141414),
              selectedLabelStyle: TextStyle(color: const Color(0xff141414), fontSize: 12.w),
              unselectedLabelStyle: TextStyle(color: const Color(0xffC4C5D5), fontSize: 12.w),
              items: [
                BottomNavigationBarItem(
                    icon: Image.asset(
                      "assets/img/icon_b_1_off.png",
                      width: 24.w,
                      height: 24.w,
                    ),
                    activeIcon: Image.asset(
                      "assets/img/icon_b_1.png",
                      width: 24.w,
                      height: 24.w,
                    ),
                    label: "Home"),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      "assets/img/icon_b_2_off.png",
                      width: 24.w,
                      height: 24.w,
                    ),
                    activeIcon: Image.asset(
                      "assets/img/icon_b_2.png",
                      width: 24.w,
                      height: 24.w,
                    ),
                    label: "Setting"),
              ]);
        }),
        body: PageView(
          controller: controller.pageC,
          physics: const NeverScrollableScrollPhysics(),
          children: const [KeepStateView(child: HomePage()), KeepStateView(child: SettingPage())],
        ),
      ),
    );
  }
}

class MainPageController extends GetxController {
  var pageC = PageController();
  var nowIndex = 0.obs;

  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void onInit() {
    super.onInit();
    Get.put(PlayPageController());

    //预加载广告
    AdUtils.instance.loadAd('level_h');
    AdUtils.instance.loadAd("behavior");

    // Future.delayed(Duration(seconds: 5)).then((_) => Get.off(const UserMain()));

    //设置网络监听，成功后打开B面
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      var result = await CUtil.instance.checkCloak();

      //监听到网络变化重新请求一次
      var okStr = GetPlatform.isIOS ? "excerpt" : "";

      if (result.data == okStr) {
        //缓存
        var sp = await SharedPreferences.getInstance();
        await sp.setBool("isOpenUser", true);
        Get.off(const UserMain());
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    subscription?.cancel();

    //关闭播放页面
    if (Get.isRegistered<PlayPageController>()) {
      Get.find<PlayPageController>().onClose();
      Get.delete<PlayPageController>();
    }
  }
}
