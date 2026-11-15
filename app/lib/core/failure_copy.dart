import 'package:api_client/api_client.dart';

import '../l10n/app_localizations.dart';

/// Maps a typed failure to one plain sentence. Never shows a stack trace,
/// status code, or server wording to a participant.
String failureMessage(AppLocalizations l10n, Object? error) {
  if (error is! ApiException) {
    return l10n.errorUnknown;
  }
  if (error.isNetwork || error.isTimeout) {
    return l10n.errorNetwork;
  }
  switch (error.code) {
    case ProblemCode.rateLimited:
      return l10n.errorRateLimited;
    case ProblemCode.sessionLimitReached:
      return l10n.errorSessionLimit;
    case ProblemCode.turnIndexMismatch:
      return l10n.errorTurnMismatch;
    case ProblemCode.consentRequired:
      return l10n.errorConsent;
    case ProblemCode.invalidToken:
    case ProblemCode.tokenExpired:
      return l10n.errorUnauthorized;
    default:
      break;
  }
  if (error.statusCode == 401) {
    return l10n.errorUnauthorized;
  }
  if (error.statusCode != null && error.statusCode! >= 500) {
    return l10n.errorServer;
  }
  return l10n.errorUnknown;
}
