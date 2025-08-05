import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:music_muse/muse_config.dart';

class AppLog {
  static void print(dynamic msg, {bool isErr = false}) {
    if (!MuseConfig.isUser) {
      String callerInfo = "";
      final stackTrace = StackTrace.current.toString().split("\n");
      if (stackTrace.length > 2) {
        callerInfo = stackTrace[2];
        callerInfo = callerInfo.replaceAll("#2", "");
        callerInfo = callerInfo.replaceAll(".<anonymous closure>", "");
        callerInfo = callerInfo.trim();
      }
      if (isErr) {
        log("$callerInfo $msg", name: "MuseLog❌");
      } else {
        log("$callerInfo $msg", name: "MuseLog✅");
      }
    } else {
      // if (isErr) {
      //   print("【N9Log】❌$msg");
      // } else {
      //   print("【N9Log】✅$msg");
      // }
    }
  }

  // static var logger = Logger(printer: PrettyPrinter(colors: false), level: Level.debug);
  //
  // static bool get isLog {
  //   if (MuseConfig.isUser) return false;
  //   return true;
  // }
  //
  // static set level(Level value) {
  //   Logger.level = value;
  // }

  static void v(dynamic message) {
    // if (!isLog) return;
    // logger.t(message);
  }

  static void i(dynamic message) {
    // if (!isLog) return;
    // logger.i(message);
    print(message);
  }

  static void d(dynamic message) {
    // if (!isLog) return;
    // logger.d(message);
    print(message);
  }

  static void w(dynamic message) {
    // if (!isLog) return;
    // logger.w(message);
    print(message);
  }

  static void e(dynamic message) {
    // if (!isLog) return;
    // logger.e(message);
    print(message, isErr: true);
  }

  static void wtf(dynamic message) {
    // if (!isLog) return;
    // logger.f(message);
    print(message);
  }
}

// class LoggerFilter extends LogFilter {
//   @override
//   bool shouldLog(LogEvent event) {
//     return true;
//   }
// }
