import 'dart:js_interop';
import 'dart:math';

import '../../main.dart';
import '../config/app_config.dart';
import '../constants/bridge_constants.dart';
import '../constants/tracker_constants.dart';
import 'js_bridge_manager.dart';
import '../utils/js_utils.dart';

class TrackerManager {

  /// 生成 spanId：8 字节随机数的 16 位十六进制字符串
  static String _generateSpanId() {
    final random = Random();
    final bytes = List<int>.generate(8, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Map<String, dynamic> _getMutableTraceMap() {
    return Map<String, dynamic>.from(traceDataMap);
  }

  static void _trackEvent({
    required String eventName,
    required Map<String, dynamic> dataMap,
    bool wrapWithPurchase = true,
  }) {
    dataMap['traceId'] = AppConfig.traceId;
    dataMap['spanId'] = _generateSpanId();
    dataMap['reason'] = dataMap['reason'] ?? dataMap['from'];
    dataMap['productType'] = 'subscribe';

    final Map<String, dynamic> aliParams = {
      'action': BridgeConstants.actionAliTrack,
      'eventName': eventName,
      'keyAndValues': wrapWithPurchase ? {'purchase': dataMap} : dataMap,
    };
    consoleLog('logEvent $aliParams');
    JsBridgeManager.aliTrack(aliParams);
  }

  static void talkiePodsPlatinumBundleMarketing() {
    final Map<String, dynamic> map = _getMutableTraceMap();
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;

    _trackEvent(
      eventName: TrackerConstants.eventNameTalkiePodsPlatinumBundleMarketing,
      dataMap: map,
    );
  }

  static void talkiePodsPlatinumBundleMarketingAction() {
    final Map<String, dynamic> map = _getMutableTraceMap();
    map['action'] = TrackerConstants.eventValueActionPurchase;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;

    _trackEvent(
      eventName: TrackerConstants.eventNameTalkiePodsPlatinumBundleMarketingAction,
      dataMap: map,
    );
  }

  static void payShow() {
    final Map<String, dynamic> map = _getMutableTraceMap();
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;

    _trackEvent(
      eventName: TrackerConstants.eventNamePayShow,
      dataMap: map,
    );
  }

  static void payClick(String? productId) {
    final Map<String, dynamic> map = _getMutableTraceMap();
    map['action'] = TrackerConstants.eventValueActionCheckOut;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
    map['product'] = productId;
    map['period'] = '12month';
    final talkiePodsColor = getTalkiePodsColor();
    if (talkiePodsColor != null) {
      map['talkiePodsColor'] = talkiePodsColor;
    }
    _trackEvent(
      eventName: TrackerConstants.eventNamePayClick,
      dataMap: map,
    );
  }

  static void payResult(String payResult, String? productId) {
    final Map<String, dynamic> map = _getMutableTraceMap();
    map['action'] = TrackerConstants.eventValueActionCheckOut;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
    map['product'] = productId;
    map['result'] = payResult;
    map['period'] = '12month';
    final talkiePodsColor = getTalkiePodsColor();
    if (talkiePodsColor != null) {
      map['talkiePodsColor'] = talkiePodsColor;
    }
    _trackEvent(
      eventName: TrackerConstants.eventNamePayResult,
      dataMap: map,
    );
  }

  static String? getTalkiePodsColor() {
    if (talkiesPodsList == null) return null;
    return talkiesPodsList!.expand((item) {
      final color = {
        TrackerConstants.eventValueColorBlue: 'Blue',
        TrackerConstants.eventValueColorPurple: 'Purple',
        TrackerConstants.eventValueColorNavyRed: 'NavyRed',
        TrackerConstants.eventValueColorRedYellow: 'RedYellow',
        TrackerConstants.eventValueColorBlackGreen: 'BlackGreen',
        TrackerConstants.eventValueColorGreen: 'Green',
        TrackerConstants.eventValueColorPinkPurple: 'PinkPurple',
      }[item['color']] ?? item['color'];
      return List.filled((item['quantity'] as num).toInt(), color);
    }).join(';');
  }

  static void payResultDialog(String result) {
    final Map<String, dynamic> map = _getMutableTraceMap();
    map['result'] = result;
    _trackEvent(
      eventName: TrackerConstants.eventNamePayResultDialog,
      dataMap: map,
      wrapWithPurchase: false,
    );
  }


}