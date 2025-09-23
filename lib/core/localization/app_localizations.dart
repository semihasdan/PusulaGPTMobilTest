import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('assets/localization/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common translations
  String get appTitle => translate('app_title');
  String get startFreeTrial => translate('start_free_trial');
  String get learnMore => translate('learn_more');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get signUp => translate('sign_up');
  String get alreadyHaveAccount => translate('already_have_account');
  String get fullName => translate('full_name');
  String get organizationName => translate('organization_name');
  String get reference => translate('reference');
  String get sendRegistrationRequest => translate('send_registration_request');
  String get whyRegister => translate('why_register');
  
  // Landing page specific translations
  String get heroTitle => translate('hero_title');
  String get heroSubtitle => translate('hero_subtitle');
  String get heroDescription => translate('hero_description');
  String get pusulaGpt => translate('pusula_gpt');
  String get comedGpt => translate('comed_gpt');
  String get medDiabet => translate('med_diabet');
  String get pusulaDescription => translate('pusula_description');
  String get comedDescription => translate('comed_description');
  String get diabetDescription => translate('diabet_description');
  String get benefitsTitle => translate('benefits_title');
  String get faqTitle => translate('faq_title');
  
  // Chat screen translations
  String get chatHistory => translate('chat_history');
  String get newChat => translate('new_chat');
  String get changeModel => translate('change_model');
  String get selectAiModel => translate('select_ai_model');
  String get languageSettings => translate('language_settings');
  String get profile => translate('profile');
  String get logOut => translate('log_out');
  String get typeMessage => translate('type_message');
  String get startConversation => translate('start_conversation');
  String get askAnything => translate('ask_anything');
  String get helloUser => translate('hello_user');
  String get howCanHelp => translate('how_can_help');
  String get askAnythingPlaceholder => translate('ask_anything_placeholder');
  String get disclaimer => translate('disclaimer');
  String get settings => translate('settings');
  String get administrator => translate('administrator');
  String get premium => translate('premium');
  String get unlimited => translate('unlimited');
  
  // Screenshots section
  String get screenshotsTitle => translate('screenshots_title');
  String get pusulaInterface => translate('pusula_interface');
  String get comedDashboard => translate('comed_dashboard');
  String get diabetAnalytics => translate('diabet_analytics');
  String get pusulaInterfaceDesc => translate('pusula_interface_desc');
  String get comedDashboardDesc => translate('comed_dashboard_desc');
  String get diabetAnalyticsDesc => translate('diabet_analytics_desc');
  
  // Benefits section
  String get fastAccurate => translate('fast_accurate');
  String get fastAccurateDesc => translate('fast_accurate_desc');
  String get securePrivate => translate('secure_private');
  String get securePrivateDesc => translate('secure_private_desc');
  String get easyIntegration => translate('easy_integration');
  String get easyIntegrationDesc => translate('easy_integration_desc');
  String get support247 => translate('support_247');
  String get support247Desc => translate('support_247_desc');
  
  // FAQ section
  String get faqWhatIs => translate('faq_what_is');
  String get faqWhatIsAnswer => translate('faq_what_is_answer');
  String get faqSecurity => translate('faq_security');
  String get faqSecurityAnswer => translate('faq_security_answer');
  String get faqIntegration => translate('faq_integration');
  String get faqIntegrationAnswer => translate('faq_integration_answer');
  String get faqTrial => translate('faq_trial');
  String get faqTrialAnswer => translate('faq_trial_answer');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr', 'ar', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}