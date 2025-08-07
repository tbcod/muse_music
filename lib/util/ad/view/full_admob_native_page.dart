import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
      Future.delayed(const Duration(milliseconds: 1000)).then((v) {
        _closeType.value = CloseType.normal;
        _curSec.value = -1;
      });
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
        body: Center(
          child: Stack(
            children: [
              StatefulBuilder(builder: (context, a) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 300, minHeight: 320, maxWidth: 300, maxHeight: 360),
                  child: AdWidget(ad: widget.ad, key: UniqueKey()),
                );
              }),
              Obx(() {
                return Visibility(
                  visible: _curSec.value >= 0,
                  child: Positioned(
                    right: 8,
                    top: 8,
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
                return Visibility(
                  visible: _closeType.value == CloseType.disable,
                  child: Positioned(
                      right: 8,
                      top: 8,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.close_rounded, size: 24, color: Colors.black38),
                          ),
                        ),
                      )),
                );
              }),
              Obx(() {
                return Visibility(
                  visible: _closeType.value == CloseType.normal || _closeType.value == CloseType.limit,
                  child: Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.close_rounded, size: 24, color: Colors.black54),
                          ),
                        ),
                      )),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    widget.onClose.call();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
