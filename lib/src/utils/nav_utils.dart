import 'package:flutter/material.dart';
import '../manager/js_bridge_manager.dart';

class NavUtils {

  NavUtils._();

  static void push(BuildContext context, Widget page) {
    Navigator.push(context, noneAnimationRoute(page));
  }

  static void pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, noneAnimationRoute(page));
  }

  static void pushReplacementNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static PageRouteBuilder<T> noneAnimationRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    );
  }

}

/// 自动根据导航栈深度控制返回键拦截
class BackPressObserver extends NavigatorObserver {

  @override
  void didPush(Route route, Route? previousRoute) {
    _updateInterception();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _updateInterception();
  }

  void _updateInterception() {
    final navigator = this.navigator;
    if (navigator == null) return;
    if (navigator.canPop()) {
      // 子页面，禁用拦截（让原生直接处理 pop）
      JsBridgeManager.setBackPressInterception();
    } else {
      // 根页面，启用拦截（由 Flutter 端处理返回）
      JsBridgeManager.setBackPressInterception(enabled: true);
    }
  }

}
