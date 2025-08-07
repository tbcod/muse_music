import 'dart:async';
import 'dart:convert';

import 'package:anythink_sdk/at_index.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/util/ad/admob_util.dart';
import 'package:music_muse/util/ad/max_util.dart';
import 'package:music_muse/util/ad/topon_util.dart';
import 'package:music_muse/util/remote_utils.dart';
import 'package:music_muse/util/tba/tba_util.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;

import '../../app.dart';
import '../log.dart';
import '../native_util.dart';
import '../tba/event_util.dart';
import 'view/full_admob_native_page.dart';

class AdUtils {
  AdUtils._internal();

  static final AdUtils _instance = AdUtils._internal();

  static AdUtils get instance {
    return _instance;
  }

  // Map<String, dynamic> adJson = {};

  Map<String, dynamic> get adJson => RemoteUtil.shareInstance.adJson;

  //and test
  // Map<String, dynamic> adJson = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [
  //     {"adweight": 2, "adtype": "open", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/9257395921"}
  //   ],
  //   "behavior": [
  //     {"adweight": 3, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/1033173712"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "b439448917e51dd1"},
  //     {"adweight": 4, "adtype": "rewarded", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/5224354917"},
  //     {"adweight": 2, "adtype": "rewarded", "adsource": "max", "placementid": "63fe7352fcdc8ac7"}
  //   ],
  // };

  // //ios test
  // Map<String, dynamic> adJsonIos = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [
  //     {"adweight": 2, "adtype": "open", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/5575463023"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "fbd6076120e63535"},
  //     {"adweight": 3, "adtype": "interstitial", "adsource": "topon", "placementid": "b1g8t40knh0dqb"}
  //   ],
  //   "behavior": [
  //     {"adweight": 3, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/4411468910"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "fbd6076120e63535"},
  //     {"adweight": 4, "adtype": "rewarded", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/1712485313"},
  //     {"adweight": 2, "adtype": "rewarded", "adsource": "max", "placementid": "7aa2c1ce7a11fe8b"},
  //     {"adweight": 8, "adtype": "rewarded", "adsource": "topon", "placementid": "b1g8t40knh0541"},
  //     {"adweight": 9, "adtype": "interstitial", "adsource": "topon", "placementid": "b1g8t40knh0dqb"}
  //   ],
  //   "homenative": [
  //     {"adweight": 1, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/3986624511"},
  //     // {
  //     //   "adweight": 2,
  //     //   "adtype": "native",
  //     //   "adsource": "topon",
  //     //   "placementid": "b1g8t40knh0lt8"
  //     // },
  //     // {
  //     //   "adweight": 2,
  //     //   "adtype": "banner",
  //     //   "adsource": "topon",
  //     //   "placementid": "b1g8t40knh0rb9"
  //     // }
  //   ]
  // };

  //and
  // Map<String, dynamic> adJsonRelease = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [],
  //   "behavior": [],
  // };

  //ios
  // Map<String, dynamic> adJsonIosRelease = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [
  //     {"adweight": 2, "adtype": "open", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/3411461191"}
  //   ],
  //   "behavior": [
  //     {"adweight": 4, "adtype": "rewarded", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/4724542864"},
  //     {"adweight": 2, "adtype": "rewarded", "adsource": "max", "placementid": "6b7f8cfc9167499f"},
  //     {"adweight": 3, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/3270503151"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "15eb7d0b57d6656c"}
  //   ],
  //   "homenative": [
  //     {"adweight": 1, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/3689560112"}
  //   ]
  // };

  DateTime? lastShowTime;

  var bannerNativeAdClicked = false.obs;

  //是否超过广告间隔
  Future<bool> canShow() async {
    if (lastShowTime == null) {
      return true;
    }

    var nowTime = DateTime.now();

    Duration temp = nowTime.difference(lastShowTime!);
    num wait = num.tryParse(adJson["sameinterval"].toString()) ?? 60;
    AppLog.i("广告间隔,$lastShowTime,$nowTime, ${temp.inSeconds}---$wait");

    if (temp.inSeconds > wait || temp.inSeconds < 0) {
      return true;
    } else {
      return false;
    }
  }

