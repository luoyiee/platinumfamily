import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:earlybird/src/constants/constants.dart';
import 'package:earlybird/src/manager/user_type_manager.dart';
import 'package:earlybird/src/routes/app_routes.dart';
import 'package:earlybird/src/utils/common_utils.dart';
import 'package:earlybird/src/utils/nav_utils.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../../main.dart';
import '../../../res/color_style.dart';
import '../../../res/image_library.dart';
import '../../../res/string_library.dart';
import '../../../res/text_style.dart';
import '../../config/price_config.dart';
import '../../manager/tracker_manager.dart';
import '../../utils/image_utils.dart';
import '../../view/constraints_container.dart';
import '../../view/home_top_video.dart';
import '../../view/horizontal_gradient_text.dart';

class TalkiePodsHomePage extends StatefulWidget {
  const TalkiePodsHomePage({super.key});
  @override
  State<TalkiePodsHomePage> createState() => _TalkiePodsHomePageState();
}

class _TalkiePodsHomePageState extends State<TalkiePodsHomePage> {
  String salePrice = '';
  String originalSalePrice = '';

  @override
  void initState() {
    super.initState();
    if (!isWebDesignMode) {
      TrackerManager.talkiePodsPlatinumBundleMarketing();
    }
    // 初始化价格（使用当前 userType）
    _updatePrices();

    // 监听 userType 变化，自动更新价格
    UserTypeManager().userTypeNotifier.addListener(_onUserTypeChanged);
  }

  @override
  void dispose() {
    // 移除监听器
    UserTypeManager().userTypeNotifier.removeListener(_onUserTypeChanged);
    super.dispose();
  }

  /// 当 userType 变化时触发
  void _onUserTypeChanged() {
    if (mounted) {
      _updatePrices();
    }
  }

