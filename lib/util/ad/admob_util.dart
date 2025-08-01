import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../log.dart';
import '../tba/tba_util.dart';

class AdmobUtils {
  AdmobUtils._internal();

  static final AdmobUtils _instance = AdmobUtils._internal();

  static AdmobUtils get instance {
    return _instance;
  }

  Future init() async {
    await MobileAds.instance.initialize();

    await MobileAds.instance.setAppMuted(true);
    //IDFA或gaid
    // await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    //     testDeviceIds: [""]));

    //Google UMP
    // ConsentInformation.instance.requestConsentInfoUpdate(
    //     ConsentRequestParameters(
    //         consentDebugSettings: ConsentDebugSettings(testIdentifiers: [])),
    //     () async {
    //   AppLog.e("UMP request success");
    //   AppLog.e(await ConsentInformation.instance.isConsentFormAvailable());
    //   if (await ConsentInformation.instance.isConsentFormAvailable()) {
    //     loadForm();
    //   }
    // }, (error) {
    //   AppLog.e("UMP request error");
    //   AppLog.e(error.message);
    // });
  }

  Future<Ad?> loadNativeAd(
      String adId, String key, String positionKey, Rx<Widget> adView) async {
    Widget view = Container();
    Completer<Ad?> completer = Completer();

    view = Container(
        constraints: const BoxConstraints(
            minWidth: 0, minHeight: 0, maxHeight: 320, maxWidth: 320),
        child: AdWidget(
            ad: NativeAd(
                nativeTemplateStyle:
                    NativeTemplateStyle(templateType: TemplateType.medium),
                adUnitId: adId,
                listener: NativeAdListener(onAdLoaded: (ad) {
                  AppLog.e("admob native加载成功");

                  adView.value = view;

                  completer.complete(ad);
                }, onAdFailedToLoad: (ad, e) {
                  AppLog.e("admob native加载失败");
                  AppLog.e(e);
                  ad.dispose();
                  completer.complete(null);
                }, onPaidEvent: (Ad ad, double valueMicros,
                    PrecisionType precision, String currencyCode) {
                  TbaUtils.instance.postAd(
                      // ad_network: ad.responseInfo?.mediationAdapterClassName ?? "",
                      ad_network: ad.responseInfo?.loadedAdapterResponseInfo
                              ?.adSourceName ??
                          "",
                      ad_pos_id: positionKey,
                      ad_source: "admob",
                      ad_unit_id: ad.adUnitId,
                      ad_format: "native",
                      ad_pre_ecpm: valueMicros.toString(),
                      currency: currencyCode,
                      precision_type: precision.name);
                }),
                request: const AdRequest())
              ..load()));

    return completer.future;
  }
}
