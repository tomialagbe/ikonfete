import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get title {
    return Intl.message('Ikonfete',
        name: 'title', desc: 'The application title');
  }

  String get splashScreenText {
    return Intl.message(
      'Harness the power of\n your fan base and loyalty',
      name: 'splashScreenText',
      desc: 'The text at the bottom of the splash screen',
    );
  }

  String get onboardText1 {
    return Intl.message(
      'Connect with your\n true fans or favourite artist.',
      name: 'onboardText1',
      desc: 'The text of the first slide of the onboarding slider',
    );
  }

  String get onboardText2 {
    return Intl.message(
      'Understand your fan\n base with analytics.',
      name: 'onboardText2',
      desc: 'The text of the second slide of the onboarding slider',
    );
  }

  String get onboardText3 {
    return Intl.message(
      'Leverage your fan base\n and artist loyalty.',
      name: 'onboardText3',
      desc: 'The text of the third slide of the onboarding slider',
    );
  }

  String get onboardText4 {
    return Intl.message(
      'Choose what you want\n to stream, anytime.',
      name: 'onboardText4',
      desc: 'The text of the fourth slide of the onboarding slider',
    );
  }

  String get artistSignupButtonText {
    return Intl.message(
      'I\'M AN ARTIST',
      name: 'artistSignupButtonText',
      desc: 'The text on the artist signup button on the onboarding screen',
    );
  }

  String get fanSignupButtonText {
    return Intl.message(
      'I\'M A FAN',
      name: 'fanSignupButtonText',
      desc: 'The text on the fan signup button on the onboarding screen',
    );
  }

  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: 'The skip button at the top of the onboarding page',
    );
  }

  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: 'Welcome text',
    );
  }

  String get artistSignupIntroText {
    return Intl.message(
      'Create an account to connect to\nyour awesome superfans. Already have\nan account? ',
      name: 'artistSignupIntroText',
      desc: 'The text at the top of the artist sign up page',
    );
  }

  String get signIn {
    return Intl.message('Sign in', name: 'signIn', desc: 'Sign in');
  }

  String get register {
    return Intl.message('Register', name: 'register', desc: 'Register');
  }

  String get or {
    return Intl.message('or', name: 'or', desc: 'or');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
//    return ['en', 'es', 'pt'].contains(locale.languageCode);
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
