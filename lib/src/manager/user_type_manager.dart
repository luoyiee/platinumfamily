import 'package:flutter/foundation.dart';
import '../utils/js_utils.dart';
import '../config/price_config.dart';

/// 用户类型管理器 - 支持响应式更新
class UserTypeManager {
  static final UserTypeManager _instance = UserTypeManager._internal();
  factory UserTypeManager() => _instance;
  UserTypeManager._internal();

  static const String _tag = 'UserTypeManager';

  /// 用户类型通知器 - 页面可以监听此值的变化  用户会员类型,默认无会员
  final ValueNotifier<UserType> userTypeNotifier = ValueNotifier<UserType>(UserType.planOthers);

  /// 用户类型是否已加载完成
  final ValueNotifier<bool> isLoadedNotifier = ValueNotifier<bool>(false);

  /// 获取当前用户类型
  UserType get userType => userTypeNotifier.value;

  /// 设置用户类型
  set userType(UserType type) {
    if (userTypeNotifier.value != type) {
      consoleLog('$_tag: User type changed from ${userTypeNotifier.value} to $type');
      userTypeNotifier.value = type;
    }
  }

  /// 标记用户类型已加载完成
  void markLoaded() {
    if (!isLoadedNotifier.value) {
      consoleLog('$_tag: User type loaded: ${userTypeNotifier.value}');
      isLoadedNotifier.value = true;
    }
  }

  /// 重置状态（用于测试或重新初始化）
  void reset() {
    userTypeNotifier.value = UserType.planOthers;
    isLoadedNotifier.value = false;
  }

  /// 释放资源
  void dispose() {
    userTypeNotifier.dispose();
    isLoadedNotifier.dispose();
  }
}
