import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BaseDialog extends GetView {
  final String? title;
  final String? content;
  final String? lBtnText;
  final String? rBtnText;
  final VoidCallback? lBtnOnTap;
  final VoidCallback? rBtnOnTap;
  final bool single;
  final bool canDismiss;
  final bool callbackBeforeClose;
  final Color mainColor;
  final Widget? contentView;

  const BaseDialog(
      {Key? key,
      this.title,
      this.content,
      this.lBtnText,
      this.rBtnText,
      this.lBtnOnTap,
      this.rBtnOnTap,
      this.single = false,
      this.callbackBeforeClose = false,
      this.contentView,
      this.canDismiss = true,
      this.mainColor = const Color(0xff7453FF)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!canDismiss) {
          return;
        }
        Get.back();
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 25.w),
        backgroundColor: Colors.transparent,
        // shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.w),
              decoration: BoxDecoration(
                  color: Color(0xff202020),
                  gradient: LinearGradient(
                      colors: [Color(0xffEAEAFF), Color(0xffFAFAFA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(24.w)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? "",
                    style: TextStyle(fontSize: 20.w, color: Colors.black),
                  ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Text(
                    content ?? "",
                    style: TextStyle(fontSize: 14.w, color: Colors.black),
                  ),
                  SizedBox(
                    height: 32.w,
                  ),
                  Container(
                    height: 40.w,
                    width: double.infinity,
                    child: Row(
                      children: single
                          ? [
                              Expanded(
                                  child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (rBtnOnTap != null) {
                                    rBtnOnTap!();
                                  }
                                  Get.back();
                                },
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.w),
                                      color: mainColor),
                                  child: Text(
                                    rBtnText ?? "",
                                    style: TextStyle(
                                        fontSize: 14.w, color: Colors.white),
                                  ),
                                ),
                              ))
                            ]
                          : [
                              Expanded(
                                  child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (lBtnOnTap != null) {
                                    lBtnOnTap!();
                                  }
                                  Get.back();
                                },
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.w),
                                      // color: Colors.white.withOpacity(0.15)

                                      border: Border.all(
                                          color: mainColor, width: 2.w)),
                                  child: Text(
                                    lBtnText ?? "",
                                    style: TextStyle(
                                        fontSize: 14.w, color: mainColor),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: 23.w,
                              ),
                              Expanded(
                                  child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (rBtnOnTap != null) {
                                    rBtnOnTap!();
                                  }
                                  Get.back();
                                },
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.w),
                                      color: mainColor),
                                  child: Text(
                                    rBtnText ?? "",
                                    style: TextStyle(
                                        fontSize: 14.w, color: Colors.white),
                                  ),
                                ),
                              )),
                            ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BaseDialog2 extends GetView {
  final String? title;
  final String? content;
  final String? lBtnText;
  final String? rBtnText;
  final VoidCallback? lBtnOnTap;
  final VoidCallback? rBtnOnTap;
  final bool single;
  final bool callbackBeforeClose;
  final Color mainColor;
  final Widget? contentView;

  const BaseDialog2(
      {Key? key,
      this.title,
      this.content,
      this.lBtnText,
      this.rBtnText,
      this.lBtnOnTap,
      this.rBtnOnTap,
      this.single = false,
      this.callbackBeforeClose = false,
      this.contentView,
      this.mainColor = Colors.blue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Center(
        child: Text(
          title ?? "提示",
        ),
      ),
      content: contentView ??
          Text(
            content ?? "",
          ),
      actions: single
          ? [
              CupertinoDialogAction(
                onPressed: () {
                  if (callbackBeforeClose) {
                    if (rBtnOnTap != null) {
                      rBtnOnTap!();
                    }
                  }
                  Get.back();
                  if (!callbackBeforeClose) {
                    if (rBtnOnTap != null) {
                      rBtnOnTap!();
                    }
                  }
                },
                // isDestructiveAction: true,
                isDefaultAction: true,
                child: Text(rBtnText ?? "确定"),
              ),
            ]
          : [
              CupertinoDialogAction(
                onPressed: () {
                  if (callbackBeforeClose) {
                    if (lBtnOnTap != null) {
                      lBtnOnTap!();
                    }
                  }
                  Get.back();
                  if (!callbackBeforeClose) {
                    if (lBtnOnTap != null) {
                      lBtnOnTap!();
                    }
                  }
                },
                child: Text(lBtnText ?? "取消"),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (callbackBeforeClose) {
                    if (rBtnOnTap != null) {
                      rBtnOnTap!();
                    }
                  }
                  Get.back();
                  if (!callbackBeforeClose) {
                    if (rBtnOnTap != null) {
                      rBtnOnTap!();
                    }
                  }
                },
                //加粗
                isDefaultAction: true,
                //强调色
                // isDestructiveAction: true,
                // textStyle: const TextStyle(color: AppColor.mainColor),
                child: Text(rBtnText ?? "确定"),
              ),
            ],
    );
  }
}
