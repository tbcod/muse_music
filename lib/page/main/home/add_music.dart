import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddMusic extends GetView<AddMusicController> {
  const AddMusic({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AddMusicController());
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: 146.w,
              width: double.infinity,
              decoration: BoxDecoration(
                  // color: Colors.red,
                  image: DecorationImage(
                image: AssetImage("assets/img/all_appbar_bg.png"),
                fit: BoxFit.fill,
              )),
            ),
            Positioned.fill(
                child: Column(
              children: [AppBar(), Expanded(child: Container())],
            ))
          ],
        ),
      ),
    );
  }
}

class AddMusicController extends GetxController {}
