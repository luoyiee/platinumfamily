import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:earlybird/res/color_style.dart';
import 'package:earlybird/res/text_style.dart';
import 'package:earlybird/res/image_library.dart';
import 'package:earlybird/src/constants/constants.dart';
import 'package:earlybird/src/utils/common_utils.dart';
import 'package:earlybird/src/utils/image_utils.dart';
import 'package:earlybird/src/manager/tracker_manager.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../../main.dart';
import '../../../res/string_library.dart';
import '../../constants/tracker_constants.dart';
import '../../manager/js_bridge_manager.dart';
import '../../product/product_string.dart';
import '../../utils/js_utils.dart';
import '../../utils/time_utils.dart';
import '../../../res/static_string_library.dart';
import '../../view/horizontal_gradient_text.dart';

class TalkiePodsMembershipActivationPage extends StatefulWidget {
  final String? sessionId;
  final String? productId;
  final int? platinumFamilyOwnerDue;
  final bool result;
  final bool vipUser;

  const TalkiePodsMembershipActivationPage({
    super.key,
    this.sessionId,
    this.productId,
    this.platinumFamilyOwnerDue,
    this.result = false,
    this.vipUser = false
  });

  @override
  State<TalkiePodsMembershipActivationPage> createState() => _TalkiePodsMembershipActivationPageState();
}

class _TalkiePodsMembershipActivationPageState extends State<TalkiePodsMembershipActivationPage> {
  final String _tag = "TalkiePodsMembershipActivationPage";
  int _step = 0;
  Timer? _timer;
  static const int maxStep = 2;
  int _platinumFamilyOwnerDue = 0; // platinumDue 时间戳

