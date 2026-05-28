import 'package:earlybird/src/view/common_dialog.dart';
import 'package:flutter/material.dart';

import '../view/three_button_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class DialogManager {

  /// 通用选择框
  static Future<void> showCommonDialog({
    required BuildContext context,
    String? titleStr,
    String? messageStr,
    String? confirmStr,
    String? cancelStr,
    bool barrierDismissible = true,
    bool canPop = true,
    bool showCancelButton = false,
    bool isDark = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return PopScope(
              canPop: canPop,
              child: CommonDialog(
                  titleStr: titleStr,
                  messageStr: messageStr,
                  confirmStr: confirmStr,
                  cancelStr: cancelStr,
                  onConfirm: onConfirm,
                  onCancel: onCancel,
                  showCancelButton: showCancelButton,
                  isDark: isDark,
              ));
      },
    );
  }

  static void showErrorDialog({required BuildContext context, required String message}) {
    showCommonDialog(context: context, titleStr: message);
  }

  /// 三按钮对话框
  static Future<void> showThreeButtonDialog({
    required BuildContext context,
    String? titleStr,
    String? primaryStr,
    String? secondaryStr,
    String? tertiaryStr,
    bool barrierDismissible = true,
    bool canPop = true,
    bool isDark = false,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    VoidCallback? onTertiary,
    isDa
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return PopScope(
            canPop: canPop,
            child: ThreeButtonDialog(
              titleStr: titleStr,
              primaryStr: primaryStr,
              secondaryStr: secondaryStr,
              tertiaryStr: tertiaryStr,
              onPrimary: onPrimary,
              onSecondary: onSecondary,
              onTertiary: onTertiary,
              isDark: isDark,
            ));
      },
    );
  }

  static void showLoadingDialog() {
    EasyLoading.show(status: 'loading...');
  }

  static void dismissLoadingDialog() {
    EasyLoading.dismiss();
  }

}