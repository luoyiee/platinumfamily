import 'package:earlybird/res/color_style.dart';
import 'package:earlybird/src/utils/common_utils.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../res/text_style.dart';

class CommonDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? titleStr;
  final String? messageStr;
  final String? confirmStr;
  final String? cancelStr;
  final bool showCancelButton;
  final bool isDark;

  const CommonDialog({
    super.key,
    required this.titleStr,
    this.messageStr,
    this.confirmStr,
    this.cancelStr,
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = false,
    this.isDark = false
  });

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = JTTextStyle.headlineSmall3;
    bool showMessage = messageStr != null && messageStr!.isNotEmpty;
    return AlertDialog(
      backgroundColor: JTColorStyle.getDialogBgColor(isDark),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        width: CommonUtil.commonDialogWidth(context),
        padding: EdgeInsets.fromLTRB(16, 24 , 16, showCancelButton ? 8 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleStr != null && titleStr!.isNotEmpty)
              Text(
                titleStr ?? "",
                style: titleStyle.copyWith(color: isDark ? Colors.white : null),
                textAlign: TextAlign.center,
              ),
            if (showMessage)
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  messageStr ?? "",
                  style: JTTextStyle.bodyLarge.copyWith(color: isDark ? Colors.white : null),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 26),
            // Confirm Button (确认按钮 - 主题色实心，完全圆角)
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 216,
                maxWidth: 292,
                minHeight: 52,
              ),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: JTColorStyle.getDialogBtnBgColor(isDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  foregroundColor: JTColorStyle.dialogBtnBgColorPressed
                ),
                onPressed: onConfirm ?? () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  confirmStr ?? loc.ok,
                  style: JTTextStyle.headlineSmall3.copyWith(color: Colors.white),
                ),
              ),
            ),
            if (showCancelButton) ...[
              SizedBox(height: 8),
              // Cancel Button (取消按钮 - 透明背景，完全圆角)
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 216,
                  maxWidth: 292,
                  minHeight: 52,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: JTColorStyle.getDialogBottomBtnBgColor(isDark),
                  ),
                  onPressed: onCancel ?? () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    cancelStr ?? loc.dialogCancel,
                    style: JTTextStyle.headlineSmall3.copyWith(color: JTColorStyle.getDialogBottomBtnTextColor(isDark)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