  @override
  void initState() {
    super.initState();
    _platinumFamilyOwnerDue = widget.platinumFamilyOwnerDue ?? 0;
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    if (_platinumFamilyOwnerDue > 0 && _platinumFamilyOwnerDue > currentTimeMillis) {
      titlePlatinumFamilyOwnerDue = sprintf(loc.titlePlatinumExpiresOnFormat, [_platinumFamilyOwnerDue]);
      setState(() {});
    }

    // 打印接收到的参数
    if (widget.sessionId != null) {
      consoleLog('$_tag: $_tag 接收到  session_id: ${widget.sessionId}');
    }
    if (widget.productId != null) {
      consoleLog('$_tag: $_tag 接收到 productId: ${widget.productId}');
    }
    if (widget.result) return;
    // 如果有 sessionId ，调用 JS purchase 方法
    if (widget.sessionId != null) {
      _callPurchaseMethod();
    }

    if (widget.productId != 'noPlatinumFamily') {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_step < maxStep) {
          setState(() {
            _step++;
          });
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 调用JS purchase方法
  void _callPurchaseMethod() {
    final map = Map<String, dynamic>.from(traceDataMap);
    map['action'] = TrackerConstants.eventValueActionPurchase;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
    map['product'] = widget.productId;

    final talkiePodsColor = TrackerManager.getTalkiePodsColor();
    if (talkiePodsColor != null) {
      map['talkiePodsColor'] = talkiePodsColor;
    }
    try {
      // 构建purchase参数
      final Map<String, dynamic> purchaseParams = {
        'action': 'purchase',
        'productId': widget.productId,
        'token': widget.sessionId,
        'eventType': 'platinumFamily',
        'traceData': map,
        'test': isTestMode,
      };

      final String paramsJson = jsonEncode(purchaseParams);
      consoleLog('$_tag: 调用purchase方法，参数: $paramsJson');

      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.toJS, (JSAny? responseData) {
        consoleLog('$_tag: purchase方法响应: $responseData');
        final Map<String, dynamic>? responseMap = jsAnyToMap(responseData);

        if (responseMap != null) {
          consoleLog('$_tag: purchase响应解析成功: $responseMap');

          // 处理platinumDue时间戳
          if (responseMap.containsKey('platinumFamilyOwnerDue')) {
            final dynamic platinumFamilyOwnerDue = responseMap['platinumFamilyOwnerDue'];
            if (platinumFamilyOwnerDue is int) {
              setState(() {
                _platinumFamilyOwnerDue = platinumFamilyOwnerDue;
                int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
                titlePlatinumFamilyOwnerDue =
                (_platinumFamilyOwnerDue > 0 && _platinumFamilyOwnerDue > currentTimeMillis) ? sprintf(loc.titlePlatinumExpiresOnFormat, [_platinumFamilyOwnerDue]) : "";
              });
              consoleLog('$_tag: 更新platinumDue时间戳: $platinumFamilyOwnerDue');
            }
          }
        } else {
          consoleLog('$_tag: purchase响应解析失败');
        }
      }.toJS,
      );
    } catch (e) {
      consoleLog('$_tag: 调用purchase方法失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isWebDesignMode) {
      loc = AppLocalizations.of(context)!;
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  bool isTablet = constraints.maxWidth >= cTabletMinWidth;
                  bool isLandscape = constraints.maxWidth > constraints.maxHeight;
                  return SafeArea(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: cContentMaxWidth),
                        margin: EdgeInsets.only(top: CommonUtil.getSafeBarTop()),
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 20),
                        child: Column(
                              children: [
                                Container(
                                  height: CommonUtil.getTopBarHeight(context),
                                  alignment: Alignment.center,
                                  child: Text(
                                      loc.paymentResult,
                                      style: JTTextStyle.headlineSmall3
                                  ),
                                ),
                                Expanded(
                                  child: widget.productId == 'noPlatinumFamily'
                                      ? buildPlanPlatinumFamilyContent()
                                      : buildNormalMembershipContent(isTablet, isLandscape),
                                ),
                                buildDoneButton(isTablet),
                              ],
                            )
                      ),
                    ),
                  );
                })
    );
  }

  Widget buildPlanPlatinumFamilyContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageUtil.loadLocalImage(context,
              ImageLibrary.icShippingBoxCenter,
              height: 80
          ),
          const SizedBox(height: 16),
          Text(
            textAlign: TextAlign.center,
            loc.payTalkiePodsSuccessful,
            style: JTTextStyle.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget buildNormalMembershipContent(bool isTablet, bool isLandscape) {
    return Column(
      children: [
        SizedBox(height: isTablet ? isLandscape ? 30 : 60 : 30),
        // 支付成功状态
        Row(
          children: [
            ImageUtil.loadLocalImage(context,
                ImageLibrary.icShippingBox,
                height: 32
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                widget.productId == ProductConfig.membershipWithoutHeadphones ||
                    widget.productId == ProductConfig.membershipClaimWithoutHeadphones ||
                    widget.productId == ProductConfig.officialMembershipWithoutHeadphones
                    ? loc.paymentSuccessfulReceipt : loc.payTalkiePodsSuccessful,
                style: JTTextStyle.bodyLarge,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet && !isLandscape ? 302 : 101),
        // 会员图标和标题
        Column(
          children: [
            ImageUtil.loadLocalImage(context,
                ImageLibrary.icPlatinumFamilyLogo,
                height: isTablet && !isLandscape ? 160 : 140,
                fit: BoxFit.contain
            ),
            SizedBox(height: isTablet ? 24 : 20),
            HorizontalGradientText(
              StaticStringLibrary.platinumFamily,
              style: JTTextStyle.headlineSmall,
              colors: const [
                Color(0xFF101A2B), Color(0xFF5E6F8A), Color(0xFF394966), Color(0xFF17253C),
                Color(0xFF5E6F8A), Color(0xFF394966), Color(0xFF1D2C43)
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),

            if (_platinumFamilyOwnerDue == 0)
            // 激活中文本
            Text(
              _getActivationText(),
              style: JTTextStyle.bodyLarge,
              textAlign: TextAlign.center,
            ),

            if (_platinumFamilyOwnerDue > 0)...[
              Visibility(
                  visible: widget.vipUser,
                  child: Text(
                    loc.activationSuccessTip,
                    style: JTTextStyle.headlineSmall3,
                    textAlign: TextAlign.center,
                  )
              ),
              SubstringHighlight(
                  text: sprintf(loc.officialExpiresOnFormat, [formatTimestamp(_platinumFamilyOwnerDue)]),
                  term: formatTimestamp(_platinumFamilyOwnerDue),
                  textStyle: JTTextStyle.headlineSmall3,
                  textStyleHighlight: JTTextStyle.headlineSmall3.copyWith(color: JTColorStyle.themeColor)
              ),
            ],
            SizedBox(height: isTablet ? 20 : 10),
            if (_platinumFamilyOwnerDue == 0 && _step == 2)
              Text(
                  loc.contactSupport,
                  style: JTTextStyle.bodyLarge.copyWith(color: JTColorStyle.secondaryTextColor),
                  textAlign: TextAlign.center
              ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget buildDoneButton(bool isTablet) {
    return
      Container(
        margin: EdgeInsets.only(bottom: CommonUtil.getSafeBarBottom() + 30),
        constraints: BoxConstraints(maxWidth: isTablet ? 343 : 320),
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: JTColorStyle.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTablet ? 40 : 30)),
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 13)
          ),
          onPressed: () {
            JsBridgeManager.finishWeb();
          },
          child: Text(
              loc.done,
              style: JTTextStyle.headlineSmall3.copyWith(color: Colors.white)
          ),
        ),
      );
  }

  String _getActivationText() {
    switch (_step) {
      case 0:
        return loc.membershipActivating;
      case 1:
        return loc.stillActivatingThanks;
      default:
        return loc.activatingThanks;
    }
  }
}