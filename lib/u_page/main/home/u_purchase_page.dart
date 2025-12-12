import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_muse/generated/assets.dart';

import 'u_purchase_controller.dart';

class UPurchasePage extends StatelessWidget {
  UPurchasePage({super.key});

  final UPurchasePageController controller = Get.put(UPurchasePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: ScreenUtil().screenHeight,
        child: Stack(
          children: [
            Image.asset(Assets.iapIpBg1, width: ScreenUtil().screenWidth),
            Positioned(
              top: 170.h,
              left: 0,
              right: 0,
              child: Image.asset(
                Assets.iapIpBg2,
                width: ScreenUtil().screenWidth,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: ScreenUtil().statusBarHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: ScreenUtil().screenWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(Assets.iapIpClose, width: 24),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white.withOpacity(0.5))),
                              child: const Text(
                                "Restore",
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              )),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  _textSection(context),
                  _priceSection(context),
                  Expanded(child: _bottomView(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textSection(BuildContext context) {
    List texts = ["Unlimited Downloads", "Ad-Free", "Watch Youtube video offline", "Play music background"];
    return Container(
      margin: const EdgeInsets.only(left: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(Assets.iapIpText, width: 188, height: 52),
          const SizedBox(height: 16),
          ...texts.map((text) {
            return Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                children: [
                  Image.asset(Assets.iapIpSure, width: 20),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _priceSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 40),
      child: Obx(() {
        return Column(
          children: List.generate(controller.products.length, (index) {
            Map map = controller.products[index];
            return _priceItem(index, map["name"], map["price"], detail: map["detail"]);
          }),
        );
      }),
    );
  }

  Widget _priceItem(int index, String title, double price, {String? detail}) {
    return Obx(() {
      int curIndex = controller.curPlanIndex.value;
      return GestureDetector(
        onTap: () => controller.onClickPrice(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          margin: EdgeInsets.only(top: 22.h, bottom: 0),
          height: (ScreenUtil().screenWidth - 40) / 5,
          width: ScreenUtil().screenWidth - 40,
          decoration: curIndex == index
              ? const BoxDecoration(image: DecorationImage(image: AssetImage(Assets.iapIpPriceBg2), fit: BoxFit.fill))
              : const BoxDecoration(image: DecorationImage(image: AssetImage(Assets.iapIpPriceBg1), fit: BoxFit.fill)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(curIndex == index ? Assets.iapIpSelected : Assets.iapIpSelect, width: 20),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xff272727)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${controller.currencySymbol}$price",
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Color(0xff272727)),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              if (detail != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 26,
                        color: const Color(0xffc1b2ff).withOpacity(0.35),
                        child: Text(
                          "${controller.currencySymbol}" " ${(price / 52).toStringAsFixed(2)}/${"week".tr.toLowerCase()}",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: -0.2, color: Color(0xff141414)),
                        ))),
            ],
          ),
        ),
      );
    });
  }

  Widget _bottomView(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      // height: 80.h + max(ScreenUtil().bottomBarHeight, 20),
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.only(bottom: 20.h + max(ScreenUtil().bottomBarHeight, 20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'autoRenewal'.trParams({"price": "1"}),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff1a1a1a)),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => controller.onClickPay(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.center,
              height: 48.h,
              decoration: BoxDecoration(color: const Color(0xff7453ff), borderRadius: BorderRadius.circular(24)),
              child: Text(
                'continue'.tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => controller.onClickTermsService(),
                child: Text(
                  "·${"Terms of Service".tr}",
                  style: const TextStyle(color: Color(0xff1a1a1a), fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: () => controller.onClickPrivacyPolicy(),
                child: Text(
                  "·${"Privacy Policy".tr}",
                  style: const TextStyle(color: Color(0xff1a1a1a), fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