  /// 更新价格信息
  void _updatePrices() {
    setState(() {
      final currentUserType = UserTypeManager().userType;
      salePrice = PriceConfigManager.instance.getIntroPrice(currentUserType);
      originalSalePrice = PriceConfigManager.instance.getIntroOriginalPrice(currentUserType);
    });
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
          TextStyle cardTextStyle = JTTextStyle.getHomeCardTextStyle(isTablet);
          TextStyle titleStyle = JTTextStyle.getHomeTitleStyle(isTablet);
          return Stack(
            children: [
              // 主体内容可滑动
              SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 52 + 40 + CommonUtil.getSafeBarBottom() + 12),
                  child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(isTablet)
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
                              imageAsset: ImageLibrary.homeTalkTablet,
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
                              imageAsset: ImageLibrary.homeSmartListeningTablet,
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
                            margin: const EdgeInsets.symmetric(horizontal: 20),
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
                                  style: isTablet ? JTTextStyle.headlineMedium : JTTextStyle.headlineSmall,
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
                                      style: titleStyle
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
                                                    textStyle: cardTextStyle,
                                                    textStyleHighlight: cardTextStyle.copyWith(color: Color(0xFF00DFBD))
                                                ),
                                              ),
                                              SizedBox(height: isTablet ? 50 : 26),
                                              Center(child: Image.asset(
                                                  ImageLibrary.box01,
                                                  height: isTablet ? 216 : 150,
                                                  fit: BoxFit.contain
                                              )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 11),
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
                                                  textStyle: cardTextStyle,
                                                  textStyleHighlight: cardTextStyle.copyWith(color: Color(0xFFFFB700))
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
                                      style: titleStyle
                                  ),
                                ),
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
                                style: titleStyle,
                                textAlign: TextAlign.center
                            ),
                          ),
                          SizedBox(height: isTablet ? 30 : 24),
                          CarouselSlider(
                            disableGesture: isTablet,
                            options: CarouselOptions(
                                height: isTablet ? 830 : 636,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: false
                            ),
                            items: [
                              ConstrainedContainer(child: _buildIncludeFuturesCard(isTablet)),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF261501),
                                    icon: ImageLibrary.icMember2,
                                    image: ImageLibrary.imgMembers02,
                                    multiCard: false,
                                    textWidget: Text(
                                          loc.upTo6MembersIncluded,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                    ),
                                    isTablet: isTablet
                                ),
                              ),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF368DFF),
                                    icon: ImageLibrary.icFriends2,
                                    image: ImageLibrary.imgFriendsManagement02,
                                    multiCard: false,
                                    textWidget: Text(
                                          loc.kidsFriendsManagement,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                    ),
                                    isTablet: isTablet
                                ),
                              ),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF865EFF),
                                    icon: ImageLibrary.liveLocation24,
                                    image: ImageLibrary.imgLiveLocation02,
                                    multiCard: false,
                                    imageHeight: 436,
                                    textWidget: Text(
                                          loc.liveLocation,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                    ),
                                    isTablet: isTablet
                                ),
                              ),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF18CEEA),
                                    icon: ImageLibrary.icSensitiveContentControl2,
                                    image: ImageLibrary.imgSensitiveContentControl02,
                                    multiCard: false,
                                    textWidget: Text(
                                          loc.sensitiveContentControl,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                    ),
                                    isTablet: isTablet
                                ),
                              ),
                              ConstrainedContainer(
                                child: featuresWidget(
                                    width: double.infinity,
                                    color: Color(0xFF00E081),
                                    icon: ImageLibrary.icFeatures02,
                                    image: ImageLibrary.imgFeatures02,
                                    multiCard: false,
                                    textWidget:  Text(
                                          loc.unlimitedCreativeFunFeatures,
                                          style: JTTextStyle.headlineSmall.copyWith(color: Colors.white)
                                    ),
                                    isTablet: isTablet
                                ),
                              ),
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
                          SizedBox(height: isTablet ? 110 : 100),
                          ConstrainedContainer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🎁', style: JTTextStyle.headlineSmall),
                                SizedBox(width: 4),
                                Flexible(
                                  child: HorizontalGradientText(
                                    loc.officialUnlockBundleNow,
                                    style: JTTextStyle.headlineSmall,
                                    textAlign: TextAlign.center,
                                    colors: const [
                                      Color(0xFF3015FF),
                                      Color(0xFFB515FF),
                                      Color(0xFFFF1524),
                                      Color(0xFFFF9000),
                                      Color(0xFFFFEE00),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          ConstrainedContainer(
                            child: Image.asset(
                              ImageLibrary.imgOfficialUnlockBundle,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                            ),
                          )
                        ],
                      ))
              ),
              // 底部悬浮按钮区
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: CommonUtil.getSafeBarBottom() + 24,
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: isTablet ? 343 : 315),
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: JTColorStyle.themeColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 4,
                            padding: EdgeInsets.symmetric(vertical: 12)
                        ),
                        onPressed: () {
                          if (!isWebDesignMode) {
                            TrackerManager.talkiePodsPlatinumBundleMarketingAction();
                          }
                          NavUtils.pushNamed(context, AppRoutes.productDetail);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                                sprintf(loc.homeBuy, [salePrice]),
                                style: JTTextStyle.headlineSmall3.copyWith(color: Colors.white)
                            ),
                            SizedBox(width: 4),
                            Text(
                                originalSalePrice,
                                style: JTTextStyle.titleSmall.copyWith(color: Colors.white.withValues(alpha: 0.7),
                                    decorationColor: Colors.white.withValues(alpha: 0.7),
                                    decoration: TextDecoration.lineThrough)
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ),
            ],
          );
        },
      ),
    );
  }

  // 视频区域
  Widget _buildVideoCard(bool isTablet) {
    if (!isTablet) {
      // 顶部大图、标题、副标题、Buy按钮、Bind提示
      return Stack(
        clipBehavior: Clip.none,
        children: [
          HomeTopVideo(isTablet: isTablet,
            video: isTablet ? ImageLibrary.officialHomeTabletVideo : ImageLibrary.officialHomeVideo),
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: CommonUtil.getTopBarHeight(context),
                  margin: EdgeInsets.only(
                      top: CommonUtil.getSafeBarTop(),
                      bottom: 20
                  ),
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
                    loc.officialHomeTopSubtitle,
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
                  loc.homeTopSubtitle,
                  style: JTTextStyle.headlineMedium,
                ),
              ],
            ),
          ),
          SizedBox(width: 50),
          Expanded( // 图片部分
            flex: 320,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
              clipBehavior: Clip.antiAlias,
              child: HomeTopVideo(isTablet: isTablet,
                  video: isTablet ? ImageLibrary.officialHomeTabletVideo : ImageLibrary.officialHomeVideo),
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

}

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