import 'package:flutter/material.dart';
import 'package:earlybird/res/color_style.dart';

/// JusTalk 字体样式系统
/// 基于设计规范创建的字体样式类
class JTTextStyle {
  // 私有构造函数，防止实例化
  JTTextStyle._();

  // 字体族
  static const String _fontFamily = 'Roboto';

  // Display 样式 - 用于大型标题
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    height: 64 / 57, // line-height / font-size
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    height: 52 / 45,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  // Headline 样式 - 用于标题
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle headlineMedium2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle headlineSmall2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle headlineSmall3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  // Title 样式 - 用于小标题
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  // Label 样式 - 用于标签
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.bold,
    color: JTColorStyle.primaryTextColor,
  );

  // Body 样式 - 用于正文
  static const TextStyle bodyLarge2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w500, // Medium
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500, // Medium
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500, // Medium
    color: JTColorStyle.primaryTextColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500, // Medium
    color: JTColorStyle.primaryTextColor,
  );

  // 便捷方法：根据字号获取样式
  static TextStyle getStyleByFontSize(double fontSize) {
    switch (fontSize.toInt()) {
      case 57:
        return displayLarge;
      case 45:
        return displayMedium;
      case 36:
        return displaySmall;
      case 32:
        return headlineLarge;
      case 28:
        return headlineMedium;
      case 24:
        return headlineSmall;
      case 22:
        return titleLarge;
      case 20:
        return headlineSmall2;
      case 18:
        return headlineSmall3;
      case 16:
        return titleMedium;
      case 14:
        return titleSmall;
      case 12:
        return bodySmall;
      case 11:
        return labelSmall;
      default:
        return bodyMedium; // 默认样式
    }
  }

  // 便捷方法：根据类型获取样式
  static TextStyle getDisplayStyle({String size = 'medium'}) {
    switch (size.toLowerCase()) {
      case 'large':
        return displayLarge;
      case 'small':
        return displaySmall;
      default:
        return displayMedium;
    }
  }

  static TextStyle getHeadlineStyle({String size = 'medium'}) {
    switch (size.toLowerCase()) {
      case 'large':
        return headlineLarge;
      case 'medium2':
        return headlineMedium2;
      case 'small':
        return headlineSmall;
      case 'small2':
        return headlineSmall2;
      case 'small3':
        return headlineSmall3;
      default:
        return headlineMedium;
    }
  }

  static TextStyle getTitleStyle({String size = 'medium'}) {
    switch (size.toLowerCase()) {
      case 'large':
        return titleLarge;
      case 'small':
        return titleSmall;
      default:
        return titleMedium;
    }
  }

  static TextStyle getLabelStyle({String size = 'medium'}) {
    switch (size.toLowerCase()) {
      case 'large':
        return labelLarge;
      case 'small':
        return labelSmall;
      default:
        return labelMedium;
    }
  }

  static TextStyle getBodyStyle({String size = 'medium'}) {
    switch (size.toLowerCase()) {
      case 'large2':
        return bodyLarge2;
      case 'large':
        return bodyLarge;
      case 'small':
        return bodySmall;
      default:
        return bodyMedium;
    }
  }

  static TextStyle getHomeCardTextStyle(bool isTablet) {
    return isTablet ? headlineSmall2 : titleMedium;
  }

  static TextStyle getHomeTitleStyle(bool isTablet) {
    return isTablet ? headlineSmall : headlineSmall2;
  }

} 