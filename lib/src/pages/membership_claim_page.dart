import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:earlybird/res/color_style.dart';
import 'package:earlybird/src/constants/constants.dart';
import 'package:earlybird/src/constants/tracker_constants.dart';
import 'package:earlybird/src/manager/tracker_manager.dart';
import 'package:earlybird/src/routes/app_routes.dart';
import 'package:earlybird/src/utils/nav_utils.dart';
import 'package:earlybird/src/utils/common_utils.dart';
import 'package:earlybird/src/view/constraints_container.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../res/string_library.dart';
import '../../res/text_style.dart';
import '../../res/image_library.dart';
import '../../main.dart';

import '../constants/url_constants.dart';
import '../manager/dialog_manager.dart';
import '../manager/js_bridge_manager.dart';
import '../product/product_string.dart';
import '../utils/image_utils.dart';
import '../utils/js_utils.dart';
import '../../res/static_string_library.dart';
import '../view/home_top_video.dart';
import '../view/horizontal_gradient_text.dart';
import 'pre_register/pre_empty_page.dart';
import 'talkiepods/talkiepods_membership_activation_page.dart';
import 'package:web/web.dart' as web;

class MembershipClaimPage extends StatefulWidget {
  const MembershipClaimPage({super.key});
  @override
  State<MembershipClaimPage> createState() => _MembershipClaimPageState();
}

class _MembershipClaimPageState extends State<MembershipClaimPage> {
  final String _tag = "MembershipClaimPage";
  String memberYearPrice = "\$109.99";
  String memberMonthPrice = "\$9.17";
  String percentOffPrice = isFamilyMember() ? '\$20' : '\$40';
  int _platinumFamilyOwnerDue = 0; // platinumDue 时间戳

  @override
  void initState() {
    super.initState();
    if(!isWebDesignMode){
      TrackerManager.payShow();
    }
    queryNewH5Result();
  }