  //设置上次显示广告时间
  Future setShowTime() async {
    // AppLog.e("保存关闭广告时间");

    lastShowTime = DateTime.now();
    // var sp = await SharedPreferences.getInstance();
    // await sp.setInt("lastShowAdMs", DateTime.now().millisecondsSinceEpoch);
  }

  //
  // //获取firebase广告配置
  // Future<Map> initJsonByFireBase() async {
  //   // return adJson;
  //
  //   var tempTime = DateTime.now();
  //   //获取云控字段
  //   try {
  //     await FirebaseRemoteConfig.instance.setConfigSettings(
  //       RemoteConfigSettings(
  //         fetchTimeout: const Duration(seconds: 15),
  //         minimumFetchInterval: const Duration(seconds: 30),
  //       ),
  //     );
  //
  //     var isOk = await FirebaseRemoteConfig.instance.fetchAndActivate();
  //     //初始化facebook
  //     NativeUtils.instance.initFacebook();
  //     var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
  //     EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});
  //     //使用json
  //     var jsonString = FirebaseRemoteConfig.instance.getString(
  //       GetPlatform.isIOS ? "ad_json_ios" : "ad_json_and",
  //     );
  //     AppLog.e("获取云控广告");
  //     AppLog.e(jsonString);
  //
  //     Map oldMap = jsonDecode(jsonString);
  //     //map key转为小写
  //     adJson = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
  //   } catch (e) {
  //     AppLog.e(e);
  //   }
  //
  //   FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
  //     var tempTime = DateTime.now();
  //
  //     var isOk = await FirebaseRemoteConfig.instance.activate();
  //
  //     if (isOk) {
  //       var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
  //       EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});
  //     }
  //
  //     // Use the new config values here.
  //     var jsonString1 = FirebaseRemoteConfig.instance.getString(
  //       GetPlatform.isIOS ? "ad_json_ios" : "ad_json_and",
  //     );
  //     Map oldMap1 = jsonDecode(jsonString1);
  //     AppLog.e(oldMap1);
  //     //map key转为小写
  //     adJson = oldMap1.map((key, value) => MapEntry(key.toLowerCase(), value));
  //   });
  //
  //   // var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
  //   //
  //   // EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});
  //   return adJson;
  // }

  //已加载的广告，key为广告id，显示后移除对应广告
  var loadedAdMap = {};

  //load
  loadAd(String key, {LoadCallback? onLoad}) {
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告$key");
      return;
    }
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    AppLog.i("开始加载广告:$key");

