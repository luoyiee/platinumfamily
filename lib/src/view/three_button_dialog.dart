
import 'package:earlybird/res/color_style.dart';
import 'package:earlybird/src/utils/common_utils.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../res/text_style.dart';

class ThreeButtonDialog extends StatelessWidget {
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback? onTertiary;
  final String? titleStr;
  final String? primaryStr;
  final String? secondaryStr;
  final String? tertiaryStr;
  final bool isDark;

  const ThreeButtonDialog({
    super.key,
    required this.titleStr,
    this.primaryStr,
    this.secondaryStr,
    this.tertiaryStr,
    this.onPrimary,
    this.onSecondary,
    this.onTertiary,
    this.isDark = false
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: JTColorStyle.getDialogBgColor(isDark),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        width: CommonUtil.commonDialogWidth(context),
        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleStr != null && titleStr!.isNotEmpty)
              Text(
                titleStr ?? "",
                style: JTTextStyle.headlineSmall3.copyWith(color: isDark ? Colors.white : null),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 26),
            // Primary Button (主按钮 - 主题色实心，完全圆角)
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 216,
                maxWidth: 292,
                minHeight: 52,
              ),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: JTColorStyle.getDialogBtnBgColor(isDark),
                  // 完全圆角
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  // 设置水波纹颜色
                  foregroundColor: JTColorStyle.dialogBtnBgColorPressed
                ),
                onPressed: onPrimary ?? () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  primaryStr ?? loc.ok,
                  style: JTTextStyle.headlineSmall3.copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8),
            // Secondary Button (第二按钮 - 主题色描边，完全圆角)
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 216,
                maxWidth: 292,
                minHeight: 52,
              ),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  // 完全圆角
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  side: BorderSide(color: JTColorStyle.getDialogBtnBgColor(isDark), width: 2),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  // 水波纹颜色
                  foregroundColor: JTColorStyle.getDialogBtnBgColor(isDark).withValues(alpha: 0.12),
                ),
                onPressed: onSecondary ?? () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  secondaryStr ?? loc.dialogCancel,
                  style: JTTextStyle.headlineSmall3.copyWith(color: JTColorStyle.getDialogBtnBgColor(isDark)),
                ),
              ),
            ),
            SizedBox(height: 8),
            // Tertiary Button (第三按钮 - 透明背景，完全圆角)
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 216,
                maxWidth: 292,
                minHeight: 52,
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  // 完全圆角
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  // 水波纹颜色
                  foregroundColor: JTColorStyle.getDialogBottomBtnBgColor(isDark),
                ),
                onPressed: onTertiary ?? () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  tertiaryStr ?? '',
                  style: JTTextStyle.headlineSmall3.copyWith(color: JTColorStyle.getDialogBottomBtnTextColor(isDark)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

