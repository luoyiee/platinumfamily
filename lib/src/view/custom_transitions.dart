import 'package:flutter/material.dart';

import '../../main.dart';

class CustomTransitions {
  static Widget slideFromRight(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  static Widget slideFromBottom(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  static Widget fade(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget scale(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    const curve = Curves.easeInOut;
    var tween = Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));
    var scaleAnimation = animation.drive(tween);
    return ScaleTransition(scale: scaleAnimation, child: child);
  }

  static Widget rotate(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const curve = Curves.easeInOut;
    var tween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
    var rotateAnimation = animation.drive(tween);

    return RotationTransition(turns: rotateAnimation, child: child);
  }

  // iOS-like slide from right transition
  static Widget iosTransition(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);
    return SlideTransition(position: offsetAnimation, child: child);
  }

  // Android-like fade transition
  static Widget androidTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const curve = Curves.easeInOut;
    var tween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
    var fadeAnimation = animation.drive(tween);
    return FadeTransition(opacity: fadeAnimation, child: child);
  }

  static Widget platformAwareTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (isIos) {
      return iosTransition(context, animation, secondaryAnimation, child);
    } else {
      return androidTransition(context, animation, secondaryAnimation, child);
    }
  }
}
