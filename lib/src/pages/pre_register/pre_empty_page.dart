import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../manager/js_bridge_manager.dart';
import '../../utils/js_utils.dart';
import '../../constants/tracker_constants.dart';

class PreEmptyPage extends StatefulWidget {
  final String? sessionId;
  final String? productId;

  const PreEmptyPage({super.key, this.sessionId, this.productId});

  @override
  State<PreEmptyPage> createState() => _PreEmptyPageState();
}

class _PreEmptyPageState extends State<PreEmptyPage> {
  final String _tag = "PreEmptyPage";

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    _reportUnRegisterOrder();
  }

  /// 上报未注册待激活订单记录
  void _reportUnRegisterOrder() {
    final map = Map<String, dynamic>.from(traceDataMap);
    map['action'] = TrackerConstants.eventValueActionCheckOut;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
    map['product'] = widget.productId;

    final Map<String, dynamic> orderParams = {
      'action': 'reportPreSignupInactiveOrder',
      'productId': widget.productId,
      'token': widget.sessionId,
      'eventType': 'platinumFamily',
      'traceData': map,
      'test': isTestMode
    };
      final String paramsJson = jsonEncode(orderParams);
      consoleLog('$_tag: 调用 reportPreSignupInactiveOrder 方法，参数: $paramsJson');
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.toJS, null);
  }
}