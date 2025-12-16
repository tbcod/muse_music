import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/const/env.dart';
import 'package:music_muse/generated/assets.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/page/main/setting/feedback.dart';
import 'package:music_muse/page/main/setting/only_web.dart';
import 'package:music_muse/u_page/main/home/u_purchase_controller.dart';
import 'package:music_muse/u_page/main/home/u_purchase_page.dart';
import 'package:music_muse/u_page/main/u_debug_page.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/ad/consent_request.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/native_util.dart';
import 'package:music_muse/util/toast.dart';
import 'package:music_muse/util/vip_utils.dart';

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
                AppBar(
                  centerTitle: false,
                  titleSpacing: 12.w,
                  title: const Text("Setting"),
                  actions: [
                    GestureDetector(
                        onDoubleTap: () {
                          controller._clickCount++;
                          if (controller._clickCount > 5) {
                            controller._clickCount = 0;
                            Get.to(() => UDebugPage());
                          }
                        },
                        child: Container(
                          color: MuseConfig.isUser ? Colors.transparent : Colors.white30,
                          width: 100,
                          height: 44,
                        )),
                    Obx(() {
                      if (!VipUtil.instance.isVip) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => UPurchasePage(), arguments: PurchasePageFrom.home.name);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Image.asset(Assets.oimgIpaPro, width: 56, height: 26),
                          ),
                        );
                      }
                      return Container();
                    }),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    NativeUtils.instance.gbToH5Page();
                  },
                  child: Image.asset(Assets.oimgSetH5, width: ScreenUtil().screenWidth - 16, fit: BoxFit.fitWidth),
                ),
                Expanded(
                    child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        return getItem(i);
                      },
                      separatorBuilder: (_, i) {
                        return const SizedBox(
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
            const Spacer(),
            Image.asset(
              "assets/img/icon_right.png",
              width: 24.w,
              height: 24.w,
            )
          ],
        ),
      ),
      onTap: () {
        if (itemTitle == "Feedback".tr) {
          //反馈
          Get.to(const FeedbackPage());
        } else if (itemTitle == "Privacy Policy".tr) {
          Get.to(const OnlyWeb(), arguments: 2);
        } else if (itemTitle == "Terms of Service".tr) {
          Get.to(const OnlyWeb(), arguments: 1);
        }else if (itemTitle == "pops".tr) {
          Get.dialog(BaseDialog(
            title: "pops".tr,
            content: "popDetail".tr,
            rBtnText: "reset".tr,
            lBtnText: "Cancel".tr,
            rBtnOnTap: () async {
              ConsentRequest.instance.reset();
              Get.back();
              ToastUtil.showToast(msg: "success".tr);
            },
          ));
        }
        // else if (itemTitle == "Ad Tools") {
        //   AppLog.e(AdUtils.instance.loadedAdMap);
        //   AppLog.e(AdUtils.instance.adJson);
        //
        //   Get.dialog(
        //       BaseDialog(
        //         title: "Tip",
        //         content: "choose",
        //         lBtnText: "Max",
        //         rBtnText: "Admob",
        //         lBtnOnTap: () {
        //           Get.back();
        //           AppLovinMAX.showMediationDebugger();
        //         },
        //         rBtnOnTap: () {
        //           Get.back();
        //           MobileAds.instance.openAdInspector((p0) {
        //             // ToastUtil.showToast(msg: p0?.message ?? "error");
        //           });
        //         },
        //       ),
        //       barrierDismissible: true);
        // }
      },
    );
  }
}

class SettingPageController extends GetxController {
  var listTitle = ["Privacy Policy".tr, "Terms of Service".tr, "Feedback".tr, "pops".tr];
  int _clickCount = 0;

  // @override
  // void onInit() {
  //   super.onInit();
  //   if (!MuseConfig.isUser) {
  //     listTitle.add("Ad Tools");
  //   }
  // }
}
