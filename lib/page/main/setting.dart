import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/const/env.dart';
import 'package:music_muse/page/main/setting/feedback.dart';
import 'package:music_muse/page/main/setting/only_web.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/log.dart';

import '../../view/base_dialog.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SettingPageController());
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("标题"),
      // ),
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
                  centerTitle: false,
                  titleSpacing: 12.w,
                  title: Text("Setting"),
                ),
                Expanded(
                    child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView.separated(
                      itemBuilder: (_, i) {
                        return getItem(i);
                      },
                      separatorBuilder: (_, i) {
                        return SizedBox(
                          height: 1,
                        );
                      },
                      itemCount: controller.listTitle.length),
                ))
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget getItem(int i) {
    var itemTitle = controller.listTitle[i];
    return InkWell(
      child: Container(
        height: 56.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Text(
              controller.listTitle[i],
              style: TextStyle(fontSize: 14.w),
            ),
            Spacer(),
            Image.asset(
              "assets/img/icon_right.png",
              width: 24.w,
              height: 24.w,
            )
          ],
        ),
      ),
      onTap: () {
        if (itemTitle == "Feedback") {
          //反馈
          Get.to(FeedbackPage());
        } else if (itemTitle == "Privacy Policy") {
          Get.to(OnlyWeb(), arguments: 2);
        } else if (itemTitle == "Terms of Service") {
          Get.to(OnlyWeb(), arguments: 1);
        } else if (itemTitle == "Ad Tools") {
          AppLog.e(AdUtils.instance.loadedAdMap);
          AppLog.e(AdUtils.instance.adJson);

          Get.dialog(
              BaseDialog(
                title: "Tip",
                content: "choose",
                lBtnText: "Max",
                rBtnText: "Admob",
                lBtnOnTap: () {
                  Get.back();
                  AppLovinMAX.showMediationDebugger();
                },
                rBtnOnTap: () {
                  Get.back();
                  MobileAds.instance.openAdInspector((p0) {
                    // ToastUtil.showToast(msg: p0?.message ?? "error");
                  });
                },
              ),
              barrierDismissible: true);
        }
      },
    );
  }
}

class SettingPageController extends GetxController {
  var listTitle = ["Privacy Policy", "Terms of Service", "Feedback"];

  @override
  void onInit() {
    super.onInit();
    if (!Env.isUser) {
      listTitle.add("Ad Tools");
    }
  }
}
