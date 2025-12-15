import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:music_muse/const/bus.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/util/idfa_util.dart';
import 'package:music_muse/util/log.dart';
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
      final test = base64Decode(receiptData);

      if (MuseConfig.isUser) {
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

    bool ok = response.data["sporocyte"]?["dispositor"] ?? false;

    List latestReceiptInfo = response.data["sporocyte"]?["mormaordom"] ?? [];

    AppLog.i("request receiptVerifier is vip : $ok");

    if (ok && latestReceiptInfo.isNotEmpty) {
      String? productId = latestReceiptInfo.first["or7qcykugi"];
      String? expiresDate = latestReceiptInfo.first["skindiver"];
      String? purchaseDate = latestReceiptInfo.first["6xejkwksqw"];
      AppLog.i("订阅详情： productId:$productId, purchaseDate:$purchaseDate, expiresDate:$expiresDate");
    }
    return ok;
  }

  Future<PackageInfo> get packageInfo async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<String> get deviceId async {
    String? deviceId = museSp.getString('keyDeviceId');
    if (deviceId == null) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      IosDeviceInfo deviceInfo = await deviceInfoPlugin.iosInfo;
      deviceId = deviceInfo.identifierForVendor ?? const Uuid().v4();
      museSp.setString('keyDeviceId', deviceId);
    }
    // logPrint.i("deviceId:$deviceId");
    return deviceId;
  }
}
