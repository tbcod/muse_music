import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:music_muse/const/bus.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/page/main/setting/only_web.dart';
import 'package:music_muse/util/dialog_util.dart';
import 'package:music_muse/util/idfa_util.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:music_muse/util/toast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class UPurchasePageController extends GetxController {
  List<Map<String, dynamic>> get products => _products;

  final _products = <Map<String, dynamic>>[].obs;

  var curPlanIndex = 0.obs;

  String currencySymbol = "\$";

  final _inAppPurchase = InAppPurchase.instance;

  @override
  void onInit() {
    _products.value = MuseConfig.isUser
        ? [
            {"id": "com.musicmuse.subscription.weekly", "name": "1 ${"week".tr}", "price": 2.99},
            {"id": "com.musicmuse.subscription.yearly", "name": "1 ${"year".tr}", "price": 24.99, "detail": ""},
            {"id": "com.musicmuse.subscription.lifetime", "name": "lifeTime".tr, "price": 39.99}
          ]
        : [
            {"id": "week_b1", "name": "1 ${"week".tr}", "price": 2.99},
            {"id": "year_b1", "name": "1 ${"year".tr}", "price": 24.99, "detail": ""},
            {"id": "life_time_b", "name": "lifeTime".tr, "price": 39.99}
          ];
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> payWithProductId(String id) async {
    LoadingUtil.showLoading();

    /// _inAppPurchase是否有效
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      LoadingUtil.hideAllLoading();
      return;
    }

    /// 如果是iOS设备进行设置代理，接口苹果服务器的回调。
    // if (Platform.isIOS) {
    //   final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    //   await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    // }

    List<String> kProductIds = [id];

    /// 查询后台返回的ProductId是否在苹果服务器上注册了
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(kProductIds.toSet());

    if (productDetailResponse.error != null) {
      AppLog.e("获取产品信息失败,${productDetailResponse.error.toString()}");
      LoadingUtil.hideAllLoading();
      ToastUtil.showToast(msg: "Failed to get product information!");
      return;
    }
    if (productDetailResponse.productDetails.isEmpty) {
      AppLog.e("查询不到商品详情说明没注册 暂无产品");
      LoadingUtil.hideAllLoading();
      ToastUtil.showToast(msg: "No products yet!");
      return;
    }

    List<ProductDetails> products = productDetailResponse.productDetails;

    /// 查询成功
    ProductDetails productDetails = products[0];
    // FlutterKeychain.put(key: "iosPrice", value: productDetails.price);

    /// 添加自己服务器上生成的订单
    PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    AppLog.i("获取产品成功, 发起支付: ${productDetails.title}, ${productDetails.description}, ${productDetails.price}");

    /// 向苹果服务器发起支付请求
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final data = purchaseDetails.verificationData.serverVerificationData;
    if (data.isEmpty) return false;
    LoadingUtil.showLoading();

    // var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    // bool? val = result;

    // bool? val = await HttpApiIap.instance.requestIapReceiptVerifier(data, productId: purchaseDetails.productID);
    LoadingUtil.hideAllLoading();
    // if (val == true) return true;
    return false;
  }

  void onClickPrice(int index) {
    curPlanIndex.value = index;
    // EventUtils.instance.addEvent("sub_page_click", data: {"location": formSource});
  }

  void onClickPay() {
    // EventUtils.instance.addEvent("sub_page_click", data: {"location": formSource});
    int curIndex = curPlanIndex.value;
    String curProduct = products[curIndex]["id"];
    payWithProductId(curProduct);
  }

  Future<void> onClickRestore() async {
    LoadingUtil.showLoading(msg: "Restoring...");
    Future.delayed(const Duration(seconds: 10)).then((value) => LoadingUtil.hideAllLoading());
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      AppLog.i(e.toString());
    }
    LoadingUtil.hideAllLoading();
  }


  void onClickPrivacyPolicy() {
    Get.to(() => const OnlyWeb(), arguments: 2);
  }

  void onClickTermsService() {
    Get.to(() => const OnlyWeb(), arguments: 2);
  }
}

class PurchaseDio {
  PurchaseDio._internal();

  static final PurchaseDio _instance = PurchaseDio._internal();

  static PurchaseDio get instance {
    return _instance;
  }

  Future<dynamic> getIapReceiptVerifier(String receiptData, {String? productId}) async {
    Options option = Options(
      validateStatus: (_) => true,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    String deviceId = await this.deviceId;
    String packageName = (await packageInfo).packageName;
    String idfa = await IdfaUtil.instance.idfa;
    try {
      Map<String, dynamic> params = {
        "device_id": deviceId,
        "package_name": packageName,
        "biz_params": {"idfa": idfa},
        "receipt_base64_data": receiptData
      };
      if (productId != null) {
        params["product_id"] = productId;
      }
      String api = MuseConfig.isUser ? "https://prodapi.apporder.net" : "https://apporder.powerfulclean.net";
      String path = "$api/v1/ios/receipt-verifier";
      AppLog.i("request(post):$path, data:$params");
      final response = await Dio().post(path, data: params, options: option);
      AppLog.i("response:${response.data}");
      return response;
    } catch (e) {
      AppLog.e('Post 异常$e');
    }
    return null;
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
