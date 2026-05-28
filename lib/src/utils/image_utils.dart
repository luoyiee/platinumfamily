import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ImageUtil {

  static Widget loadLocalImage(BuildContext context, String assetPath,
      {double? width, double? height, BoxFit fit = BoxFit.cover, AlignmentGeometry? alignment}) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment ?? Alignment.center,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded||frame != null) {
          return child;
        }
        // 图片还在加载中，显示加载动画
        return buildLoadingAnimation(width: width, height: height);
      },
    );
  }

  static Widget loadLocalCircleImage(BuildContext context, String assetPath,
      {double? width,
        double? height,
        double borderWidth = 2.0,
        BoxFit fit = BoxFit.cover,
        Color borderColor = Colors.white}) {
    return ClipOval(
      child: Container(
        color: borderColor,
        padding: EdgeInsets.all(borderWidth),
        child: ClipOval(
          child: Image.asset(assetPath,
              width: width, height: height, fit: fit),
        ),
      ),
    );
  }

  static Widget buildLoadingAnimation({double? width, double? height}) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: LoadingAnimationWidget.flickr(
          leftDotColor: const Color(0xFFFF0084),
          rightDotColor: Colors.black,
          size: 35,
        ),
      ),
    );
  }

}