    //循环加载广告
    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];

      if (loadedAdMap.containsKey(ad_id)) {
        //如果已经加载了并且没有超时就跳过
        int timeMs = loadedAdMap[ad_id]["timeMs"] ?? 0;
        //缓存过期时间
        if (timeMs < DateTime.now().subtract(const Duration(minutes: 55)).millisecondsSinceEpoch) {
          //已过期,删除广告重新加载
          //销毁广告后删除

          // admob广告先销毁再删除
          if (ad_id.startsWith("ca-app-pub")) {
            AdWithoutView? adView = loadedAdMap[ad_id]["admob_ad"];
            adView?.dispose();
          }
          loadedAdMap.remove(ad_id);
        } else {
          //未过期，加载下一条
          continue;
        }
      }

      AppLog.i("广告开始加载：$key， $source, $type, $ad_id");

      if (source == "admob") {
        //加载admob广告
        if (type == "open") {
          AppOpenAd.load(
            adUnitId: ad_id,
            request: const AdRequest(),
            adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
              if (onLoad != null) {
                onLoad(ad.adUnitId, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": ad,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
              };
            }, onAdFailedToLoad: (e) {
              if (onLoad != null) {
                onLoad(ad_id, false, e);
              }
            }),
          );
        } else if (type == "interstitial") {
          InterstitialAd.load(
            adUnitId: ad_id,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
              AppLog.i("广告加载成功：$key， $source, $type, $ad_id");
              if (onLoad != null) {
                onLoad(ad.adUnitId, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": ad,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
              };
            }, onAdFailedToLoad: (e) {
              if (onLoad != null) {
                onLoad(ad_id, false, e);
              }
            }),
          );
        } else if (type == "rewarded") {
          RewardedAd.load(
            adUnitId: ad_id,
            request: const AdRequest(),
            rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
              AppLog.i("广告加载成功：$key， $source, $type, $ad_id");
              if (onLoad != null) {
                onLoad(ad.adUnitId, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": ad,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
              };
            }, onAdFailedToLoad: (e) {
              if (onLoad != null) {
                onLoad(ad_id, false, e);
              }
            }),
          );
        } else if (type == "native") {
          NativeAd nativeAd = NativeAd(
            adUnitId: ad_id,
            request: const AdRequest(),
            // factoryId: "",
            listener: admob.NativeAdListener(onAdLoaded: (ad) async {
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": ad,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
              };
            }, onAdFailedToLoad: (ad, e) {
              ad.dispose();
              if (onLoad != null) {
                onLoad(ad_id, false, e);
              }
            }, onAdClicked: (ad) {
              // Global.instance.bannerNativeAdClicked.value = true;
              bannerNativeAdClicked.refresh();
              // showBlock?.onClick?.call();
            }, onAdImpression: (ad) {
              adIsShowing = true;
              AppLog.i("原生广告onAdImpression:${ad.adUnitId}");
              // showBlock?.onShowSuccess?.call();
            }, onAdClosed: (ad) {
              // showBlock?.onClose?.call();
              //关闭
              // adIsShowing = false;
              // //设置显示时间以判断广告间隔
              // setShowTime();
              // //重新加载一轮广告
              // loadAd(key);
            }, onAdWillDismissScreen: (ad) {
              // AppLog.i("原生广告onAdWillDismissScreen:${ad.adUnitId}");
            }, onAdOpened: (ad) {
              AppLog.i("原生广告onAdOpened:${ad.adUnitId}");
              adIsShowing = true;
            }, onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
              TbaUtils.instance.postAd(
                  ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "admob",
                  ad_format: "native",
                  ad_source: "admob",
                  ad_unit_id: ad.adUnitId,
                  ad_pos_id: key,
                  ad_pre_ecpm: valueMicros.toString(),
                  currency: currencyCode,
                  precision_type: precision.name);
            }),
            nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium, cornerRadius: 8),
          );
          nativeAd.load();
        }
      } else if (source == "max") {
        //加载max广告
        if (type == "open") {
          AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(
              onAdLoadedCallback: (ad) {
                AppLog.i("广告加载成功：$key， $source, $type, $ad_id");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
                };
              },
              onAdLoadFailedCallback: (adId, e) {
                if (onLoad != null) {
                  onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
                }
              },
              onAdDisplayedCallback: (ad) {},
              onAdDisplayFailedCallback: (ad, e) {},
              onAdClickedCallback: (ad) {},
              onAdHiddenCallback: (ad) {}));
          AppLovinMAX.loadAppOpenAd(ad_id);
        } else if (type == "interstitial") {
          AppLovinMAX.setInterstitialListener(InterstitialListener(
              onAdLoadedCallback: (ad) {
                AppLog.i("广告加载成功：$key， $source, $type, $ad_id");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
                };
              },
              onAdLoadFailedCallback: (adId, e) {
                if (onLoad != null) {
                  onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
                }
              },
              onAdDisplayedCallback: (ad) {},
              onAdDisplayFailedCallback: (ad, e) {},
              onAdClickedCallback: (ad) {},
              onAdHiddenCallback: (ad) {}));
          AppLovinMAX.loadInterstitial(ad_id);
        } else if (type == "rewarded") {
          AppLovinMAX.setRewardedAdListener(RewardedAdListener(
              onAdLoadedCallback: (ad) {
                AppLog.i("广告加载成功：$key， $source, $type, $ad_id");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
                };
              },
              onAdLoadFailedCallback: (adId, e) {
                if (onLoad != null) {
                  onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
                }
              },
              onAdDisplayedCallback: (ad) {},
              onAdDisplayFailedCallback: (ad, e) {},
              onAdClickedCallback: (ad) {},
              onAdHiddenCallback: (ad) {},
              onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {}));
          AppLovinMAX.loadRewardedAd(ad_id);
        }
      } else if (source == "topon") {
        if (type == "interstitial") {
          TopOnUtils.instance.interstitialStream?.cancel();
          TopOnUtils.instance.interstitialStream = null;

          // AppLog.e("加载topon插屏");
          TopOnUtils.instance.interstitialStream = ATListenerManager.interstitialEventHandler.listen((e) {
            if (e.interstatus == InterstitialStatus.interstitialAdDidFinishLoading) {
              //加载成功
              // AppLog.e("topon插屏加载成功");
              AppLog.i("广告加载成功：$key， $source, $type, $ad_id");

              if (onLoad != null) {
                onLoad(e.placementID, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": null,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
              };
            } else if (e.interstatus == InterstitialStatus.interstitialAdFailToLoadAD) {
              //加载失败
              AppLog.e("topon插屏加载失败:${e.requestMessage}");
              if (onLoad != null) {
                onLoad(e.placementID, false, AdError(-101, "", e.requestMessage));
              }
            }
          });
          ATInterstitialManager.loadInterstitialAd(placementID: ad_id, extraMap: {});
        } else if (type == "rewarded") {
          TopOnUtils.instance.rewardedStream?.cancel();
          TopOnUtils.instance.rewardedStream = null;

          // AppLog.e("加载topon激励");
          TopOnUtils.instance.rewardedStream = ATListenerManager.rewardedVideoEventHandler.listen((e) {
            if (e.rewardStatus == RewardedStatus.rewardedVideoDidFinishLoading) {
              //加载成功
              //加载成功
              // AppLog.e("topon激励加载成功");
              AppLog.i("广告加载成功：$key， $source, $type, $ad_id");

              if (onLoad != null) {
                onLoad(e.placementID, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": null,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2
              };
            } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidFailToLoad) {
              //加载失败
              AppLog.e("topon激励加载失败:${e.requestMessage}");
              if (onLoad != null) {
                onLoad(e.placementID, false, AdError(-101, "", e.requestMessage));
              }
            }
          });
          ATRewardedManager.loadRewardedVideo(placementID: ad_id, extraMap: {});
        }
      }
    }
  }

  bool adIsShowing = false;

  Future<bool> showAd(String key, {ShowCallback? onShow}) async {
    //TODO 测试不显示广告
    // if (onShow != null) {
    //   onShow.onShowFail!("", AdError(-1, "", "show key error"));
    // }
    // return false;

    if (adIsShowing) {
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "ad is showing"));
      }
      return false;
    }

    if (Get.find<Application>().isAppBack == true) {
      AppLog.e("app在后台");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "app is background"));
      }
      return false;
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    // AppLog.e("广告网络：$connectivityResult");
    if (!connectivityResult.contains(ConnectivityResult.wifi) && !connectivityResult.contains(ConnectivityResult.mobile)) {
      //没有网络
      AppLog.e("没有网络，不显示广告");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "no network"));
      }
      return false;
    }

    //会员去除广告
    // if (Get.find<Application>().isVip.value) {
    //   //直接启动app
    //   if (key == "open" && Get.isRegistered<SplashPageController>()) {
    //     Get.find<SplashPageController>().toMainPage();
    //   }
    //   return false;
    // }

    if (!await canShow()) {
      AppLog.i("广告间隔未到, $key");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "ad interval has not expired"));
      }
      return false;
    }

    AppLog.i("准备展示广告, $key");

    if (key != "level_h") {
      bool isHighSuc = await showAd("level_h", onShow: onShow);
      AppLog.i("先展示高价位, $key， $isHighSuc");
      if (isHighSuc) {
        return true;
      }
    }

    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "show key error"));
      }
      return false;
    }

    //显示广告逻辑
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return false;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    //循环判断广告是否加载

    AppLog.i("开始显示广告:$key");

    var isShowAd = false;
    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];

      if (!loadedAdMap.containsKey(ad_id)) {
        //没有加载跳过
        continue;
      }

      var loadedItem = loadedAdMap[ad_id] ?? {};

      if (source == "admob") {
        //显示admob广告
        if (type == "open") {
          AppOpenAd? openAd = loadedItem["admob_ad"];
          //设置显示事件
          openAd?.fullScreenContentCallback = FullScreenContentCallback(onAdClicked: (ad) {
            if (onShow != null) {
              onShow.onClick!(ad.adUnitId);
            }
          }, onAdFailedToShowFullScreenContent: (ad, e) {
            //显示失败删除缓存广告
            loadedAdMap.remove(ad.adUnitId);
            ad.dispose();

            if (onShow != null) {
              onShow.onShowFail!(ad.adUnitId, e);
            }
          }, onAdDismissedFullScreenContent: (ad) {
            adIsShowing = false;
            //广告关闭
            //删除缓存
            loadedAdMap.remove(ad.adUnitId);
            ad.dispose();
            //设置显示时间以判断广告间隔
            setShowTime();
            //重新加载一轮广告
            loadAd(key);

            if (onShow != null) {
              onShow.onClose!(ad.adUnitId);
            }
          }, onAdShowedFullScreenContent: (ad) {
            adIsShowing = true;
            if (onShow != null) {
              onShow.onShow!(ad.adUnitId);
            }
          });
          //设置收益事件
          openAd?.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            //上报广告收益
            TbaUtils.instance.postAd(
                ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
                ad_format: "open",
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_pos_id: key,
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                precision_type: precision.name);
          };
          openAd?.show();
          isShowAd = true;
          break;
        } else if (type == "interstitial") {
          InterstitialAd? interstitialAd = loadedItem["admob_ad"];
          //设置显示事件
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(onAdClicked: (ad) {
            if (onShow != null) {
              onShow.onClick!(ad.adUnitId);
            }
          }, onAdFailedToShowFullScreenContent: (ad, e) {
            //显示失败删除缓存广告
            loadedAdMap.remove(ad.adUnitId);
            ad.dispose();

            if (onShow != null) {
              onShow.onShowFail!(ad.adUnitId, e);
            }
          }, onAdDismissedFullScreenContent: (ad) {
            adIsShowing = false;
            //广告关闭
            //删除缓存
            loadedAdMap.remove(ad.adUnitId);
            ad.dispose();
            //设置显示时间以判断广告间隔
            setShowTime();
            //重新加载一轮广告
            loadAd(key);

            if (onShow != null) {
              onShow.onClose!(ad.adUnitId);
            }
          }, onAdShowedFullScreenContent: (ad) {
            adIsShowing = true;
            if (onShow != null) {
              onShow.onShow!(ad.adUnitId);
            }
          });
          //设置收益事件
          interstitialAd?.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            //上报广告收益
            TbaUtils.instance.postAd(
                ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
                ad_format: "interstitial",
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_pos_id: key,
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                precision_type: precision.name);
          };
          interstitialAd?.show();
          isShowAd = true;
          break;
        } else if (type == "rewarded") {
          RewardedAd? rewardedAd = loadedItem["admob_ad"];
          //设置显示事件
          rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(onAdClicked: (ad) {
            if (onShow != null) {
              onShow.onClick!(ad.adUnitId);
            }
          }, onAdFailedToShowFullScreenContent: (ad, e) {
            //显示失败删除缓存广告
            loadedAdMap.remove(ad.adUnitId);
            ad.dispose();

            if (onShow != null) {
              onShow.onShowFail!(ad.adUnitId, e);
            }
          }, onAdDismissedFullScreenContent: (ad) {
            adIsShowing = false;
            //广告关闭
            //删除缓存
            loadedAdMap.remove(ad.adUnitId);
            ad.dispose();
            //设置显示时间以判断广告间隔
            setShowTime();
            //重新加载一轮广告
            loadAd(key);

            if (onShow != null) {
              onShow.onClose!(ad.adUnitId);
            }
          }, onAdShowedFullScreenContent: (ad) {
            adIsShowing = true;
            if (onShow != null) {
              onShow.onShow!(ad.adUnitId);
            }
          });
          //设置收益事件
          rewardedAd?.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            //上报广告收益
            TbaUtils.instance.postAd(
                ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
                ad_format: "rewarded",
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_pos_id: key,
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                precision_type: precision.name);
          };
          rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            //用户看完激励广告
          });
          isShowAd = true;
          break;
        } else if (type == 'native') {
          NativeAd? ad = loadedItem["admob_ad"];
          if (ad != null) {
            Get.bottomSheet(
              FullAdmobNativePage(
                ad: ad,
                onClose: () async {
                  adIsShowing = false;
                  setShowTime();
                  await ad.dispose();
                  loadedAdMap.remove(ad.adUnitId);
                  loadAd(key);
                  if (onShow != null) {
                    onShow.onClose!(ad.adUnitId);
                  }
                },
              ),
              isScrollControlled: true,
              enableDrag: false,
              isDismissible: false,
              backgroundColor: Colors.black,
              useRootNavigator: true,
            );
            isShowAd = true;
            break;
          }
        }
      } else if (source == "max") {
        //Max广告

        if (type == "open") {
          var isReady = await AppLovinMAX.isAppOpenAdReady(ad_id);

          if (isReady ?? false) {
            //重新设置显示监听
            AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(onAdLoadedCallback: (ad) {
              //已经加载成功，无需回调此方法
            }, onAdLoadFailedCallback: (adId, e) {
              //已经加载成功，无需回调此方法
            }, onAdDisplayedCallback: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
            }, onAdDisplayFailedCallback: (ad, e) {
              loadedAdMap.remove(ad.adUnitId);
              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
              }
            }, onAdClickedCallback: (ad) {
              if (onShow != null) {
                onShow.onClick!(ad.adUnitId);
              }
            }, onAdHiddenCallback: (ad) {
              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(key);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
            }, onAdRevenuePaidCallback: (ad) {
              //收益上报
              TbaUtils.instance.postAd(
                  ad_network: ad.networkName,
                  ad_pos_id: key,
                  ad_source: "max",
                  ad_unit_id: ad.adUnitId,
                  ad_format: "open",
                  ad_pre_ecpm: ad.revenue.toString(),
                  currency: "",
                  precision_type: ad.revenuePrecision);
            }));

            AppLovinMAX.showAppOpenAd(ad_id);
            // loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        } else if (type == "interstitial") {
          var isReady = await AppLovinMAX.isInterstitialReady(ad_id);

          if (isReady ?? false) {
            //重新设置显示监听
            AppLovinMAX.setInterstitialListener(InterstitialListener(onAdLoadedCallback: (ad) {
              //已经加载成功，无需回调此方法
            }, onAdLoadFailedCallback: (adId, e) {
              //已经加载成功，无需回调此方法
            }, onAdDisplayedCallback: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
            }, onAdDisplayFailedCallback: (ad, e) {
              loadedAdMap.remove(ad.adUnitId);
              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
              }
            }, onAdClickedCallback: (ad) {
              if (onShow != null) {
                onShow.onClick!(ad.adUnitId);
              }
            }, onAdHiddenCallback: (ad) {
              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(key);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
            }, onAdRevenuePaidCallback: (ad) {
              //收益上报
              TbaUtils.instance.postAd(
                  ad_network: ad.networkName,
                  ad_pos_id: key,
                  ad_source: "max",
                  ad_unit_id: ad.adUnitId,
                  ad_format: "interstitial",
                  ad_pre_ecpm: ad.revenue.toString(),
                  currency: "",
                  precision_type: ad.revenuePrecision);
            }));

            AppLovinMAX.showInterstitial(ad_id);
            // loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        } else if (type == "rewarded") {
          var isReady = await AppLovinMAX.isRewardedAdReady(ad_id);

          if (isReady ?? false) {
            //重新设置显示监听
            AppLovinMAX.setRewardedAdListener(RewardedAdListener(onAdLoadedCallback: (ad) {
              //已经加载成功，无需回调此方法
            }, onAdLoadFailedCallback: (adId, e) {
              //已经加载成功，无需回调此方法
            }, onAdDisplayedCallback: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
            }, onAdDisplayFailedCallback: (ad, e) {
              loadedAdMap.remove(ad.adUnitId);
              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
              }
            }, onAdClickedCallback: (ad) {
              if (onShow != null) {
                onShow.onClick!(ad.adUnitId);
              }
            }, onAdHiddenCallback: (ad) {
              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(key);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
            }, onAdRevenuePaidCallback: (ad) {
              // 收益上报
              TbaUtils.instance.postAd(
                  ad_network: ad.networkName,
                  ad_pos_id: key,
                  ad_source: "max",
                  ad_unit_id: ad.adUnitId,
                  ad_format: "rewarded",
                  ad_pre_ecpm: ad.revenue.toString(),
                  currency: "",
                  precision_type: ad.revenuePrecision);
            }, onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
              //用户看完激励视频
            }));

            AppLovinMAX.showRewardedAd(ad_id);
            // loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        }
      } else if (source == "topon") {
        //增加topon

        if (type == "interstitial") {
          var isReady = await ATInterstitialManager.hasInterstitialAdReady(placementID: ad_id);
          if (isReady) {
            TopOnUtils.instance.interstitialStream?.cancel();
            TopOnUtils.instance.interstitialStream = null;

            TopOnUtils.instance.interstitialStream = ATListenerManager.interstitialEventHandler.listen((e) {
              if (e.interstatus == InterstitialStatus.interstitialFailedToShow) {
                //展示失败
                if (onShow != null) {
                  onShow.onShowFail!(e.placementID, AdError(-102, "", e.requestMessage));
                }
              } else if (e.interstatus == InterstitialStatus.interstitialDidShowSucceed) {
                //展示
                adIsShowing = true;
                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }

                var revenueData = e.extraMap;
                // 收益上报
                TbaUtils.instance.postAd(
                    ad_network: revenueData["network_name"] ?? "",
                    ad_pos_id: key,
                    ad_source: "topon",
                    ad_unit_id: revenueData["adunit_id"] ?? "",
                    ad_format: "interstitial",
                    ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
                    currency: revenueData["currency"] ?? "USD",
                    precision_type: revenueData["precision"] ?? "");
              } else if (e.interstatus == InterstitialStatus.interstitialAdDidClose) {
                //关闭
                adIsShowing = false;
                //设置显示时间以判断广告间隔
                setShowTime();
                //重新加载一轮广告
                loadAd(key);
                if (onShow != null) {
                  onShow.onClose!(e.placementID);
                }

                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }
              }
            });
            ATInterstitialManager.showInterstitialAd(placementID: ad_id);
            loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        } else if (type == "rewarded") {
          var isReady = await ATRewardedManager.rewardedVideoReady(placementID: ad_id);
          if (isReady) {
            TopOnUtils.instance.rewardedStream?.cancel();
            TopOnUtils.instance.rewardedStream = null;

            TopOnUtils.instance.rewardedStream = ATListenerManager.rewardedVideoEventHandler.listen((e) {
              if (e.rewardStatus == RewardedStatus.rewardedVideoDidFailToPlay) {
                //展示失败
                if (onShow != null) {
                  onShow.onShowFail!(e.placementID, AdError(-102, "", e.requestMessage));
                }
              } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidStartPlaying) {
                //展示
                adIsShowing = true;
                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }

                var revenueData = e.extraMap;
                // 收益上报
                TbaUtils.instance.postAd(
                    ad_network: revenueData["network_name"] ?? "",
                    ad_pos_id: key,
                    ad_source: "topon",
                    ad_unit_id: revenueData["adunit_id"] ?? "",
                    ad_format: "rewarded",
                    ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
                    currency: revenueData["currency"] ?? "USD",
                    precision_type: revenueData["precision"] ?? "");
              } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidClose) {
                //关闭
                adIsShowing = false;
                //设置显示时间以判断广告间隔
                setShowTime();
                //重新加载一轮广告
                loadAd(key);
                if (onShow != null) {
                  onShow.onClose!(e.placementID);
                }

                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }
              }
            });
            ATRewardedManager.showRewardedVideo(placementID: ad_id);
            loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        }
      }
    }

    //没有显示广告
    //重新加载
    if (!isShowAd) {
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "no ad show"));
      }
      loadAd(key);
    }
    return isShowAd;
  }
}

