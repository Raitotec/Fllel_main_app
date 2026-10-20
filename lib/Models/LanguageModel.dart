import 'package:flutter/material.dart';

import '../Localization/Translations.dart';

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList(BuildContext context) {
    return <Language>[
     // Language(1, "🇺🇸", "English", "en"),
     // Language(2, "🇸🇦", "اَلْعَرَبِيَّةُ‎", "ar"),
      Language(0,Translations.of(context)!.Language_flag, Translations.of(context)!.language, ""),
    ];
  }
}
