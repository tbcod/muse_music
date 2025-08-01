import 'dart:math';
import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:music_muse/lang/my_tr.dart';
import 'package:music_muse/u_page/main/u_home.dart';
import 'package:music_muse/u_page/main/u_library.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/ad/admob_util.dart';
import 'package:music_muse/util/ad/max_util.dart';
import 'package:music_muse/util/ad/topon_util.dart';
import 'package:music_muse/util/history_util.dart';
import 'package:music_muse/util/like/like_util.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:music_muse/util/tba/tba_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import 'const/db_key.dart';
import 'const/env.dart';

///可存放所有全局变量（如token,启动图等），跟随应用生命周期，不重启不会被销毁
class Application extends GetxService {
  String userAppUuid = "";

  var isMainPage = false.obs;

  var visitorData = "";

  //使用的资源  no/yt/ytm
  var typeSo = "no";

  var isAppBack = false;

  Future<Application> init() async {
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        1024 * 1024 * 1024 * 5; //设置缓存为5GB，避免图片太多经常重新加载
    //竖屏
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //沉浸状态栏
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark));

    final sp = await SharedPreferences.getInstance();
    //设置设备的uuid,每次重新安装后不一样
    userAppUuid = sp.getString("userAppUuid") ?? "";
    if (userAppUuid.isEmpty) {
      userAppUuid = const Uuid().v4();
      await sp.setString("userAppUuid", userAppUuid);
    }

    //设置语言
    var lastLangCode = sp.getString("lastLangCode") ?? "";
    var lastLangCountryCode = sp.getString("lastLangCountryCode") ?? "";
    if (lastLangCode.isNotEmpty) {
      MyTranslations.locale = Locale(lastLangCode, lastLangCountryCode);
    }

    await initLocTypeSo();

    //设置下拉刷新
    EasyRefresh.defaultHeaderBuilder = () {
      return const ClassicHeader(
          iconTheme: IconThemeData(color: Color(0xff8569FF)),
          showMessage: false,
          showText: false,
          infiniteHitOver: true,
          processedDuration: Duration.zero);
    };

    EasyRefresh.defaultFooterBuilder = () {
      return ClassicFooter(
          iconTheme: const IconThemeData(color: Color(0xff8569FF)),
          failedText: "loadMoreFailStr".tr,
          noMoreText: "noMoreStr".tr,
          textStyle: const TextStyle(color: Colors.black),
          showMessage: false,
          infiniteHitOver: true,
          processedDuration: Duration.zero);
    };

    await initHive();
    await initAppsflyer();

    await initSdk();

    return this;
  }

  AppsflyerSdk? appsflyerSdk;
  initAppsflyer() async {
    if (!Env.isUser) {
      return;
    }

    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: Env.isUser ? "XrT2fnS7Vhxh9w3YLjHtGS" : "",
      appId: "6667107568",
      showDebug: !Env.isUser,
    );
    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    var appsflyerData = await appsflyerSdk?.initSdk(
      registerConversionDataCallback: true,
      // registerOnAppOpenAttributionCallback: true,
      // registerOnDeepLinkingCallback: true,
    );
    AppLog.e("appsflyerSdk init ok,$appsflyerData");
    appsflyerSdk?.setCustomerUserId(userAppUuid);
  }

  Future initHive() async {
    var path = await getApplicationSupportDirectory();
    Hive.init(path.path);
  }

  Future<void> initSdk() async {
    await Firebase.initializeApp();
    AppLog.e("firebase初始化完成");
    //异步，否则会卡在启动
    initFireBaseOther();

    initAd();
  }

  initFireBaseOther() async {
    //测试环境异常上报
    if (!Env.isUser) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    if (Env.isUser) {
      AdUtils.instance.adJson = AdUtils.instance.adJsonRelease;
      if (GetPlatform.isIOS) {
        AdUtils.instance.adJson = AdUtils.instance.adJsonIosRelease;
      }
      var adData = await AdUtils.instance.initJsonByFireBase();
      AppLog.e("广告配置");
      AppLog.e(adData);
    } else {
      if (GetPlatform.isIOS) {
        AdUtils.instance.adJson = AdUtils.instance.adJsonIos;
      }
      var adData = await AdUtils.instance.initJsonByFireBase();
      AppLog.e("广告配置");
      AppLog.e(adData);
    }
  }

  initAd() {
    AdmobUtils.instance.init();
    MaxUtils.instance.init();
    TopOnUtils.instance.init();
  }

  changeTypeSo(String str) async {
    if (typeSo == str) {
      //和上次一样不切换源
      return;
    }
    AppLog.e("typeSo切换了数据：$typeSo");

    typeSo = str;
    //保存到本地

    TbaUtils.instance.postUserData({"mm_type_so": typeSo});
    var sp = await SharedPreferences.getInstance();
    sp.setString("lastTypeSo", typeSo);
    //删除之前源的所有
    //删除各种收藏
    await LikeUtil.instance.clearAll();
    LikeUtil.instance.removeNewState(1);
    LikeUtil.instance.removeNewState(2);
    //删除本地歌单
    var box = await Hive.openBox(DBKey.myPlayListData);
    await box.clear();

    if (Get.isRegistered<UserLibraryController>()) {
      Get.find<UserLibraryController>().bindMyPlayListData();
    } else if (Get.isRegistered<UserHomeController>()) {
      Get.find<UserHomeController>().reloadHistory();
    }

    AppLog.e("nowtypeso:$typeSo");
  }

  Future initLocTypeSo() async {
    var sp = await SharedPreferences.getInstance();
    typeSo = sp.getString("lastTypeSo") ?? "no";

    AppLog.e("nowtypeso:$typeSo");
  }

  Future initNetPush() async {
    if (!Env.isUser) {
      return;
    }

    AppLog.e("开始初始化推送");
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    AppLog.e(settings.authorizationStatus.name);

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      AppLog.e("推送token:$fcmToken");
      // await Clipboard.setData(ClipboardData(text: fcmToken ?? ""));
      // a terminated state.
    } catch (e) {
      print(e);
    }

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      //点击消息进入
      EventUtils.instance.addEvent("push_click");
    }

    FirebaseMessaging.onMessage.listen((event) {
      //前台收到消息
      EventUtils.instance.addEvent("push_show");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      //后台收到消息
      EventUtils.instance.addEvent("push_show");
    });
    // FirebaseMessaging.onBackgroundMessage(())

    //订阅频道
    // await FirebaseMessaging.instance.subscribeToTopic("");
  }

  Future initLocPush() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final InitializationSettings initializationSettings =
        const InitializationSettings(iOS: DarwinInitializationSettings());

    var d =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (d != null) {
      EventUtils.instance.addEvent("push_click");
    }
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      // 处理用户点击通知后的回调逻辑，例如打开对应的页面等，按需编写逻辑
      EventUtils.instance.addEvent("push_click");
    });

    // initializeTimeZones();
  }

  Future<Map> getRandomItem(List list) async {
    var sp = await SharedPreferences.getInstance();

    var rIndex = Random().nextInt(list.length);
    String lastId = sp.getString("lastPushSongId") ?? "-";

    String nowId = list[rIndex]["videoId"] ?? "";
    if (nowId == lastId) {
      //重新随机
      return getRandomItem(list);
    }
    await sp.setString("lastPushSongId", nowId);
    return list[rIndex];
  }

  pushLocNotification(tz.TZDateTime tzDate, int nId) async {
    await HistoryUtil.instance.initData();

    List historySongList = List.of(HistoryUtil.instance.songHistoryList);
    if (historySongList.isEmpty) {
      //没有历史数据推送
      return;
    }

    //随机一首
    Map item = await getRandomItem(historySongList);

    // EventUtils.instance.addEvent("push_show");

    await FlutterLocalNotificationsPlugin().zonedSchedule(
        nId,
        "Music Muse",
        "${"Listen now".tr}\n${item["title"]}",
        tzDate,
        const NotificationDetails(
            iOS: DarwinNotificationDetails(
          presentBadge: true,
          badgeNumber: 1,
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        )),
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exact);
  }
}
