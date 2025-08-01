import 'dart:ui';

import 'package:get/get.dart';
import 'package:music_muse/lang/de_de.dart';
import 'package:music_muse/lang/es_es.dart';
import 'package:music_muse/lang/fr_fr.dart';
import 'package:music_muse/lang/pt_pt.dart';
import 'package:music_muse/lang/zh_cn.dart';

import 'en_us.dart';

class MyTranslations extends Translations {
  static Locale locale = Get.deviceLocale ?? const Locale("en", "US");

  static const fallbackLocale = Locale("en", "US");

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'zh_CN': zhCN,
        'de_DE': deDE,
        "fr_FR": frFR,
        "es_ES": esES,
        "pt_PT": ptPT,
      };
}
