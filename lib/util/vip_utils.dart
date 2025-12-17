import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:music_muse/const/bus.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/u_page/main/home/u_purchase_controller.dart';
import 'package:music_muse/u_page/main/home/u_purchase_page.dart';
import 'package:music_muse/util/idfa_util.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/remote_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

const String keyIsVip = "UserIsPurchaseVip";

class VipUtil {
  static final instance = VipUtil._();

  VipUtil._();

  final _isVip = false.obs;

  bool get isVip {
    return _isVip.value;
  }

  set vip(bool vip) {
    _isVip.value = vip;
  }

  init() {
    bool vip = museSp.getBool(keyIsVip);
    _isVip.value = vip;
  }

  Future requestVipStatus() async {
    try {
      if (kDebugMode) return;
      await SKRequestMaker().startRefreshReceiptRequest();
      String data = await SKReceiptManager.retrieveReceiptData();

      bool? val = await requestIapReceiptVerifier(data);
      if (val != null) {
        _isVip.value = val;
        museSp.setBool(keyIsVip, val);
      }
    } catch (e) {
      // _isVip.value = false;
      AppLog.e("error:${e.toString()}");
    }
  }

  Future<dynamic> getIapReceiptVerifier(String receiptData, {String? productId}) async {
    String deviceId = await this.deviceId;
    String packageName = (await packageInfo).packageName;
    String idfa = await IdfaUtil.instance.idfa;

    // final bytes = utf8.encode(receiptData);
    // String receiptDataBase64 = base64Encode(bytes);
    try {
      // Map<String, dynamic> params = {
      //   "device_id": deviceId,
      //   "package_name": packageName,
      //   "biz_params": {"idfa": idfa},
      //   "receipt_base64_data": receiptData
      // };
      // if (productId != null) {
      //   params["product_id"] = productId;
      // }
      // String api = MuseConfig.isUser ? "https://prodapi.apporder.net" : "https://apporder.powerfulclean.net";
      // String path = "$api/v1/ios/receipt-verifier";
      // AppLog.i("request(post):$path, data:$params");
      // final response = await Dio().post(path, data: params, options: option);
      // AppLog.i("response:${response.data}");
      // return response;
      if (MuseConfig.isUser) {
        Options option = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {"retattle": "rhinegrave"},
        );
        Map<String, dynamic> params = {
          "faenas": deviceId, //device_id
          "satanology": packageName, //package_name
          "unspoilt": {"shopworn": idfa}, //biz_params
          "stemson": receiptData //receipt_base64_data
        };
        if (productId != null) {
          params["fellahs"] = productId; //product_id
        }
        String api = "https://prod.order.littlemusicmuse.com";
        String path = "$api/cretinic/tuckahoes/respondent";
        AppLog.i("request(post):$path, data:$params, headers:${option.headers}");
        final response = await Dio().post(path, data: params, options: option);
        AppLog.i("response:${response.data}");
        return response;
      } else {
        Options option = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {"dauncy": "veinings"},
        );
        Map<String, dynamic> params = {
          "flocculus": deviceId, //device_id
          "herbwoman": packageName,
          "imperfect": {"bepistoled": idfa},
          "pliantness": receiptData
        };
        if (productId != null) {
          params["or7qcykugi"] = productId;
        }
        String api = "https://apporder.powerfulclean.net";
        String path = "$api/fard/2fwxn8jrcc/homerist";
        AppLog.i("request(post):$path, data:$params, headers:${option.headers}");
        final response = await Dio().post(path, data: params, options: option);
        AppLog.i("response:${response.data}");
        return response;
      }
    } catch (e) {
      AppLog.e('Post 异常$e');
    }
    return null;
  }

  Future<bool?> requestIapReceiptVerifier(String receiptData, {String? productId}) async {
    final response = await getIapReceiptVerifier(receiptData, productId: productId);
    if (response == null || response.data == null) {
      return null;
    }
    if (response.statusCode != 200) return null;
    // bool ok = response.data["entity"]?["ok"] ?? false;
    //
    // List latestReceiptInfo = response.data["entity"]?["latest_receipt_info"] ?? [];
    //
    // AppLog.i("request receiptVerifier is vip : $ok");
    //
    // if (ok && latestReceiptInfo.isNotEmpty) {
    //   String? productId = latestReceiptInfo.first["product_id"];
    //   String? expiresDate = latestReceiptInfo.first["expires_date"];
    //   String? purchaseDate = latestReceiptInfo.first["purchase_date"];
    //   AppLog.i("vip详情： productId:$productId, purchaseDate:$purchaseDate, expiresDate:$expiresDate");
    // }

    bool ok = false;
    if (MuseConfig.isUser) {
      ok = response.data["foodstuff"]?["prevailers"] ?? false;

      List latestReceiptInfo = response.data["entity"]?["monaurally"] ?? [];

      AppLog.i("request receiptVerifier is vip : $ok");

      if (ok && latestReceiptInfo.isNotEmpty) {
        String? productId = latestReceiptInfo.first["fellahs"];
        String? expiresDate = latestReceiptInfo.first["palomino"];
        String? purchaseDate = latestReceiptInfo.first["ordinately"];
        AppLog.i("订阅结果：productId:$productId, expiresDate:$expiresDate, purchaseDate:$purchaseDate,");
      }
    } else {
      ok = response.data["sporocyte"]?["dispositor"] ?? false;

      List latestReceiptInfo = response.data["sporocyte"]?["mormaordom"] ?? [];

      AppLog.i("request receiptVerifier is vip : $ok");

      if (ok && latestReceiptInfo.isNotEmpty) {
        String? productId = latestReceiptInfo.first["or7qcykugi"];
        String? expiresDate = latestReceiptInfo.first["skindiver"];
        String? purchaseDate = latestReceiptInfo.first["6xejkwksqw"];
        AppLog.i("订阅结果：productId:$productId, expiresDate:$expiresDate,purchaseDate:$purchaseDate,");
      }
    }

    return ok;
  }

  Future<PackageInfo> get packageInfo async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<String> get deviceId async {
    String? deviceId = museSp.getString(keyIDFVDeviceId);
    if (deviceId == null) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      IosDeviceInfo deviceInfo = await deviceInfoPlugin.iosInfo;
      deviceId = deviceInfo.identifierForVendor ?? const Uuid().v4();
      museSp.setString(keyIDFVDeviceId, deviceId);
    }
    return deviceId;
  }

  static String keyIDFVDeviceId = "keyIDFVDeviceId";
  static String keyFirstInAppDate = "keyFirstInAppDateMt";
  static String keyLastShowPurchaseDate = "keyLastShowPurchaseDateMt";

  bool autoEnterPurchasePage() {
    AppLog.i("autoEnterPurchasePage isVip:$isVip, type:${RemoteUtil.shareInstance.vipShowType.name}");

    if (isVip) return false;

    if (RemoteUtil.shareInstance.vipShowType == VipShowType.B) {
      if (!isFirstDayInApp && !isTodayShowedPage) {
        museSp.setInt(keyLastShowPurchaseDate, DateTime.now().millisecondsSinceEpoch);
        Get.to(() => UPurchasePage(), arguments: PurchasePageFrom.enter.name);
        return true;
      }
    }
    return false;
  }

  bool get isFirstDayInApp {
    int dateMt = museSp.getInt(keyFirstInAppDate);
    if (dateMt == 0) {
      museSp.setInt(keyFirstInAppDate, DateTime.now().millisecondsSinceEpoch);
      AppLog.i("isFirstDay:是");
      return true;
    }
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateMt);
    if (isSameDay(DateTime.now(), dateTime)) {
      AppLog.i("isFirstDay:是");
      return true;
    }
    AppLog.i("isFirstDay:不是");
    return false;
  }

  bool get isTodayShowedPage {
    int lastShowDateMt = museSp.getInt(keyLastShowPurchaseDate);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(lastShowDateMt);
    if (isSameDay(DateTime.now(), dateTime)) {
      AppLog.i("isTodayShowed:是");
      return true;
    }
    AppLog.i("isTodayShowed:不是");
    return false;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
