import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_muse/const/bus.dart';
import 'package:music_muse/util/log.dart';

class ConsentRequest {
  static final ConsentRequest instance = ConsentRequest._();

  ConsentRequest._();

  static const keyShowedGDPRObtained = "keyShowedGRPRObtained";

  Future<bool> startRequest() async {
    Completer<bool> completer = Completer();
    ConsentRequestParameters params = ConsentRequestParameters();
    // if (!kReleaseMode && Platform.isIOS) {
    //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    //   String testIdentifier = (await deviceInfo.iosInfo).identifierForVendor ?? "";
    //   ConsentDebugSettings debugSettings = ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: [testIdentifier]);
    //   params = ConsentRequestParameters(consentDebugSettings: debugSettings);
    // }
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadConsentForm(
            (ConsentForm consentForm) async {
              var status = await ConsentInformation.instance.getConsentStatus();
              if (status == ConsentStatus.required) {
                consentForm.show(
                  (FormError? formError) async {
                    AppLog.e("【ConsentRequest】formError1: message:${formError?.message}");
                    var status = await ConsentInformation.instance.getConsentStatus();
                    museSp.setBool(keyShowedGDPRObtained, status == ConsentStatus.obtained);
                    if (!completer.isCompleted) completer.complete(true);
                  },
                );
              } else {
                AppLog.e("【ConsentRequest】 completer 1");
                if (!completer.isCompleted) completer.complete(true);
              }
            },
            (formError) {
              if (!completer.isCompleted) completer.complete(true);
              AppLog.e("【ConsentRequest】formError2: message:${formError.message}");
            },
          );
        } else {
          AppLog.e("【ConsentRequest】 completer 2");
          if (!completer.isCompleted) completer.complete(true);
        }
      },
      (FormError error) {
        AppLog.e("【ConsentRequest】 completer 3, error:${error.message}");
        if (!completer.isCompleted) completer.complete(true);
      },
    );
    return completer.future;
  }

  void reset() {
    ConsentInformation.instance.reset();
  }

  bool get isGdprObtained {
    return museSp.getBool(keyShowedGDPRObtained);
  }
}
