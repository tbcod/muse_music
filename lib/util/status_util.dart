import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

getWhiteBarStyle() {
  return SystemUiOverlayStyle(
      //设置状态栏颜色
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark);
}

getBlackBarStyle() {
  return SystemUiOverlayStyle(
      //设置状态栏颜色
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light);
}
