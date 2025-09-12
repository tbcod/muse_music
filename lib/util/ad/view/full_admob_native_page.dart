import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/page/main/home/play.dart';
import 'package:music_muse/u_page/main/home/u_play.dart';
import 'package:music_muse/util/ad/ad_util.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/remote_utils.dart';

enum CloseType { normal, limit, disable, hide }

class FullAdmobNativePage extends StatefulWidget {
  const FullAdmobNativePage({super.key, required this.ad, required this.onClose});

  final NativeAd ad;
  final VoidCallback onClose;

  @override
  State<FullAdmobNativePage> createState() => _FullAdmobNativePageState();
}

class _FullAdmobNativePageState extends State<FullAdmobNativePage> {
  int maxSec = RemoteUtil.shareInstance.adNativeCountDown;
  final _curSec = 0.obs;
  Timer? _timer;
  bool _isDarkMode = false;
  StreamSubscription? _streamSubscription;

  late NativeAd nativeAd;

  final _closeType = CloseType.hide.obs;

  @override
  void initState() {
    nativeAd = widget.ad;
    _isDarkMode = true;
    if (maxSec == 0) {
      _curSec.value = -1;
      _showCloseBtn();
    } else {
      _curSec.value = maxSec;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        _curSec.value = _curSec.value - 1;
        if (_curSec.value < 0) {
          _curSec.value = -1;
          _timer?.cancel();
          _timer = null;
          _showCloseBtn();
        }
      });
    }

    _streamSubscription = AdUtils.instance.bannerNativeAdClicked.listen((val) {
      _closeType.value = CloseType.normal;
      _curSec.value = -1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (Get.isRegistered<UserPlayInfoController>()) {
        Get.find<UserPlayInfoController>().hideFloatingWidget();
      }
      if (Get.isRegistered<PlayPageController>()) {
        Get.find<PlayPageController>().hideFloatingWidget();
      }
    });
    super.initState();
  }

  _showCloseBtn() {
    if (RemoteUtil.shareInstance.adNativeScreenClick == 0) {
      _closeType.value = CloseType.normal;
    } else {
      int rate = RemoteUtil.shareInstance.adNativeScreenClick;
      if (rate >= 100) {
        _closeType.value = CloseType.disable;
      } else {
        final random = Random().nextInt(100);
        bool result = random < rate;
        AppLog.i("random=$random,rate=$rate, 跳转=$result");
        _closeType.value = result ? CloseType.disable : CloseType.limit;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
          decoration: const BoxDecoration(
              gradient: LinearGradient(end: Alignment.bottomCenter, begin: Alignment.topCenter, colors: [Color(0xffa79efe), Color(0xff5d60dc)])),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: StatefulBuilder(builder: (context, a) {
                  try {
                    return SizedBox(
                      height: 620,
                      child: AdWidget(ad: widget.ad, key: UniqueKey()),
                    );
                  } catch (e) {
                    AppLog.e("报错了：${e.toString()}");
                    _closeType.value = CloseType.normal;
                    return const SizedBox.shrink();
                  }
                }),
              ),
              Obx(() {
                return Visibility(
                  visible: _curSec.value >= 0,
                  child: Positioned(
                    right: 20,
                    top: 24,
                    child: Container(
                        alignment: Alignment.center,
                        width: 24,
                        height: 24,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                                strokeWidth: 1.5,
                                value: 1 - _curSec.value / maxSec,
                                backgroundColor: _isDarkMode ? Colors.white24 : Colors.black12,
                                valueColor: AlwaysStoppedAnimation(_isDarkMode ? Colors.white : Colors.black45)),
                            Text(
                              "${max(_curSec.value, 0)}s",
                              style: const TextStyle(fontSize: 10, color: Color(0xffbfbfbf)),
                            ),
                          ],
                        )),
                  ),
                );
              }),
              Obx(() {
                return Positioned(
                    left: 20,
                    top: 24,
                    child: _closeType.value == CloseType.disable
                        ? IgnorePointer(
                            ignoring: true,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(11)),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.close_rounded, size: 20, color: Colors.black38),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              AppLog.i("关闭点击");
                              Get.back();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(11)),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.close_rounded, size: 20, color: Colors.black54),
                              ),
                            ),
                          ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    final previous = Get.routing.previous;
    if(!previous.contains("BOTTOMSHEET")){
      Future.delayed(const Duration(seconds: 1)).then((v){
        if (Get.isRegistered<UserPlayInfoController>()) {
          Get.find<UserPlayInfoController>().showFloatingWidget();
        }
        if (Get.isRegistered<PlayPageController>()) {
          Get.find<PlayPageController>().showFloatingWidget();
        }
      });
    }
    widget.onClose.call();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _timer?.cancel();
    _timer = null;
    AdUtils.instance.adIsShowing = false;
    super.dispose();
  }
}