  @override
  Widget build(BuildContext context) {
    if (isWebDesignMode) {
      loc = AppLocalizations.of(context)!;
    }
     /// ipad 测试使用 LayoutBuilder 无法刷新页面
    bool isTablet = CommonUtil.isTablet(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
            children: [
              // 主体内容可滑动
              SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: CommonUtil.getSafeBarBottom() + 138 + 60),
                  child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(isTablet && titlePlatinumFamilyOwnerDue.isNotEmpty)
                            Container(
                                height: CommonUtil.getTopBarHeight(context),
                                margin: EdgeInsets.only(top: CommonUtil.getSafeBarTop(), bottom: 20),
                                alignment: Alignment.center,
                                child: Text(titlePlatinumFamilyOwnerDue, style: JTTextStyle.titleSmall)
                            ),
                          _buildVideoCard(isTablet),
                          SizedBox(height: isTablet ? 95 : 40),
                          ...isTablet ? [
                            _buildTabletSceneCard(
                              imageAsset: ImageLibrary.homeTalk,
                              titleTextSpan: TextSpan(
                                text: loc.tapToTalk,
                                style: JTTextStyle.headlineMedium2,
                                children: [
                                  TextSpan(
                                    text: loc.justTalk,
                                    style: JTTextStyle.headlineMedium2.copyWith(color: const Color(0xFF00DCE4)),
                                  ),
                                ],
                              ),
                              subtitleText: loc.sendAndReceiveVoiceMessages,
                              imageOnRight: false,
                            ),
                          ] : [_buildMobileSceneCard1()],
                          SizedBox(height: isTablet ? 100 : 40),
                          ...isTablet ? [
                            _buildTabletSceneCard(
                              imageAsset: ImageLibrary.homeSmartListening,
                              titleTextSpan: TextSpan(
                                text: loc.smartListening,
                                style: JTTextStyle.headlineMedium2.copyWith(color: const Color(0xFFFFA12E)),
                                children: [
                                  TextSpan(
                                    text: loc.parentApproved,
                                    style: JTTextStyle.headlineMedium2,
                                  ),
                                ],
                              ),
                              subtitleText: loc.setLimitsOnTimeAndVolume,
                              imageOnRight: true,
                            )] : [_buildMobileSceneCard2()],
                          SizedBox(height: isTablet ? 100 : 40),
                          // 四大亮点（2x2图片+标题+描述）
                          Container(
                            constraints: BoxConstraints(maxWidth: cContentMaxWidth),
                            margin: EdgeInsets.symmetric(horizontal: isTablet ? 36 : 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF3FCF9), Color(0xFFFBFBFB)],
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 24, vertical: isTablet ? 50 : 32),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _FeatureBlock(
                                        image: ImageLibrary.feature1,
                                        title: loc.safeOpenEar,
                                        desc: loc.hearAndAware,
                                        isTablet: isTablet
                                      ),
                                    ),
                                    SizedBox(width: isTablet ? 60 : 32),
                                    Expanded(
                                      child: _FeatureBlock(
                                        image: ImageLibrary.feature2,
                                        title: loc.allDayBattery,
                                        desc: loc.battery20hFastCharge,
                                        isTablet: isTablet
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isTablet ? 80 : 50),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _FeatureBlock(
                                        image: ImageLibrary.feature3,
                                        title: loc.durableWaterResistant,
                                        desc: loc.flexibleIpx5Safe,
                                        isTablet: isTablet
                                      ),
                                    ),
                                    SizedBox(width: isTablet ? 60 : 32),
                                    Expanded(
                                      child: _FeatureBlock(
                                        image: ImageLibrary.feature4,
                                        title: loc.featherlightComfort,
                                        desc: loc.lightBendableComfort,
                                        isTablet: isTablet
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isTablet ? 120 : 60),
                          // 会员权益区块
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFE2E7EF), Color(0x00E2E7EF)]
                              ),
                            ),
                            padding: EdgeInsets.only(top: isTablet ? 60 : 80),
                            child: Column(
                              children: [
                                Image.asset(
                                  ImageLibrary.premiumLogo,
                                  width: isTablet ? 160 : 140,
                                  height: isTablet ? 160 : 140,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: isTablet ? 20 : 24),
                                HorizontalGradientText(
                                  loc.homeMembershipTitle,
                                  style: JTTextStyle.headlineMedium,
                                  textAlign: TextAlign.center,
                                  colors: const [
                                    Color(0xFF101A2B), Color(0xFF5E6F8A), Color(0xFF394966), Color(0xFF17253C),
                                    Color(0xFF5E6F8A), Color(0xFF394966), Color(0xFF5E6F8A), Color(0xFF1D2C43),
                                  ],
                                ),
                                SizedBox(height: isTablet ? 120 : 100),
                                ConstrainedContainer(
                                    child: Text(
                                      loc.exclusiveDeviceProtection,
                                      style: JTTextStyle.headlineSmall,
                                      textAlign: TextAlign.center,
                                    )
                                ),
                                SizedBox(height: isTablet ? 24 : 30),
                                ConstrainedContainer(
                                  child: Row(
                                    children: [
                                      // 左侧卡片
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 16),
                                          height: isTablet ? 350 : 280,
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                                                child: SubstringHighlight(
                                                    text: loc.freeReplacementTitle,
                                                    terms: [loc.free, loc.replacement],
                                                    textStyle: isTablet ? JTTextStyle.headlineSmall2 : JTTextStyle.titleMedium,
                                                    textStyleHighlight: (isTablet ? JTTextStyle.headlineSmall2 : JTTextStyle.titleMedium).copyWith(color: Color(0xFF00DFBD))
                                                ),
                                              ),
                                              SizedBox(height: isTablet ? 50 : 26),
                                              Center(child: Image.asset(
                                                  ImageLibrary.box01,
                                                  height: isTablet ? 216 : 150,
                                                  fit: BoxFit.contain
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // 右侧卡片
                                      Expanded(
                                        child: Container(
                                          height: isTablet ? 350 : 280,
                                          padding: EdgeInsets.only(top: isTablet ? 24 : 16),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                                                child: SubstringHighlight(
                                                    text: loc.priorityTitle,
                                                    term: loc.on1Support,
                                                    textStyle: JTTextStyle.headlineSmall2,
                                                    textStyleHighlight: JTTextStyle.headlineSmall2.copyWith(color: Color(0xFFFFB700))
                                                ),
                                              ),
                                              Spacer(),
                                              LayoutBuilder(
                                                builder: (context, constraints) {
                                                  return Container(
                                                    width: constraints.maxWidth,
                                                    alignment: Alignment.bottomCenter,
                                                    clipBehavior: isTablet ? Clip.none : Clip.antiAlias,
                                                    decoration: BoxDecoration(
                                                      borderRadius: isTablet ? BorderRadius.zero : const BorderRadius.vertical(bottom: Radius.circular(28)),
                                                    ),
                                                    child: Image.asset(
                                                      ImageLibrary.support01,
                                                      width: isTablet
                                                          ? constraints.maxWidth * 236 / 359  // 平板
                                                          : constraints.maxWidth * 157 / 176, // 手机
                                                      fit: BoxFit.contain,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                ConstrainedContainer(
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        loc.exclusiveDeviceProtectionDesc,
                                        style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor)
                                      )
                                  )
                                ),
                                SizedBox(height: isTablet ? 110 : 100),
                                ConstrainedContainer(
                                    child: Text(
                                        loc.enhancedParentalDeviceControls,
                                        style: JTTextStyle.headlineSmall2
                                    )
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: isTablet ? 30 : 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CarouselSlider(
                                disableGesture: isTablet,
                                options: CarouselOptions(
                                  height: isTablet ? 682 : 533,
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {},
                                ),
                                items: [
                                  // 第一张：总览页面（包含3个小组件）
                                  ConstrainedContainer(
                                      child: _buildOverviewCard(isTablet)
                                  ),
                                  // 第二张：详细设备管理界面
                                  ConstrainedContainer(
                                      child: _buildDetailedDeviceManagementCard()
                                  ),
                                  // 第三张：详细音量控制界面
                                  ConstrainedContainer(
                                      child: _buildDetailedVolumeControlCard()
                                  ),
                                  // 第四张：电池监控界面
                                  ConstrainedContainer(
                                      child: _buildBatteryMonitorCard()
                                  ),
                                  // 第五张：使用报告界面
                                  ConstrainedContainer(
                                      child: _buildUsageReportsCard()
                                  ),
                                ],
                              ),
                              Visibility(
                                  visible: !isTablet,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 24),
                                    child: Text(
                                      loc.tripleLeftArrowSwipeLeftToSeeMore,
                                      style: JTTextStyle.bodyLarge.copyWith(color: JTColorStyle.secondaryTextColor)
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(height: isTablet ? 110 : 100),
                          ConstrainedContainer(
                            child: Text(
                              loc.includesAllPremiumFamilyFeatures,
                              style: JTTextStyle.headlineSmall2,
                              textAlign: TextAlign.center
                            ),
                          ),
                          SizedBox(height: isTablet ? 30 : 24),
                          CarouselSlider(
                            disableGesture: isTablet,
                            options: CarouselOptions(
                                height: isTablet ? 830 : 636,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: false,
                            ),
                            items: [
                              ConstrainedContainer(
                                child: _buildIncludeFuturesCard(isTablet)),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF261501),
                                    icon: ImageLibrary.icMember2,
                                    image: ImageLibrary.imgMembers02,
                                    textWidget: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                          loc.upTo6MembersIncluded,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                      ),
                                    ),
                                    isTablet: isTablet
                                ),),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF368DFF),
                                    icon: ImageLibrary.icFriends2,
                                    image: ImageLibrary.imgFriendsManagement02,
                                    textWidget: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                          loc.kidsFriendsManagement,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                      ),
                                    ),
                                    isTablet: isTablet
                                ),),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF865EFF),
                                    icon: ImageLibrary.liveLocation24,
                                    image: ImageLibrary.imgLiveLocation02,
                                    imageHeight: 436,
                                    textWidget: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                          loc.liveLocation,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                      ),
                                    ),
                                    isTablet: isTablet
                                ),),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF18CEEA),
                                    icon: ImageLibrary.icSensitiveContentControl2,
                                    image: ImageLibrary.imgSensitiveContentControl02,
                                    textWidget: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        loc.sensitiveContentControl,
                                        style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                      ),
                                    ),
                                    isTablet: isTablet
                                ),),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF00E081),
                                    icon: ImageLibrary.icFeatures02,
                                    image: ImageLibrary.imgFeatures02,
                                    textWidget: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        loc.unlimitedCreativeFunFeatures,
                                        style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                      ),
                                    ),
                                    isTablet: isTablet
                                ),),
                            ],
                          ),
                          Visibility(
                            visible: !isTablet,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 24),
                              child: Text(
                                  loc.tripleLeftArrowSwipeLeftToSeeMore,
                                  style: JTTextStyle.bodyLarge.copyWith(color: JTColorStyle.secondaryTextColor)
                              ),
                            ),
                          ),
                          SizedBox(height: 60),
                          // 订阅条款
                          ConstrainedContainer(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(child: Text(
                                      loc.subscriptionTerms,
                                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                                    )),
                                    Text(
                                      loc.paymentTerms,
                                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                                    ),
                                    Text(
                                        "${loc.terms}${StaticStringLibrary.termsUrl}",
                                        style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor)
                                    ),
                                    Text(
                                        "${loc.privacyPolicy}${StaticStringLibrary.privacyUrl}",
                                        style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor)
                                    ),
                                  ])),
                        ],
                      ))
              ),
              // 底部悬浮按钮区
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child:ClipRect(child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                          height: CommonUtil.getSafeBarBottom() + 138,
                          color: Color(0xCCF9F9F9),
                          padding: EdgeInsets.fromLTRB(0, 12, 0, CommonUtil.getSafeBarBottom() + 24),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 315,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.0),
                                          Colors.black.withValues(alpha: 0.5)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 315,
                                    height: 52,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFF2C55),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        _membershipEligibility(isTablet);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            loc.membershipClaimTitle,
                                            style: JTTextStyle.headlineSmall3.copyWith(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                  sprintf(loc.membershipClaimDetailFormat,
                                      [memberYearPrice, memberMonthPrice]),
                                  style: JTTextStyle.titleSmall.copyWith(color: JTColorStyle.secondaryTextColor)
                              )
                            ],
                          )))
                  )
              ),
            ],
          )
    );
  }

