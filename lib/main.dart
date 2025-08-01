import 'package:bot_toast/bot_toast.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/lang/my_tr.dart';
import 'package:music_muse/page/launch.dart';
import 'package:music_muse/page/main_page.dart';
import 'package:music_muse/u_page/main/home/u_play.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/status_util.dart';
import 'package:music_muse/util/tba/event_util.dart';
import 'package:music_muse/util/tba/tba_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'const/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => Application().init());
  runApp(const MyApp());
}

class MyApp extends GetView {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // bindData();
    Get.put(AppController());
    final botToastBuilder = BotToastInit();
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, otherChild) {
          return GetMaterialApp(
            // color: Color(0xffECECF4),
            builder: (c, child) {
              child = GestureDetector(
                child: Container(
                  // decoration: BoxDecoration(
                  //     color: Color(0xffECECF4),
                  //     image: DecorationImage(
                  //         fit: BoxFit.fill,
                  //         image: AssetImage("assets/img/bg_all.png"))),
                  child: child,
                ),
                onTap: () {
                  //空白处收起键盘
                  Get.focusScope?.unfocus();
                },
              );

              child = botToastBuilder(c, child);
              return child;
            }, //1. call BotToastInit
            navigatorObservers: [
              BotToastNavigatorObserver()
            ], //2. registered route observer
            theme: ThemeData(
                scaffoldBackgroundColor: const Color(0xfff9f9f9),
                splashColor: Colors.transparent, // 点击时的高亮效果设置为透明
                highlightColor: Colors.transparent, // 长按时的扩散效果设置为透明

                textTheme: const TextTheme(
                  bodyMedium: TextStyle(height: 1.2),
                ),
                bottomSheetTheme: BottomSheetThemeData(
                    modalBarrierColor: Colors.red.withOpacity(0.43)),
                appBarTheme: AppBarTheme(
                    systemOverlayStyle: getWhiteBarStyle(),
                    foregroundColor: Colors.black,
                    scrolledUnderElevation: 0,
                    titleSpacing: 0,
                    elevation: 0,
                    centerTitle: true,
                    titleTextStyle: TextStyle(
                        fontSize: 18.w,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    backgroundColor: Colors.transparent)),
            title: Env.appName,
            debugShowCheckedModeBanner: false,
            home: const LaunchPage(),
            locale: MyTranslations.locale,
            fallbackLocale: MyTranslations.fallbackLocale,
            translations: MyTranslations(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              // Locale('cn', 'US'),
              Locale('zh', 'CN'),
            ],

            routingCallback: (Routing? routing) async {
              //路由跳转
              if (routing?.current == "/MainPage" ||
                  routing?.current == "/UserMain") {
                Get.find<Application>().isMainPage.value = true;
              } else {
                Get.find<Application>().isMainPage.value = false;
              }
            },
          );
        });
  }
}

class AppController extends SuperController {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  void onInit() async {
    super.onInit();
    bindData();
  }

  bindData() async {
    TbaUtils.instance.postSession();
    var sp = await SharedPreferences.getInstance();
    var isPostInstall = sp.getBool("isPostInstall") ?? false;

    AppLog.e("是否已经安装上报:$isPostInstall");

    if (!isPostInstall) {
      // var isNewUser = false;
      //安装时间
      await sp.setInt("installTimeMs", DateTime.now().millisecondsSinceEpoch);
      //安装上报
      TbaUtils.instance.postInstall().then((value) {
        AppLog.e("安装上报:${value.toJson()}");
        sp.setBool("isPostInstall", true);
        TbaUtils.instance.postUserData({"mm_new_user": "new"});
      });
    } else {
      //已经安装过了，先判断是否已经上报次留
      // var isPostRated = sp.getBool("isPostRated") ?? false;
      // if (!isPostRated) {
      //   //判断是否是次留
      //   var installTimeMs = sp.getInt("installTimeMs") ?? 0;
      //   var tempTime = DateTime.fromMillisecondsSinceEpoch(installTimeMs)
      //       .add(Duration(days: 1));
      //   var nowT = DateTime.now();
      //   if (tempTime.year == nowT.year &&
      //       tempTime.month == nowT.month &&
      //       tempTime.day == nowT.day) {
      //     //是次留
      //     FacebookAppEvents().logRated();
      //     sp.setBool("isPostRated", true);
      //   }
      // }

      //判断是否新用户
      var isNewUser = false;
      var installTimeMs = sp.getInt("installTimeMs") ?? 0;
      var tempD = DateTime.fromMillisecondsSinceEpoch(installTimeMs)
          .difference(DateTime.now());
      isNewUser = tempD.inHours < 24;
      TbaUtils.instance
          .postUserData({"mm_new_user": isNewUser ? "new" : "old"});
    }

    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach(
      (state) async {
        if (state == AppState.foreground) {
          Get.find<Application>().isAppBack = false;
          AppLog.e("前台");
          TbaUtils.instance.postSession();

          //判断新老用户
          var isNewUser = false;
          var installTimeMs = sp.getInt("installTimeMs") ?? 0;
          var tempD = DateTime.fromMillisecondsSinceEpoch(installTimeMs)
              .difference(DateTime.now());
          isNewUser = tempD.inHours < 24;
          TbaUtils.instance
              .postUserData({"mm_new_user": isNewUser ? "new" : "old"});

          AdUtils.instance.showAd("open");
        } else if (state == AppState.background) {
          Get.find<Application>().isAppBack = true;
          AppLog.e("后台");
          //判断是否在播放
          try {
            if (Get.find<UserPlayInfoController>().player?.value.isPlaying ??
                false) {
              await Future.delayed(const Duration(milliseconds: 100));
              await Get.find<UserPlayInfoController>().player?.play();
              await Future.delayed(const Duration(milliseconds: 100));
              await Get.find<UserPlayInfoController>().player?.play();
              await Future.delayed(const Duration(milliseconds: 100));
              await Get.find<UserPlayInfoController>().player?.play();
              EventUtils.instance.addEvent("background_play");
            }
          } catch (e) {
            print(e);
          }
        }
      },
    );

    // TbaUtils.instance.postUserData({"mm_new_user": "old"});
    // TbaUtils.instance.postUserData({"mm_type_so": "ytm"});
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() async {
    AppLog.e("-切换到后台");
    // try {
    //   if (Get.find<UserPlayInfoController>().player?.value.isPlaying ?? false) {
    //     await Future.delayed(Duration(milliseconds: 100));
    //     await Get.find<UserPlayInfoController>().player?.play();
    //     await Future.delayed(Duration(milliseconds: 100));
    //     await Get.find<UserPlayInfoController>().player?.play();
    //     await Future.delayed(Duration(milliseconds: 100));
    //     await Get.find<UserPlayInfoController>().player?.play();
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }

  @override
  void onResumed() async {
    AppLog.e("-切换到前台");
  }

  @override
  void onHidden() {}
}
