import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnlyWeb extends GetView<OnlyWebController> {
  const OnlyWeb({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => OnlyWebController());
    var isLoading = true.obs;
    //1用户协议2隐私政策
    var type = Get.arguments;
    var url = "https://";
    var title = "";
    //TODO 隐私和协议
    if (type == 1) {
      url = GetPlatform.isIOS
          ? "https://littlemusicmuse.com/MusicMuse-Termsofuse.html"
          : "https://musicmuseapp.com/music%20muse-and-terms.html";
      title = "Terms of Service".tr;
    } else if (type == 2) {
      url = GetPlatform.isIOS
          ? "https://littlemusicmuse.com/MusicMuse-PrivacyPolicy.html"
          : "https://musicmuseapp.com/music%20muse-and-privacy.html";
      title = "Privacy Policy".tr;
    }

    var webC = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoading.value = false;
          },
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('https://www.youtube.com/')) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ),
      )
      ..loadRequest(Uri.parse(url));

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
              children: [
                AppBar(
                  title: Text(title),
                ),
                Expanded(
                    child: Container(
                  child: Obx(() => isLoading.value
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : WebViewWidget(controller: webC)),
                )),
                SizedBox(
                  height: Get.mediaQuery.padding.bottom,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class OnlyWebController extends GetxController {}
