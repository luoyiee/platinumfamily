import 'package:flutter/material.dart';

import 'lang/ar.dart';
import 'lang/de.dart';
import 'lang/en.dart';
import 'lang/es.dart';
import 'lang/fr.dart';
import 'lang/hi.dart';
import 'lang/id.dart';
import 'lang/it.dart';
import 'lang/ja.dart';
import 'lang/ko.dart';
import 'lang/nl.dart';
import 'lang/pt.dart';
import 'lang/ru.dart';
import 'lang/tr.dart';
import 'lang/vi.dart';
import 'lang/zh.dart';
import 'lang/zh_tw.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'ar': ar,
    'de': de,
    'es': es,
    'fr': fr,
    'hi': hi,
    'id': id,
    'it': it,
    'ja': ja,
    'ko': ko,
    'nl': nl,
    'pt': pt,
    'ru': ru,
    'tr': tr,
    'vi': vi,
    'zh': zh,
    'zh_TW': zhTW,
  };

  String _get(String key) {
    final lang = locale.languageCode;
    final country = locale.countryCode;
    final full = country != null && country.isNotEmpty ? '${lang}_$country' : lang;
    final value = _localizedValues[full]?[key]
        ?? _localizedValues[lang]?[key]
        ?? _localizedValues['en']?[key];
    if (value == null) {
      assert(() {
        throw FlutterError('Missing translation for key: $key (lang: $lang)');
      }());
      return key;
    }
    return value;
  }

  // 类型安全的 getter - 只保留实际使用的翻译键
  String get homeTopTitle => _get('homeTopTitle');
  String get homeTopSubtitle => _get('homeTopSubtitle');
  String get homeMembershipTitle => _get('homeMembershipTitle');
  String get homeBuy => _get('homeBuy');
  String get justTalk => _get('justTalk');
  String get tapToTalk => _get('tapToTalk');
  String get sendAndReceiveVoiceMessages => _get('sendAndReceiveVoiceMessages');
  String get smartListening => _get('smartListening');
  String get parentApproved => _get('parentApproved');
  String get setLimitsOnTimeAndVolume => _get('setLimitsOnTimeAndVolume');
  String get safeOpenEar => _get('safeOpenEar');
  String get hearAndAware => _get('hearAndAware');
  String get allDayBattery => _get('allDayBattery');
  String get battery20hFastCharge => _get('battery20hFastCharge');
  String get durableWaterResistant => _get('durableWaterResistant');
  String get flexibleIpx5Safe => _get('flexibleIpx5Safe');
  String get lightBendableComfort => _get('lightBendableComfort');
  String get exclusiveDeviceProtection => _get('exclusiveDeviceProtection');
  String get freeReplacementTitle => _get('freeReplacementTitle');
  String get free => _get('free');
  String get replacement => _get('replacement');
  String get priorityTitle => _get('priorityTitle');
  String get on1Support => _get('on1Support');
  String get enhancedParentalDeviceControls => _get('enhancedParentalDeviceControls');
  String get smartBatteryMonitor => _get('smartBatteryMonitor');
  String get accessUsageReports => _get('accessUsageReports');
  String get usageReports => _get('usageReports');
  String get manageDailyUsageTime => _get('manageDailyUsageTime');
  String get featherlightComfort => _get('featherlightComfort');
  String get manage => _get('manage');
  String get usageTime => _get('usageTime');
  String get setSafeMaximumVolumeLimits => _get('setSafeMaximumVolumeLimits');
  String get safeMaximumVolume => _get('safeMaximumVolume');
  String get tripleLeftArrowSwipeLeftToSeeMore => _get('tripleLeftArrowSwipeLeftToSeeMore');
  String get includesAllPremiumFamilyFeatures => _get('includesAllPremiumFamilyFeatures');
  String get upTo6MembersIncluded => _get('upTo6MembersIncluded');
  String get sixMembers => _get('sixMembers');
  String get kidsFriendsManagement => _get('kidsFriendsManagement');
  String get friendsManagement => _get('friendsManagement');
  String get liveLocation => _get('liveLocation');
  String get sensitiveContentControl => _get('sensitiveContentControl');
  String get unlimitedCreativeFunFeatures => _get('unlimitedCreativeFunFeatures');
  String get creative => _get('creative');
  String get features => _get('features');
  String get preOrderDealEndingSoon => _get('preOrderDealEndingSoon');
  String get percentOff => _get('percentOff');
  String get talkiePodsPlatinumMembershipValueOnly => _get('talkiePodsPlatinumMembershipValueOnly');
  String get fifteenMonthsTotal => _get('fifteenMonthsTotal');
  String get get15MonthsForPriceOf12 => _get('get15MonthsForPriceOf12');
  String get exclusivePerksAccess => _get('exclusivePerksAccess');
  String get joinPrivateBetaTestingGroup => _get('joinPrivateBetaTestingGroup');
  String get withDevice => _get('withDevice');
  String get oneYearPlatinumFamily => _get('oneYearPlatinumFamily');
  String get threeMonthsBonus => _get('threeMonthsBonus');
  String get bonusTimeActivatesAfterSubscriptionEnds => _get('bonusTimeActivatesAfterSubscriptionEnds');
  String get renewsAtPerYearAfterFirstYear => _get('renewsAtPerYearAfterFirstYear');
  String get madeByGiznity => _get('madeByGiznity');
  String get selectAColor => _get('selectAColor');
  String get shipsInOctoberByOrderDate => _get('shipsInOctoberByOrderDate');
  String get subscriptionTerms => _get('subscriptionTerms');
  String get terms => _get('terms');
  String get privacyPolicy => _get('privacyPolicy');
  String get paymentTerms => _get('paymentTerms');
  String get checkout => _get('checkout');
  String get paymentResult => _get('paymentResult');
  String get firstYear => _get('firstYear');
  String get thenPerYear => _get('thenPerYear');
  String get noDevice => _get('noDevice');
  // Color selection labels
  String get colorDash => _get('colorDash');
  String get colorBlue => _get('colorBlue');
  String get colorPurple => _get('colorPurple');
  String get colorNavyRed => _get('colorNavyRed');
  String get colorRedYellow => _get('colorRedYellow');
  String get colorBlackGreen => _get('colorBlackGreen');
  String get colorGreen => _get('colorGreen');
  String get colorPinkPurple => _get('colorPinkPurple');
  String get paymentSuccessfulReceipt => _get('paymentSuccessfulReceipt');
  String get paymentSuccessful => _get('paymentSuccessful');
  String get membershipActivating => _get('membershipActivating');
  String get stillActivatingThanks => _get('stillActivatingThanks');
  String get activatingThanks => _get('activatingThanks');
  String get contactSupport => _get('contactSupport');
  String get expiresOn => _get('expiresOn');
  String get done => _get('done');
  String get selectYourTalkiePodsColor => _get('selectYourTalkiePodsColor');
  String get ok => _get('ok');
  String get perYear => _get('perYear');
  String get preparingCheckout => _get('preparingCheckout');
  String get membershipClaimTitle => _get('membershipClaimTitle');
  String get membershipClaimDetailFormat => _get('membershipClaimDetailFormat');
  String get exclusiveDeviceProtectionDesc => _get('exclusiveDeviceProtectionDesc');
  String get tipClaimUnavailable => _get('tipClaimUnavailable');
  String get tipNetworkError => _get('tipNetworkError');
  String get tipRegionUnavailable => _get('tipRegionUnavailable');
  String get expiresOnFormat => _get('expiresOnFormat');
  String get claimHomeTopSubtitle => _get('claimHomeTopSubtitle');
  String get tipAvailableArea => _get('tipAvailableArea');
  String get titlePlatinumExpiresOnFormat => _get('titlePlatinumExpiresOnFormat');
  String get dialogCancel => _get('dialogCancel');
  String get tipUnregisteredOrderFormat => _get('tipUnregisteredOrderFormat');
  String get officialHomeTopSubtitle => _get('officialHomeTopSubtitle');
  String get officialUnlockBundleNow => _get('officialUnlockBundleNow');
  String get officialShipDesc => _get('officialShipDesc');
  String get updateDialogTitle => _get('updateDialogTitle');
  String get updateDialogMessage => _get('updateDialogMessage');
  String get dialogUpdate => _get('dialogUpdate');
  String get officialExpiresOnFormat => _get('officialExpiresOnFormat');

  String get promoTipZero => _get('promoTipZero');
  String get promoTipOneFormat => _get('promoTipOneFormat');
  String get promoTipTwoFormat => _get('promoTipTwoFormat');
  String get promoTipThreeFormat => _get('promoTipThreeFormat');
  String get promoTipFourFormat => _get('promoTipFourFormat');
  String get talkiePodsSelect => _get('talkiePodsSelect');
  String get platinumOnly => _get('platinumOnly');
  String get talkiePodsQtyFormat => _get('talkiePodsQtyFormat');
  String get talkiePodsMemberFormat => _get('talkiePodsMemberFormat');
  String get freePlatinumFamilyFormat => _get('freePlatinumFamilyFormat');
  String get freePlatinumFamilySubtitle => _get('freePlatinumFamilySubtitle');
  String get memberUpgradeBonus => _get('memberUpgradeBonus');
  String get memberUpgradeBonusSubtitle => _get('memberUpgradeBonusSubtitle');
  String get talkiePodsSelectOneFormat => _get('talkiePodsSelectOneFormat');
  String get talkiePodsSelectTwoFormat => _get('talkiePodsSelectTwoFormat');
  String get talkiePodsSelectThreeFormat => _get('talkiePodsSelectThreeFormat');
  String get talkiePodsSelectFourFormat => _get('talkiePodsSelectFourFormat');
  String get talkiePodsSelectFiveFormat => _get('talkiePodsSelectFiveFormat');

  String get blackFridaySpecial => _get('blackFridaySpecial');
  String get freeShipping => _get('freeShipping');
  String get freeShippingDesc => _get('freeShippingDesc');
  String get platinumFreeShippingDesc => _get('platinumFreeShippingDesc');
  String get platinumContactUs => _get('platinumContactUs');
  String get confirmPurchaseTitle => _get('confirmPurchaseTitle');
  String get confirmPurchaseMessage => _get('confirmPurchaseMessage');
  String get dialogConfirm => _get('dialogConfirm');
  String get payTalkiePodsSuccessful => _get('payTalkiePodsSuccessful');
  String get activationSuccessTip => _get('activationSuccessTip');
  String get talkiePodsSelectAFormat => _get('talkiePodsSelectAFormat');
  String get talkiePodsPolicy => _get('talkiePodsPolicy');
  String get talkiePodsPolicyDesc => _get('talkiePodsPolicyDesc');
  String get payConfirmDialogTitle => _get('payConfirmDialogTitle');
  String get payConfirmDialogButtonDone => _get('payConfirmDialogButtonDone');
  String get payConfirmDialogButtonUnDone => _get('payConfirmDialogButtonUnDone');
  String get payUnDoneDialogTitle => _get('payUnDoneDialogTitle');
  String get payUnDoneDialogButtonContinue => _get('payUnDoneDialogButtonContinue');
  String get payUnDoneDialogButtonAbandon => _get('payUnDoneDialogButtonAbandon');
  String get payUnDoneDialogButtonFeedback => _get('payUnDoneDialogButtonFeedback');
  String get labelFeedback => _get('labelFeedback');
  String get loading => _get('loading');

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final lang = locale.languageCode;
    final country = locale.countryCode;
    final full = country != null && country.isNotEmpty ? '${lang}_$country' : lang;
    return AppLocalizations._localizedValues.containsKey(full) ||
        AppLocalizations._localizedValues.containsKey(lang);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
} 