import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/base_api.dart';
import '../../app.dart';
import '../log.dart';

class CUtil extends BaseApi {
  CUtil._internal()
      : super(GetPlatform.isIOS ? "https://jocose.littlemusicmuse.com" : "");
  static final CUtil _instance = CUtil._internal();
  static CUtil get instance {
    return _instance;
  }

  Future<BaseModel> checkCloak() async {
    // httpClient.baseUrl =
    //     GetPlatform.isIOS ? "https://jocose.littlemusicmuse.com" : "";

    var packageInfo = await PackageInfo.fromPlatform();
    var userAppUuid = Get.find<Application>().userAppUuid;
    var netResult = await Connectivity().checkConnectivity();

    if (GetPlatform.isAndroid) {
      return BaseModel(code: -1);
    } else {
      var iosInfo = await DeviceInfoPlugin().iosInfo;

      var idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
      return httpRequest("/elope/callus", method: HttpMethod.get, body: {
        //distinct_id
        "teapot": userAppUuid,
        //client_ts
        "anagram": DateTime.now().millisecondsSinceEpoch,
        //device_model
        "bunch": iosInfo.model,
        //bundle_id
        "environ": packageInfo.packageName,
        //os_version
        "exorcise": iosInfo.systemVersion,
        //idfv
        "liken": iosInfo.identifierForVendor,
        // //gaid
        // "sergeant": "",
        // //android_id
        // "neophyte": "",
        //os
        "garland": "school",
        //idfa
        "labour": idfa,
        //app_version
        "brent": packageInfo.version,
      });
    }
  }
}
