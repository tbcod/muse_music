import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'log.dart';

class IdfaUtil {
  IdfaUtil._internal();

  static final IdfaUtil _instance = IdfaUtil._internal();

  static IdfaUtil get instance {
    return _instance;
  }

  Future showIdfaDialog() async {
    if (!GetPlatform.isIOS) {
      return;
    }

    var sta = await ConsentInformation.instance.getConsentStatus();
    if (sta == ConsentStatus.obtained) {
      AppLog.i("idfa 已展示gdprStatus: ${sta.name}");
      if(kDebugMode){
        var idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
        AppLog.e("idfa:$idfa");
      }
      return true;
    }

    // final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    // if (status != TrackingStatus.denied && status != TrackingStatus.authorized) {
    //   TrackingStatus status2 = await AppTrackingTransparency.requestTrackingAuthorization();
    //   return status2 == TrackingStatus.denied || status2 == TrackingStatus.authorized;
    // }
    // return false;

    var status = await AppTrackingTransparency.requestTrackingAuthorization();
    AppLog.i("idfa status: ${status.name}");
    if (status == TrackingStatus.authorized) {
      // var idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
      // AppLog.e(idfa);
    }
    // AppLog.e(status);
  }
}
