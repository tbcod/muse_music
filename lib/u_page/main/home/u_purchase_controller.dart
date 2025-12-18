import 'dart:async';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:music_muse/const/bus.dart';
import 'package:music_muse/muse_config.dart';
import 'package:music_muse/page/main/setting/only_web.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:music_muse/util/toast.dart';
import 'package:music_muse/util/vip_utils.dart';

enum PurchasePageFrom {
  enter,
  home,
  setting,
  library,
}

class UPurchasePageController extends GetxController {
  List<Map<String, dynamic>> get products => _products;

  final _products = <Map<String, dynamic>>[].obs;

  var curPlanIndex = 0.obs;

  String currencySymbol = "\$";

  final _inAppPurchase = InAppPurchase.instance;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  late String station;

  @override
  void onInit() {
    station = Get.arguments ?? PurchasePageFrom.home.name;
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
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) async {
      bool isSuc = false;
      for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
        String? transactionDate = purchaseDetails.transactionDate;
        AppLog.i("purchaseUpdated listen productID：${purchaseDetails.productID}, status:${purchaseDetails.status.name} ,$transactionDate, ${purchaseDetails.verificationData.serverVerificationData}");
        if (purchaseDetails.status == PurchaseStatus.pending) {
          LoadingUtil.showLoading();
        } else {
          LoadingUtil.hideAllLoading();
          if (purchaseDetails.status == PurchaseStatus.error) {
            AppLog.e("purchaseUpdated error:${purchaseDetails.error?.toString()}");
            EventUtils.instance.addEvent("premium_fail", data: {"error": purchaseDetails.error?.toString() ?? "Purchase error"});
          } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
            bool valid = await _verifyPurchase(purchaseDetails);
            if (valid) {
              EventUtils.instance.addEvent("premium_succ", data: {"pay_id": purchaseDetails.productID});
              isSuc = true;
            } else {
              EventUtils.instance.addEvent("premium_fail", data: {"error": "service verify fail!"});
            }
          } else if (purchaseDetails.status == PurchaseStatus.canceled) {
            ToastUtil.showToast(msg: 'canceled'.tr, type: IconType.error);
            EventUtils.instance.addEvent("premium_fail", data: {"error": "user cancel"});
          }
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);
          }
        }
      }
      if(isSuc){
        VipUtil.instance.vip = true;
        museSp.setBool(keyIsVip, true);
        ToastUtil.showToast(msg: 'subscribedSuc'.tr, type: IconType.success);
        Get.back();
      }else{
        ToastUtil.showToast(msg: 'subscriptionFail'.tr, type: IconType.error);
      }
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      AppLog.e("purchaseUpdated error:${error.toString()}");
      EventUtils.instance.addEvent("premium_fail", data: {"error": "other error:${error.toString()}"});
    });
    super.onInit();
  }

  @override
  void onReady() {
    synProductInfoFormAppstore();
    super.onReady();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> synProductInfoFormAppstore() async {
    List<String> kProductIds = [];
    for (Map map in _products) {
      kProductIds.add(map["id"]);
    }

    bool loadSuc = false;
    LoadingUtil.showLoading();

    /// 查询后台返回的ProductId是否在苹果服务器上注册了
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(kProductIds.toSet());
    List<ProductDetails> productList = productDetailResponse.productDetails;
    if (_products.length == productList.length) {
      loadSuc = true;
      for (int i = 0; i < productList.length; i++) {
        ProductDetails productDetails = productList[i];
        PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
        currencySymbol = purchaseParam.productDetails.currencySymbol;
        for (Map map in _products) {
          if (map["id"] == purchaseParam.productDetails.id) {
            map["price"] = purchaseParam.productDetails.rawPrice;
            break;
          }
        }
      }
    }
    _products.refresh();
    curPlanIndex.value = yearIndex;
    AppLog.i("getProductInfo:${productList.length}");
    EventUtils.instance.addEvent("premium_page", data: {"station": station, "load": loadSuc ? "suc" : "fail", "load_page": bus.isBMode ? "b" : "a"});
    LoadingUtil.hideAllLoading();
  }

  Future<void> payWithProductId(String id) async {
    LoadingUtil.showLoading();

    /// _inAppPurchase是否有效
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      AppLog.e("inAppPurchase isAvailable:$isAvailable");
      LoadingUtil.hideAllLoading();
      return;
    }

    List<String> kProductIds = [id];

    /// 查询后台返回的ProductId是否在苹果服务器上注册了
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(kProductIds.toSet());

    if (productDetailResponse.error != null) {
      AppLog.e("获取内购产品信息失败： ${productDetailResponse.error.toString()}");
      LoadingUtil.hideAllLoading();
      ToastUtil.showToast(msg: "failedGetProduct".tr);
      return;
    }
    if (productDetailResponse.productDetails.isEmpty) {
      AppLog.e("查询不到内购商品，没注册？暂无产品");
      LoadingUtil.hideAllLoading();
      ToastUtil.showToast(msg: "noProducts".tr);
      return;
    }
    LoadingUtil.hideAllLoading();

    List<ProductDetails> products = productDetailResponse.productDetails;

    // 向苹果服务器发起支付请求
    try {
      /// 查询成功
      ProductDetails productDetails = products[0];
      // FlutterKeychain.put(key: "iosPrice", value: productDetails.price);

      /// 添加自己服务器上生成的订单
      PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      AppLog.i("获取产品成功, 发起支付: ${productDetails.title}, ${productDetails.description}, ${productDetails.price}");

      LoadingUtil.showLoading();

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam); //非消耗性购买
    } catch (e) {
      await _inAppPurchase.restorePurchases();
      AppLog.e('购买出错：${e.toString()}');
    }
    LoadingUtil.hideAllLoading();
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final data = purchaseDetails.verificationData.serverVerificationData;
    if (data.isEmpty) return false;
    LoadingUtil.showLoading();

    bool? val = await VipUtil.instance.requestIapReceiptVerifier(data, productId: purchaseDetails.productID);
    LoadingUtil.hideAllLoading();
    if (val == true) return true;
    return false;
  }

  void onClickPrice(int index) {
    curPlanIndex.value = index;
    String curProduct = products[index]["id"];
    EventUtils.instance.addEvent("premium_page_click", data: {"pay_id": curProduct});
  }

  void onClickPay() {
    // EventUtils.instance.addEvent("sub_page_click", data: {"location": formSource});
    int curIndex = curPlanIndex.value;
    String curProduct = products[curIndex]["id"];
    payWithProductId(curProduct);
    EventUtils.instance.addEvent("premium_page_click_ot", data: {"type": "other"});
  }

  Future<void> onClickRestore() async {
    EventUtils.instance.addEvent("premium_page_click_ot", data: {"type": "restore"});

    LoadingUtil.showLoading(msg: "${'restore'.tr}...");
    Future.delayed(const Duration(seconds: 10)).then((value) => LoadingUtil.hideAllLoading());
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      AppLog.e(e.toString());
    }
    LoadingUtil.hideAllLoading();
  }

  void onClickPrivacyPolicy() {
    EventUtils.instance.addEvent("premium_page_click_ot", data: {"type": "other"});
    Get.to(() => const OnlyWeb(), arguments: 2);
  }

  void onClickTermsService() {
    EventUtils.instance.addEvent("premium_page_click_ot", data: {"type": "other"});
    Get.to(() => const OnlyWeb(), arguments: 1);
  }

  List<String> get contentTips {
    List<String> texts = [];
    if (bus.isBMode) {
      texts = ["unlimitedDownload".tr, "adFree".tr, "watchVideoOffline".tr, "playMusicBackground".tr];
    } else {
      texts = ["playMusicBackground".tr, "adFree".tr, "unlockedAllFunctions".tr];
    }
    return texts;
  }

  int get yearIndex {
    int index = 0;
    for (Map map in products) {
      if (map['id'] == 'year_b1' || map['id'] == 'com.musicmuse.subscription.yearly') {
        return index;
      }
      index++;
    }
    return index;
  }

  String get yearPriceStr {
    for (Map map in products) {
      if (map['id'] == 'year_b1' || map['id'] == 'com.musicmuse.subscription.yearly') {
        return "$currencySymbol${map['price']}";
      }
    }
    return '\$24.9';
  }
}
