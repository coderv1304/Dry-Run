import 'package:api_client/api_client.dart';

import '../../l10n/app_localizations.dart';

String languageName(AppLocalizations l10n, AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return l10n.languageEnglish;
    case AppLanguage.hi:
      return l10n.languageHindi;
    case AppLanguage.hinglish:
      return l10n.languageHinglish;
  }
}
