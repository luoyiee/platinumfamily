import 'package:earlybird/src/constants/constants.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import 'js_utils.dart';
import 'package:web/web.dart' as web;


class CommonUtil{

  /// 判断是否为平板  适用于原生访问网页
  static bool isTablet(BuildContext context) {
    // 推荐使用最短边，因为这样在横屏和竖屏模式下都能正确判断
    return MediaQuery.of(context).size.shortestSide >= cTabletMinWidth;
  }

  /// 判断是否为横屏
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// 获取对话框最大宽度
  static double commonDialogWidth(BuildContext context) {
    return CommonUtil.isTablet(context) ? 448 : MediaQuery.of(context).size.width - 32;
  }
  /// 布局方向
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  static void openUrl(String url) {
    if (isIos) {
      web.window.location.href = url;
    } else {
      web.window.open(url, '_blank');
    }
  }

  /// 需适配安全区
  static String getFitSystemWindowsUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(queryParameters: {...uri.queryParameters, 'fitSystemWindows': 'true'}).toString();
  }

  static bool unSupportNewJs() {
    return isIos && versionCode! <= 892033470 || !isIos && versionCode! <= 891003459;
  }

  /// px 转换为 dp
  static int pxToDp(BuildContext context, int pxValue) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (pxValue / devicePixelRatio).round();
  }

  /// 获取顶部状态栏高度
  static getSafeBarTop() {
    consoleLog('getSafeBarTop: ${(safeBarTop > 0 ? safeBarTop : statusBarHeight).toDouble()}');
    return (safeBarTop > 0 ? safeBarTop : statusBarHeight).toDouble();
  }

  /// 获取底部导航栏高度
  static getSafeBarBottom() {
    return (safeBarBottom > 0 ? safeBarBottom : cBottomNavBarHeight).toDouble();
  }

  /// 获取顶部标题栏高度
  /// 平板使用 cSw600TopBarHeight，手机使用 cTopBarHeight
  static getTopBarHeight(BuildContext context) {
    consoleLog('getTopBarHeight: $topBarHeight');
    if (topBarHeight > 0) return topBarHeight;
    return isTablet(context) ? cSw600TopBarHeight : cTopBarHeight;
  }

}