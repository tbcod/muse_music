import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:get/get.dart';

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
    var status = await AppTrackingTransparency.requestTrackingAuthorization();
    if (status == TrackingStatus.authorized) {
      var idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
      AppLog.e(idfa);
    }
    AppLog.e(status);
  }
}
