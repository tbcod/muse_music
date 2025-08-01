import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class NetImageView extends GetView {
  final double? width;
  final double? height;
  final String imgUrl;
  final String? errorAsset;
  final BoxFit fit;
  final Color? bgColor;
  const NetImageView({
    Key? key,
    required this.imgUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorAsset,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (c, url) {
        return errorAsset == null
            ? Container(
                color: bgColor ?? Colors.black.withOpacity(0.08),
                // child: const Center(
                //   child: Icon(Icons.error),
                // ),
              )
            : Image.asset(
                errorAsset!,
                fit: BoxFit.cover,
              );

        // return Container(
        //   color: bgColor ?? Colors.black.withOpacity(0.08),
        //   // child: const Center(
        //   //   child: CircularProgressIndicator(),
        //   // ),
        // );
      },
      errorWidget: (c, url, error) {
        // return Container(
        //   color: bgColor ?? Colors.black.withOpacity(0.08),
        // );

        return errorAsset == null
            ? Container(
                color: bgColor ?? Colors.black.withOpacity(0.08),
                // child: const Center(
                //   child: Icon(Icons.error),
                // ),
              )
            : Image.asset(
                errorAsset!,
                fit: BoxFit.cover,
              );
      },
    );
  }
}

class NetAvatarView extends GetView {
  final double size;
  final String imgUrl;
  final String errorAsset;
  final double borderWidth;
  final Color borderColor;
  final Color bgColor;
  const NetAvatarView(
      {Key? key,
      required this.imgUrl,
      this.size = 40,
      this.borderWidth = 0,
      this.borderColor = Colors.grey,
      this.bgColor = Colors.grey,
      this.errorAsset = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: size / 2 - borderWidth / 2,
        backgroundImage: errorAsset.isEmpty
            ? null
            : AssetImage(
                errorAsset,
              ),
        backgroundColor: bgColor,
        foregroundImage: CachedNetworkImageProvider(
          imgUrl,
        ),
        onForegroundImageError: (o, e) {},
      ),
    );
  }
}