class MyNativeAdView extends GetView<MyNativeAdViewController> {
  final String adKey;
  final String positionKey;

  @override
  String? get tag => positionKey;

  const MyNativeAdView({super.key, required this.adKey, required this.positionKey});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MyNativeAdViewController(adKey, positionKey), tag: tag);
    return Container(alignment: Alignment.center, child: Obx(() => controller.adView.value));
  }
}

class MyNativeAdViewController extends GetxController {
  MyNativeAdViewController(this.adKey, this.positionKey);

  var adKey = "";
  var positionKey = "";

  Rx<Widget> adView = Container().obs;

  //0未加载 1admob 2max 3topon
  var loadType = 0;

  Ad? admobAd;

  loadAd(String key, String positionKey) async {
    adView.value = Container();

    var adJson = AdUtils.instance.adJson;
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告:$key");
      return;
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    AppLog.e("广告网络：$connectivityResult");
    if (!connectivityResult.contains(ConnectivityResult.wifi) && !connectivityResult.contains(ConnectivityResult.mobile)) {
      return;
    }

    //会员去除广告
    // if (Get.find<Application>().isVip.value) {
    //   return;
    // }

    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];
      AppLog.e("开始加载原生广告:$type,$source,$positionKey,$ad_id");

      var isOk = false;
      if (source == "admob") {
        if (type == "native") {
          var ad = await AdmobUtils.instance.loadNativeAd(ad_id, key, positionKey, adView);
          if (ad != null) {
            loadType = 1;
            isOk = true;
            admobAd = ad;
          }
        }
      } else if (source == "max") {
        if (type == "native") {
          // var ad= await AdmobUtils.instance
          //     .loadNativeAd(ad_id, key, positionKey, adView);
          var isLoadMaxAd = await MaxUtils.instance.loadNativeAd(ad_id, positionKey, adView);
          if (isLoadMaxAd) {
            loadType = 2;
          }
        }
      } else if (source == "topon") {
        if (type == "native") {
          var isLoadOk = await TopOnUtils.instance.loadNativeAd(ad_id, positionKey, adView);
          if (isLoadOk) {
            loadType = 3;
          }
        } else if (type == "banner") {
          var isLoadOk = await TopOnUtils.instance.loadBannerAd(ad_id, positionKey, adView);
          if (isLoadOk) {
            loadType = 3;
          }
        }
      }

      AppLog.e("结束加载原生广告:${isOk ? "成功" : "失败"}---$type,$source");
      if (isOk) {
        //加载成功跳出循环
        break;
      } else {
        //加载失败加载下一条
        continue;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAd(adKey, positionKey);
  }

  @override
  void onClose() {
    super.onClose();
    admobAd?.dispose();
  }
}

//加载回调
typedef LoadCallback = void Function(String adId, bool isOk, AdError? e);

//显示相关回调
typedef OnShow = void Function(String adId);
typedef OnClose = void Function(String adId);
typedef OnClick = void Function(String adId);
typedef OnShowFail = void Function(String? adId, AdError? e);

//显示回调
class ShowCallback {
  final OnShow? onShow;
  final OnClose? onClose;
  final OnClick? onClick;
  final OnShowFail? onShowFail;

  const ShowCallback({this.onShow, this.onClose, this.onClick, this.onShowFail});
}
