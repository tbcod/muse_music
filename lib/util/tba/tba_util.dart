import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:music_muse/app.dart';
import 'package:music_muse/util/tba/tba_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/base_api.dart';
import '../log.dart';

class TbaUtils {
  TbaUtils._internal();
  static final TbaUtils _instance = TbaUtils._internal();
  static TbaUtils get instance {
    return _instance;
  }

  Future<BaseModel> postEvent(String id, Map<String, dynamic>? data) async {
    if (GetPlatform.isIOS) {
      return await TbaIos.instance
          .postData(TbaType.event, eventId: id, eventData: data);
    }

    //android
    return BaseModel(code: -1);
  }

  Future<BaseModel> postInstall() async {
    if (GetPlatform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var idfaStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      var userAgent = "";
      try {
        var result =
            await GetConnect(followRedirects: false).get("https://google.com");
        userAgent = result.request?.headers["user-agent"] ?? "";
      } catch (e) {
        print(e);
      }

      return await TbaIos.instance.postData(TbaType.install, eventData: {
        "pupa": "build/${iosInfo.systemVersion}",
        "amelia": userAgent,
        "riley":
            idfaStatus != TrackingStatus.authorized ? "northrop" : "thieves",
        "they": "0",
        "rumford": "0",
        "domineer": "0",
        "cloy": "0",
        "usurp": "0",
        "drain": "0",
      });
    }

    return BaseModel(code: -1);

    //android
    // var andInfo = await DeviceInfoPlugin().androidInfo;
    //
    // var result = await GetConnect().get("https://boxhub24.com");
    // var userAgent = result.request?.headers["user-agent"] ?? "";
    //
    // ReferrerDetails referrerDetails =
    //     await AndroidPlayInstallReferrer.installReferrer;
    //
    // referrerDetails.googlePlayInstantParam;
    //
    // return await TbaAnd.instance.postData(TbaType.install, eventData: {
    //   "denmark": "build/${andInfo.version.release}",
    //   "sal": userAgent,
    //   "jesse": "gavel",
    //   //referrer_click_timestamp_seconds
    //   "fayette": referrerDetails.referrerClickTimestampSeconds,
    //   //install_begin_timestamp_seconds
    //   "price": referrerDetails.installBeginTimestampSeconds,
    //   //referrer_click_timestamp_server_seconds
    //   "culvert": referrerDetails.referrerClickTimestampServerSeconds,
    //   //install_begin_timestamp_server_seconds
    //   "cruddy": referrerDetails.installBeginTimestampServerSeconds,
    //   //install_first_seconds
    //   "ask": "0",
    //   //last_update_seconds
    //   "bilge": "0",
    //   //referrer_url
    //   "bonfire": referrerDetails.installReferrer,
    //   //install_version
    //   "brusque": referrerDetails.installVersion,
    // });
  }

  Future<BaseModel> postSession() async {
    AppLog.e("上报session");
    if (GetPlatform.isIOS) {
      return await TbaIos.instance.postData(TbaType.session);
    }
    return BaseModel(code: -1);
  }

  Future<BaseModel> postAd(
      {required String ad_network,
      required String ad_format,
      required String ad_source,
      required String ad_unit_id,
      required String ad_pos_id,
      required String ad_pre_ecpm,
      required String currency,
      required String precision_type}) async {
    AppLog.i("广告收益原值:$ad_pre_ecpm，$ad_format,$ad_source, $ad_network, $ad_unit_id");
    // AppLog.e("广告来源:$ad_network");

    double ecpm = double.tryParse(ad_pre_ecpm) ?? 0;
    if (GetPlatform.isIOS) {
      //ios max价值乘以10的6次方
      if (ad_source == "max" || ad_source == "topon") {
        ecpm = ecpm * 1000000;
      }

      var afNetwork = AFMediationNetwork.googleAdMob;
      if (ad_source == "admob") {
        afNetwork = AFMediationNetwork.googleAdMob;
      } else if (ad_source == "max") {
        afNetwork = AFMediationNetwork.applovinMax;
      } else if (ad_source == "topon") {
        afNetwork = AFMediationNetwork.topon;
      }
      Get.find<Application>().appsflyerSdk?.logAdRevenue(AdRevenueData(
          monetizationNetwork: ad_network,
          mediationNetwork: afNetwork.value,
          currencyIso4217Code: currency,
          revenue: ecpm / 1000000));

      //自定义ad_impression事件
      // Get.find<Application>()
      //     .appsflyerSdk
      //     ?.logEvent("ad_impression", {"revenue": ecpm / 1000000});

      //上报facebook价值
      FacebookAppEvents().logAdImpression(adType: ad_source);
      //自定义事件上报价值
      FacebookAppEvents()
          .logEvent(name: "ad_impression_revenue", valueToSum: ecpm / 1000000);
      FacebookAppEvents().logPurchase(amount: ecpm / 1000000, currency: "USD");

      //tba事件
      TbaUtils.instance
          .postEvent("ad_impression_revenue", {"value": ecpm / 1000000});

      //firebase事件
      FirebaseAnalytics.instance
          .logAdImpression(value: ecpm / 1000000, currency: currency);
      FirebaseAnalytics.instance.logEvent(
        name: "ad_impression_revenue",
        parameters: {"value": ecpm / 1000000},
      );

      return await TbaIos.instance.postData(TbaType.ad, eventData: {
        "platelet": ad_network,
        "mckeon": ad_source,
        //广告id
        "ethereal": ad_unit_id,
        "converse": ad_format,
        "millikan": ad_pos_id,
        "bunk": ecpm.toStringAsFixed(2),
        "doodle": currency,
        "husky": precision_type,
      });
    }

    return BaseModel(code: -1);
  }

  Future<BaseModel> postUserData(Map<String, dynamic> data) async {
    if (GetPlatform.isIOS) {
      return await TbaIos.instance
          .postData(TbaType.event, eventId: "hamilton", eventData: data);
    }

    return BaseModel(code: -1);
  }
}

enum TbaType { install, session, ad, event, cloak }