// 视频区域
  Widget _buildVideoCard(bool isTablet) {
    if (!isTablet) {
      // 顶部大图、标题、副标题、Buy按钮、Bind提示
      return Stack(
        clipBehavior: Clip.none,
        children: [
          HomeTopVideo(isTablet: false),
          Positioned(
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(titlePlatinumFamilyOwnerDue.isNotEmpty)
                  Container(
                    height: CommonUtil.getTopBarHeight(context),
                    margin: EdgeInsets.only(top: CommonUtil.getSafeBarTop(), bottom: 20),
                    alignment: Alignment.center,
                    child: Text(
                        titlePlatinumFamilyOwnerDue,
                        style: JTTextStyle.titleSmall.copyWith(color: Colors.white)
                    ),
                  ),
                Text(
                    loc.homeTopTitle,
                    style: JTTextStyle.bodyLarge2.copyWith(color: Colors.white.withValues(alpha: 0.8))
                ),
                const SizedBox(height: 6),
                Text(
                    loc.claimHomeTopSubtitle,
                    style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                ),
              ],
            ),
          ),
          // Buy按钮悬浮
        ],
      );
    }
    return ConstrainedContainer(
      child: Row(
        children: [
          Expanded( // 文字部分
            flex: 358,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    loc.homeTopTitle,
                    style: JTTextStyle.titleMedium.copyWith(color: JTColorStyle.secondaryTextColor)
                ),
                const SizedBox(height: 12),
                Text(
                  loc.claimHomeTopSubtitle,
                  style: JTTextStyle.headlineMedium,
                ),
              ],
            ),
          ),
          SizedBox(width: 50),
          Expanded(
            flex: 320,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
              clipBehavior: Clip.antiAlias,
              child: HomeTopVideo(isTablet: true),
            ),
          ),
        ],
      ),
    );
  }

