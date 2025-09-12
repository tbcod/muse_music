import 'dart:convert';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/ad/admob_util.dart';
import 'package:music_muse/util/log.dart';

class UDebugPage extends StatelessWidget {
  UDebugPage({super.key});

  final UDebugController controller = Get.put(UDebugController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Debug".tr,
          style: TextStyle(fontSize: 20.w),
        ),
        titleSpacing: 12.w,
      ),
      body: Container(
        height: ScreenUtil().screenHeight,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                    onPressed: () {
                      MobileAds.instance.openAdInspector((value) {});
                    },
                    child: const Text('Admob')),
                const SizedBox(height: 12),
                CupertinoButton(
                    onPressed: () {
                      AppLovinMAX.showMediationDebugger();
                    },
                    child: const Text('ApplovinMax')),
              ],
            ),
            const SizedBox(height: 12),
            Text('${controller.getAd(AdUtils.instance.adJson)}'),
          ],
        ),
      ),
    );
  }
}

class UDebugController extends GetxController {
  getAd(Map user) {
    var encoder = const JsonEncoder.withIndent("  "); // 两个空格缩进
    String prettyJson = encoder.convert(user);
return prettyJson;
    // String formatted = user.entries.map((e) => "${e.key}: ${e.value}").join("\n");
    // return formatted;
  }
}
