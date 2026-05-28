import 'package:flutter/material.dart';

// https://share.lanhuapp.com/#/invite?sid=lX3AblY7
// https://share.lanhuapp.com/#/invite?sid=lXYzSlx7
// https://mastergo.com/goto/Pr5SudCx?page_id=0:70&file=107289336695678
class JTColorStyle {


  /// 主题色
  static const Color themeColor = Color(0xFFFF2C55);

  /// 主要文本色
  static const Color primaryTextColor = Color(0xFF262626);

  /// 次要文本色
  static const Color secondaryTextColor = Color(0xFFAAAAAA);

  /// 正确、成功相关颜色
  static const Color successColor = Color(0xFF30D270);

  /// 失败、警示相关颜色
  static const Color failureColor = Color(0xFFF44336);

  /// 不可按的文本色
  static final Color disableTextColor = primaryTextColor.withValues(alpha: 0.26);

  /// 分割线的颜色
  static const Color dividerColor = Color(0xFFE8E8E8);

  /// 类似分割线区域的颜色
  static const Color dividerSimilarColor = Color(0xFFFAFAFA);

  /// 一级页面的背景色
  static const Color primaryBgColor = Colors.white;

  /// 一般用来设置二级页面的背景色, 也用来设置 scaffold 默认背景色; 以及输入框的颜色
  static const Color secondaryBgColor = Color(0xFFF6F6F6);

  /// 弹框蒙层的背景色
  static final Color maskBgColor = Colors.black.withValues(alpha: 0.5);

  /// 水波纹颜色
  static final Color splashColor = const Color(0XFF999999).withValues(alpha: 0.2);

  /// dialog 背景色
  static const Color dialogBgColor = Colors.white;

  /// dialog 背景色-深色模式
  static const Color dialogBgColorDark = Color(0xff333333);

  /// dialog 按钮背景色
  static const Color dialogBtnBgColor = Color(0xFFFF2C55);

  /// dialog 按钮背景色-深色模式
  static const Color dialogBtnBgColorDark = Color(0xffEF6479);

  /// dialog 按钮背景色-Pressed
  static  Color dialogBtnBgColorPressed = Colors.white.withValues(alpha: 0.26);

  /// dialog 底部按钮文本颜色
  static const Color dialogBottomBtnTextColor = secondaryTextColor;

  /// dialog 底部按钮文本颜色-深色模式
  static const Color dialogBottomBtnTextColorDark = Color(0xb3ffffff);

  /// dialog 底部按钮背景颜色
  static Color dialogBottomBtnBgColor = Color(0xff999999).withValues(alpha: 0.2);

  /// dialog 底部按钮背景颜色-深色模式
  static Color dialogBottomBtnBgColorDark = Color(0xffcccccc).withValues(alpha: 0.25);

  static getDialogBgColor(bool isDark) {
    return isDark ? dialogBgColorDark : dialogBgColor;
  }

  static getDialogBtnBgColor(bool isDark) {
    return isDark ? dialogBtnBgColorDark : dialogBtnBgColor;
  }

  static getDialogBottomBtnTextColor(bool isDark) {
    return isDark ? dialogBottomBtnTextColorDark : dialogBottomBtnTextColor;
  }

  static getDialogBottomBtnBgColor(bool isDark) {
    return isDark ? dialogBottomBtnBgColorDark : dialogBottomBtnBgColor;
  }

}
