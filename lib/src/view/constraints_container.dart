import 'package:earlybird/src/utils/common_utils.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class ConstrainedContainer extends StatelessWidget {
  final Widget child;
  final bool noPadding;
  final double targetPadding;
  final double targetMaxWidth;

  const ConstrainedContainer({
    super.key,
    required this.child,
    this.noPadding = false,
    this.targetPadding = 0,
    this.targetMaxWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: noPadding ? null : EdgeInsets.symmetric(horizontal: targetPadding > 0 ? targetPadding : CommonUtil.isTablet(context) ? 36 : 20),
      constraints: BoxConstraints(maxWidth: targetMaxWidth > 0 ? targetMaxWidth : cContentMaxWidth),
      child: child,
    );
  }
}