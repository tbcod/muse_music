import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../log.dart';
import '../tba/tba_util.dart';

class MaxUtils {
  MaxUtils._internal();

  static final MaxUtils _instance = MaxUtils._internal();

  static MaxUtils get instance {
    return _instance;
  }

  Future init() async {
    //TODO 注意切换正式的app key;
    MaxConfiguration? sdkConfiguration = await AppLovinMAX.initialize(
        "POzCPzJAQ_vi7vlPr0v6dpTw1giLvT2HKZcyQJ27U_0hDMdIeOgvScokaDvmqrXg8AogImcyxb9QMKF5TXSf8U");
    AppLovinMAX.setMuted(true);
    AppLog.e(sdkConfiguration?.toString());

    //IDFA或gaid
    // AppLovinMAX.setTestDeviceAdvertisingIds([""]);
  }

  Future<bool> loadNativeAd(
      String adId, String positionKey, Rx<Widget> adView) async {
    Completer<bool> completer = Completer();
    MaxNativeAdViewController nativeAdViewController =
        MaxNativeAdViewController();

    var view = Container();

    var adLoaded = false.obs;

    view = Container(
      child: Obx(() => Visibility(
          visible: adLoaded.value,
          maintainState: true,
          child: Stack(
            children: [
              Container(
                child: MaxNativeAdView(
                  adUnitId: adId,
                  controller: nativeAdViewController,
                  listener: NativeAdListener(
                      onAdLoadedCallback: (ad) {
                        AppLog.e("max native加载成功");
                        adLoaded.value = true;
                        completer.complete(true);
                      },
                      onAdLoadFailedCallback: (adUnitId, error) {
                        AppLog.e("max原生加载失败");
                        AppLog.e(error);
                        completer.complete(false);
                      },
                      onAdClickedCallback: (ad) {},
                      onAdRevenuePaidCallback: (ad) {
                        TbaUtils.instance.postAd(
                            ad_network: ad.networkName,
                            ad_pos_id: positionKey,
                            ad_source: "max",
                            ad_unit_id: ad.adUnitId,
                            ad_format: "native",
                            ad_pre_ecpm: ad.revenue.toString(),
                            currency: "",
                            precision_type: ad.revenuePrecision);
                      }),
                  child: Container(
                    color: const Color(0xff141414).withOpacity(0.5),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(child: MaxNativeAdMediaView())),
                        Container(
                          height: 60,
                          child: Row(
                            children: [
                              MaxNativeAdIconView(
                                width: 36,
                                height: 36,
                              ),
                              Expanded(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MaxNativeAdTitleView(
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                  ),
                                  MaxNativeAdAdvertiserView(
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              )),
                              MaxNativeAdCallToActionView(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Color(0xff985CFF)),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  textStyle: MaterialStatePropertyAll(TextStyle(
                                      // color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),

                    // child: Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Container(
                    //           padding: const EdgeInsets.all(4.0),
                    //           child: const MaxNativeAdIconView(
                    //             width: 48,
                    //             height: 48,
                    //           ),
                    //         ),
                    //         Flexible(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               MaxNativeAdTitleView(
                    //                 style: TextStyle(
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 16),
                    //                 maxLines: 1,
                    //                 overflow: TextOverflow.visible,
                    //               ),
                    //               MaxNativeAdAdvertiserView(
                    //                 style: TextStyle(
                    //                     fontWeight: FontWeight.normal,
                    //                     fontSize: 10),
                    //                 maxLines: 1,
                    //                 overflow: TextOverflow.fade,
                    //               ),
                    //               MaxNativeAdStarRatingView(
                    //                 size: 10,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         const MaxNativeAdOptionsView(
                    //           width: 20,
                    //           height: 20,
                    //         ),
                    //       ],
                    //     ),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Flexible(
                    //           child: MaxNativeAdBodyView(
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.normal, fontSize: 14),
                    //             maxLines: 3,
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     const SizedBox(height: 8),
                    //     Expanded(
                    //       child: AspectRatio(
                    //         aspectRatio: adSize.height / adSize.width,
                    //         child: const MaxNativeAdMediaView(),
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: double.infinity,
                    //       child: MaxNativeAdCallToActionView(
                    //         style: ButtonStyle(
                    //           backgroundColor:
                    //               MaterialStatePropertyAll(Color(0xff2d545e)),
                    //           foregroundColor:
                    //               MaterialStatePropertyAll(Colors.white),
                    //           textStyle: MaterialStatePropertyAll(TextStyle(
                    //               // color: Colors.white,
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold)),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
              ),
              //关闭按钮
              // Positioned(
              //   right: 0,
              //   top: 0,
              //   child: InkWell(
              //     onTap: () {
              //       isShow.value = false;
              //     },
              //     child: Container(
              //         padding: EdgeInsets.all(4),
              //         child: Image.asset(
              //           "assets/img/uimg/icon_ad_hide.png",
              //           width: 24,
              //           height: 24,
              //         )),
              //   ),
              // )
            ],
          ))),
    );

    nativeAdViewController.loadAd();
    adView.value = view;
    return completer.future;
  }
}