// 手机场景卡片1
  Widget _buildMobileSceneCard1() {
    return Container(
      constraints: BoxConstraints(maxWidth: cContentMaxWidth),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ImageUtil.loadLocalImage(
            context,
            ImageLibrary.homeTalk,
            height: 500,
            width: double.infinity,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  style: JTTextStyle.headlineSmall2.copyWith(color: Colors.white),
                  TextSpan(
                    text: loc.tapToTalk,
                    children: [
                      TextSpan(
                          text: loc.justTalk,
                          style: JTTextStyle.headlineSmall2.copyWith(color: Color(0xFF00F6FF))
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    loc.sendAndReceiveVoiceMessages,
                    style: JTTextStyle.bodyMedium.copyWith(color: Colors.white)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 手机场景卡片2（文字叠加，图片高500）
  Widget _buildMobileSceneCard2() {
    return Container(
      constraints: BoxConstraints(maxWidth: cContentMaxWidth),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ImageUtil.loadLocalImage(context,
              ImageLibrary.homeSmartListening,
              height: 500,
              width: double.infinity
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: loc.smartListening,
                    style: JTTextStyle.headlineSmall2.copyWith(color: Color(0xFFFFEB3B)),
                    children: [
                      TextSpan(
                        text: loc.parentApproved,
                        style: JTTextStyle.headlineSmall2.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.setLimitsOnTimeAndVolume,
                  style: JTTextStyle.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 平板场景区域
  Widget _buildTabletSceneCard({
    required String imageAsset,
    required TextSpan titleTextSpan,
    required String subtitleText,
    bool imageOnRight = true
  }) {
    final List<Widget> children = [
      Expanded( // 文字部分
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(titleTextSpan),
            const SizedBox(height: 24),
            Text(
              subtitleText,
              style: JTTextStyle.titleMedium.copyWith(color: JTColorStyle.secondaryTextColor),
            ),
          ],
        ),
      ),
      const SizedBox(width: 50),
      Expanded( // 图片部分
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ImageUtil.loadLocalImage(context,
              imageAsset,
              width: 320,
              fit: BoxFit.contain
          ),
        ),
      ),
    ];
    return ConstrainedContainer(
        child: Row(children: imageOnRight ? children : children.reversed.toList())
    );
  }

  /// 第一张：总览页面（包含3个小组件）
  Widget _buildOverviewCard(bool isTablet) {
    double hPadding = isTablet ? 24 : 20;
    double vPadding = isTablet ? 24 : 16;
    TextStyle titleStyle = JTTextStyle.getHomeCardTextStyle(isTablet);
    return Column(children: [
      Row(children: [
        // 左侧大卡片
        Expanded(
          child: Container(
            width: double.infinity,
            height: isTablet ? 478 : 383,
            padding: EdgeInsets.only(top: vPadding),
            decoration: BoxDecoration(color: const Color(0xFFE9FAFF), borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(horizontal: hPadding),
                    child: SubstringHighlight(
                        text: loc.manageDailyUsageTime,
                        terms: [loc.manage, loc.usageTime],
                        textStyle: titleStyle,
                        textStyleHighlight: titleStyle.copyWith(color: Color(0xFF00A6FF))
                    )),
                Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                          ImageLibrary.usageTimePhone,
                          width: isTablet ? 237 : double.infinity,
                          fit: BoxFit.contain
                      )
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        // 右侧两小卡片
        Expanded(
          child: Column(
            children: [
              Container(
                height: isTablet ? 248 : 220,
                decoration: BoxDecoration(
                    color: Color(isTablet ? 0xFFFFF7DE : 0xFFFFF9E4),
                    borderRadius: BorderRadius.circular(28)),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: hPadding, top: vPadding, right: hPadding),
                      child: SubstringHighlight(
                        text: loc.setSafeMaximumVolumeLimits,
                        term: loc.safeMaximumVolume,
                        textStyle: titleStyle,
                        textStyleHighlight: titleStyle.copyWith(color: Color(0xFFFF7700)),
                      ),
                    ),
                    // Spacer(),
                    SizedBox(height: 6),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              ImageLibrary.volumePhone,
                              width: isTablet
                                  ? constraints.maxWidth * 211 / 359  // 平板
                                  : constraints.maxWidth * 128 / 176, // 手机
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: isTablet ? 220 : 153,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFEAFFFD), borderRadius: BorderRadius.circular(28)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                        ImageLibrary.batteryMeter,
                        height: isTablet ? 54 : 34,
                        fit: BoxFit.fitHeight),
                    Text(
                      loc.smartBatteryMonitor,
                      style: isTablet ? JTTextStyle.bodyLarge2 : JTTextStyle.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(ImageLibrary.batteryIcon,
                            width: isTablet ? 70 : 50,
                            height: isTablet ? 48 : 34,
                            fit: BoxFit.fitHeight),
                        SizedBox(width: isTablet ? 10 : 5),
                        Text('100%',
                            style: (isTablet ? JTTextStyle.displayMedium : JTTextStyle.headlineMedium)
                                .copyWith(color: Color(0xFF00DFBD), fontWeight: isTablet ? null : FontWeight.w500)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      ),
      SizedBox(height: 10),
      // 下方 usage report
      Container(
        height: isTablet ? 191 : 140,
        decoration: BoxDecoration(
            color: Color(isTablet ? 0xFFF0ECFF : 0xFFF2EFFF),
            borderRadius: BorderRadius.circular(28)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: hPadding, top: vPadding),
                child: SubstringHighlight(
                  text: loc.accessUsageReports,
                  term: loc.usageReports,
                  textStyle: titleStyle,
                  textStyleHighlight: titleStyle.copyWith(color: Color(0xFF6A48FF)),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(right: isTablet ? 90 : 20), // 移除右边距解决单词换行问题
              child: Image.asset(
                  ImageLibrary.usageReport, height: isTablet ? 170 : 126,
                  fit: BoxFit.contain),
            )
          ],
        ),
      ),
    ],
    );
  }

  /// 第二张：详细设备管理界面
  Widget _buildDetailedDeviceManagementCard() {
    return Container(
      padding: const EdgeInsets.only(left: 32, top: 32, right: 32),
      decoration: BoxDecoration(color: const Color(0xFFF3FAFF), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubstringHighlight(
            text: loc.manageDailyUsageTime,
            terms: [loc.manage, loc.usageTime],
            textStyle: JTTextStyle.headlineSmall,
            textStyleHighlight: JTTextStyle.headlineSmall.copyWith(color: Color(0xFF00A6FF)),
          ),
          const SizedBox(height: 34),
          Center(child: ImageUtil.loadLocalImage(
              context,ImageLibrary.usageTimePhone, height: 400, fit: BoxFit.contain)
          )
        ],
      ),
    );
  }

  /// 第三张：详细音量控制界面
  Widget _buildDetailedVolumeControlCard() {
    return Container(
      padding: const EdgeInsets.only(left: 32, top: 32, right: 32),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E7), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubstringHighlight(
            text: loc.setSafeMaximumVolumeLimits,
            term: loc.safeMaximumVolume,
            textStyle: JTTextStyle.headlineSmall,
            textStyleHighlight: JTTextStyle.headlineSmall.copyWith(color: Color(0xFFFF7700)),
          ),
          Spacer(),
          Center(
              child: ImageUtil.loadLocalImage(
                  context, ImageLibrary.volumePhone2, height: 381,
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.contain)
          )
        ],
      ),
    );
  }

  /// 第四张：电池监控界面
  Widget _buildBatteryMonitorCard() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFFEAFFFD), borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImageLibrary.batteryMeter,
              height: 72,
              fit: BoxFit.contain
          ),
          const SizedBox(height: 8),
          Text(
            loc.smartBatteryMonitor,
            style: JTTextStyle.headlineSmall,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(ImageLibrary.batteryIcon,
                  height: 65,
                  fit: BoxFit.contain
              ),
              const SizedBox(width: 8),
              const Text('100%',
                style: TextStyle(
                  color: Color(0xFF00DFBD),
                  fontWeight: FontWeight.w600,
                  fontSize: 51,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 第五张：使用报告卡片
  Widget _buildUsageReportsCard() {
    return Container(
      padding: const EdgeInsets.only(left: 32, top: 32, right: 32),
      decoration: BoxDecoration(color: const Color(0xFFF0ECFF), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubstringHighlight(
              text: loc.accessUsageReports,
              term: loc.usageReports,
              textStyle: JTTextStyle.headlineSmall,
              textStyleHighlight: JTTextStyle.headlineSmall.copyWith(color: Color(0xFF6A48FF))
          ),
          Spacer(),
          Center(child: ImageUtil.loadLocalImage(
              context,
              ImageLibrary.usageReport2,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              fit: BoxFit.contain)
          )
        ],
      ),
    );
  }

  /// Includes All “Premium Family” Features 卡片
  Widget _buildIncludeFuturesCard(bool isTablet) {
    double padding = isTablet ? 24 : 20;
    double iconSize = isTablet ? 36 : 28;
    TextStyle titleStyle = JTTextStyle.getHomeCardTextStyle(isTablet);
    return Column(
      children: [
        /// 第一行卡片
        Row(children: [
          Expanded(child: featuresWidget(
              width: double.infinity,
              height: isTablet ? 316 : 250,
              color: Color(isTablet ? 0xFFFFF6D9 : 0xFFFFF9E4),
              icon: ImageLibrary.icMember,
              image: ImageLibrary.imgMembers01,
              textWidget: SubstringHighlight(
                  text: loc.upTo6MembersIncluded,
                  term: loc.sixMembers,
                  textStyleHighlight: titleStyle.copyWith(color: Color(0xFFFF7200)),
                  textStyle: titleStyle
              ),
              isTablet: isTablet
          ),
          ),
          SizedBox(width: 10),
          Expanded(child: featuresWidget(
              width: double.infinity,
              height: isTablet ? 316 : 250,
              color: Color(0xFFE9FFEE),
              icon: ImageLibrary.icFriends,
              image: ImageLibrary.imgFriendsManagement01,
              textWidget: SubstringHighlight(
                text: loc.kidsFriendsManagement,
                term: loc.friendsManagement,
                textStyle: titleStyle,
                textStyleHighlight: titleStyle.copyWith(color: Color(0xFF00D430)),
              ),
              isTablet: isTablet
          ),
          )
        ]),
        SizedBox(height: 10),
        /// 第二行卡片
        Row(children: [
          Expanded(
            flex: isTablet ? 424 : 210,
            child: featuresWidget(
                width: double.infinity,
                height: isTablet ? 316 : 224,
                color: isTablet ? Color(0xFFF7E9FF) : Color(0xFFF9EEFF),
                icon: ImageLibrary.icLiveLocation,
                image: ImageLibrary.imgLiveLocation01,
                textWidget: Text(loc.liveLocation, style: titleStyle.copyWith(color: Color(0xFFC800FF))),
                isTablet: isTablet
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: isTablet ? 294 : 142,
            child: featuresWidget(
                width: double.infinity,
                height: isTablet ? 316 : 224,
                color: isTablet ? Color(0xFFFFEEF3) : Color(0xFFFFEFF4),
                icon: ImageLibrary.icSensitiveContentControl,
                image: ImageLibrary.imgSensitiveContentControl01,
                textWidget: Text(loc.sensitiveContentControl, style: titleStyle.copyWith(color: Color(0xFFFF1D49))),
                isTablet: isTablet
            ),
          )
        ],
        ),
        SizedBox(height: 10),
        /// 第三行卡片
        Container(
          width: double.infinity,
          height: isTablet ? null : 142,
          padding: EdgeInsets.fromLTRB(padding, padding, isTablet ? 107 : 31, padding),
          decoration: BoxDecoration(
              color: isTablet ? Color(0xFFEFEFFF) : Color(0xFFEDEDFF),
              borderRadius: BorderRadius.circular(28)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ImageLibrary.icFeatures,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain),
                  SizedBox(height: 12),
                  SubstringHighlight(
                      text: loc.unlimitedCreativeFunFeatures,
                      terms: [loc.creative, loc.features],
                      textStyle: titleStyle,
                      textStyleHighlight: titleStyle.copyWith(color: Color(0xFF7A59FF)))
                ],
              ),
              ),
              SizedBox(width: 8),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  ImageLibrary.imgFeatures01,
                  height: isTablet ? 124 : 90,
                  fit: BoxFit.contain,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget featuresWidget({
    required double width,
    required Color color,
    required String icon,
    required String image,
    required Widget textWidget,
    required bool isTablet,
    double? imageHeight,
    double? height,
    bool multiCard = true,
  }) {
    double iconSize = multiCard ? (isTablet ? 36 : 28) : 42;
    double padding = multiCard ? (isTablet ? 24 : 20) : 32;
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(icon, width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain),
                    SizedBox(height: multiCard ? 12 : 20),
                    textWidget,
                  ])),
          SizedBox(height: isTablet ? 12 : 8),
          Expanded(child:
          ImageUtil.loadLocalImage(
              context,
              image,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              width: double.infinity
          )
          )
        ],
      ),
    );
  }

  ///  查询是否可以领会员
  void _membershipEligibility(bool isTablet) {
    if (isWebDesignMode) {
      NavUtils.pushNamed(context, AppRoutes.membershipActivation, arguments: {'sessionId': 'test', 'productId': 'test'});
      return;
    }
    double dialogWidth = isTablet ? 448 : double.infinity;
    consoleLog('$_tag: queryUrl:${web.window.location.href}');
    final Map<String, dynamic> orderParams = {
      'action': 'membershipEligibility',
      'bluetoothMac': macAddress,
    };
    try {
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, orderParams.jsify(), (JSAny? responseData) {
          consoleLog('$_tag: responseData: $responseData');
          final Map? responseMap = jsAnyToMap(responseData);
          if (responseMap == null || !responseMap.containsKey("result")) {
            _showErrorDialog(loc.tipNetworkError, dialogWidth);
            return;
          }
          int result = responseMap['result'] as int? ?? 3;
          switch (result) {
            case 0:
              _claimMembership(isTablet);
              break;
            case 1:
              _showErrorDialog(loc.tipClaimUnavailable, dialogWidth);
              break;
            case 2:
              _showErrorDialog(loc.tipRegionUnavailable, dialogWidth);
              break;
            default:
              _showErrorDialog(loc.tipNetworkError, dialogWidth);
          }
        }.toJS);
    } catch (e) {
      consoleLog('$_tag: WebViewJavascriptBridge error: $e');
      Navigator.of(context).pop();
      _showErrorDialog(loc.tipNetworkError, dialogWidth);
    }
  }

  ///  领取会员流程
  void _claimMembership(bool isTablet) {
    double dialogWidth = isTablet ? 448 : double.infinity;
    final String productId = ProductConfig.membershipClaimWithoutHeadphones;
    final String color = TrackerConstants.eventValueColorNoDevice;
    final Map<String, String> metadata = {'bluetoothMac': macAddress};
    final Map<String, dynamic> orderParams = {
      'action': 'createOrder',
      'platform': 'stripe',
      'productId': productId,
      'successUrl': '${ProductConfig.myUrl}?page=${AppRoutes.payResultEmpty}&color=$color&productId=$productId&trackerMap=${jsonEncode(traceDataMap)}&payResult=ok',
      'test': isTestMode,
      'metadata': metadata.jsify(),
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Container(
              width: dialogWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red), strokeWidth: 3),
                  const SizedBox(height: 20),
                  Text(
                    loc.preparingCheckout,
                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    // 检查 WebViewJavascriptBridge 是否可用
    try {
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, orderParams.jsify(), (JSAny? responseData) {
          // 关闭加载弹框
          Navigator.of(context).pop();
          consoleLog('$_tag: responseData: $responseData');
          final Map? responseMap = jsAnyToMap(responseData);
          // 从响应中提取 paymentLink 并打开
          if (responseMap != null && responseMap.containsKey('paymentLink')) {
            final String? paymentLink = responseMap['paymentLink'] as String?;
            final String? sessionId = responseMap['sessionId'] as String?;
            if (paymentLink != null && paymentLink.isNotEmpty) {
              consoleLog('$_tag: opening payment link: $paymentLink');
              // 调用 loadingSuccess
              JsBridgeManager.loadingSuccess();
              TrackerManager.payClick(ProductConfig.membershipClaimWithoutHeadphones);
              consoleLog('$_tag: called loadingSuccess');
              if (CommonUtil.unSupportNewJs()) {
                CommonUtil.openUrl(paymentLink);
              } else {
                JsBridgeManager.startNewH5ForResult(CommonUtil.getFitSystemWindowsUrl(paymentLink));
                Future.delayed(Duration(milliseconds: 500), () {
                  showPayConfirmDialog(productId,sessionId);
                });
              }
            } else {
              consoleLog('$_tag: paymentLink is null or empty');
              _showErrorDialog(loc.tipNetworkError, dialogWidth);
            }
          } else {
            consoleLog('$_tag: responseMap is null or does not contain paymentLink');
            _showErrorDialog(loc.tipNetworkError, dialogWidth);
          }
        }.toJS,
      );
    } catch (e) {
      consoleLog('$_tag: WebViewJavascriptBridge error: $e');
      Navigator.of(context).pop();
      _showErrorDialog(loc.tipNetworkError, dialogWidth);
    }
  }

  void _showErrorDialog(String message, double dialogWidth) {
    showDialog(context: context, barrierDismissible: true, builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
            width: dialogWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: JTTextStyle.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 216,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF2C55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                      onPressed: () {
                        Navigator.of(context).pop();
                        JsBridgeManager.finishWeb();
                      },
                    child: Text(
                      loc.ok,
                      style: JTTextStyle.bodyLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }

  void queryNewH5Result() {
    JsBridgeManager.queryNewH5Result(callback: (Map responseMap) {
      consoleLog('openH5PurchaseUrlResult: map $responseMap');
      if (preRegisterMode) {
        NavUtils.pushReplacement(context, PreEmptyPage(
          sessionId: responseMap['sessionId'],
          productId: responseMap['productId'],
        ));
      } else {
        NavUtils.pushReplacement(context, TalkiePodsMembershipActivationPage(
          sessionId: responseMap['sessionId'],
          productId: responseMap['productId'],
        ));
      }
    });
  }

  void showPayConfirmDialog(String productId, String? sessionId) {
    DialogManager.showCommonDialog(
        context: context,
        titleStr: loc.payConfirmDialogTitle,
        confirmStr: loc.payConfirmDialogButtonDone,
        cancelStr: loc.payConfirmDialogButtonUnDone,
        barrierDismissible: false,
        canPop: false,
        showCancelButton: true,
        onConfirm: () {
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogDone);
          DialogManager.showLoadingDialog();
          _callPurchaseMethod(productId,sessionId);
        },
        onCancel: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogUnDone);
          showPayUnDoneDialog(productId,sessionId);
        }
    );
  }

  void showPayUnDoneDialog(String productId, String? sessionId) {
    DialogManager.showThreeButtonDialog(
        context: context,
        titleStr: loc.payUnDoneDialogTitle,
        primaryStr: loc.payUnDoneDialogButtonContinue,
        secondaryStr: loc.payUnDoneDialogButtonAbandon,
        tertiaryStr: loc.payUnDoneDialogButtonFeedback,
        barrierDismissible: false,
        canPop: false,
        onPrimary: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogContinue);
          _claimMembership(CommonUtil.isTablet(context));
        },
        onSecondary: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogAbandon);
        },
        onTertiary: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogFeedback);
          CommonUtil.openUrl(UrlConstants.feedbackUrlWithLabel);
        }
    );
  }

  /// 调用JS purchase方法
  void _callPurchaseMethod(String productId, String? sessionId) {
    final map = Map<String, dynamic>.from(traceDataMap);
    map['action'] = TrackerConstants.eventValueActionUserReport;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
    map['product'] = productId;
    try {
      final Map<String, dynamic> purchaseParams = {
        'action': 'purchase',
        'productId': productId,
        'token': sessionId,
        'eventType': 'platinumFamily',
        'traceData': map,
        'test': isTestMode,
      };
      final String paramsJson = jsonEncode(purchaseParams);
      consoleLog('$_tag: 调用purchase方法，参数: $paramsJson');
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.jsify(), (JSAny? responseData) {
        consoleLog('$_tag: purchase方法响应: $responseData');
        DialogManager.dismissLoadingDialog();
        final Map<String, dynamic>? responseMap = jsAnyToMap(responseData);
        if (responseMap != null) {
          consoleLog('$_tag: purchase响应解析成功: $responseMap');
          if (responseMap.containsKey('platinumFamilyOwnerDue')) {
            final dynamic platinumFamilyOwnerDue = responseMap['platinumFamilyOwnerDue'];
            if (platinumFamilyOwnerDue is int) {
              _platinumFamilyOwnerDue = platinumFamilyOwnerDue;
              int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
              titlePlatinumFamilyOwnerDue = (_platinumFamilyOwnerDue > 0 && _platinumFamilyOwnerDue > currentTimeMillis) ? sprintf(loc.titlePlatinumExpiresOnFormat, [_platinumFamilyOwnerDue]) : "";
              consoleLog('$_tag: 更新platinumDue时间戳: $platinumFamilyOwnerDue');
            }
          }
          bool result = responseMap['result'] ?? false;
          if (result) {
            Navigator.of(context).pop();
            NavUtils.pushReplacement(context, TalkiePodsMembershipActivationPage(
              sessionId: sessionId,
              productId: productId,
              platinumFamilyOwnerDue: _platinumFamilyOwnerDue,
              result: true,
            ));
          } else {
            Navigator.of(context).pop();
            showPayUnDoneDialog(productId, sessionId);
          }
        } else {
          Navigator.of(context).pop();
          showPayUnDoneDialog(productId, sessionId);
        }
      }.toJS,
      );
    } catch (e) {
      DialogManager.dismissLoadingDialog();
      consoleLog('$_tag: 调用purchase方法失败: $e');
      Navigator.of(context).pop();
      showPayUnDoneDialog(productId, sessionId);
    }
  }

}

/// 复用 web_home 页
class _FeatureBlock extends StatelessWidget {
  final String image;
  final String title;
  final String desc;
  final bool isTablet;
  const _FeatureBlock({required this.image, required this.title, required this.desc,required this.isTablet});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(image,
            height: isTablet ? 60 : 40,
            fit: BoxFit.contain),
        const SizedBox(height: 20),
        Text(title, style: JTTextStyle.titleMedium),
        const SizedBox(height: 12),
        Text(desc, style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor)),
      ],
    );
  }
}

