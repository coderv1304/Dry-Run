import 'package:api_client/api_client.dart';

import '../../l10n/app_localizations.dart';

String stageName(AppLocalizations l10n, StageId stage) {
  switch (stage) {
    case StageId.contact:
      return l10n.stageContact;
    case StageId.accusation:
      return l10n.stageAccusation;
    case StageId.isolation:
      return l10n.stageIsolation;
    case StageId.urgency:
      return l10n.stageUrgency;
    case StageId.transfer:
      return l10n.stageTransfer;
  }
}

String labelName(AppLocalizations l10n, LabelId? label) {
  switch (label) {
    case LabelId.p1:
      return l10n.labelP1;
    case LabelId.p2:
      return l10n.labelP2;
    case LabelId.p3:
      return l10n.labelP3;
    case LabelId.p4:
      return l10n.labelP4;
    case LabelId.c1:
      return l10n.labelC1;
    case LabelId.c2:
      return l10n.labelC2;
    case LabelId.c3:
      return l10n.labelC3;
    case LabelId.c4:
      return l10n.labelC4;
    case null:
      return l10n.labelUnknown;
  }
}

String habitTitle(AppLocalizations l10n, HabitId habit) {
  switch (habit) {
    case HabitId.hangUp:
      return l10n.habitHangUpTitle;
    case HabitId.callBackOfficial:
      return l10n.habitCallBackTitle;
    case HabitId.tellFamily:
      return l10n.habitTellFamilyTitle;
  }
}

String habitBody(AppLocalizations l10n, HabitId habit) {
  switch (habit) {
    case HabitId.hangUp:
      return l10n.habitHangUpBody;
    case HabitId.callBackOfficial:
      return l10n.habitCallBackBody;
    case HabitId.tellFamily:
      return l10n.habitTellFamilyBody;
  }
}

String didWellText(AppLocalizations l10n, String id) {
  switch (id) {
    case 'refused_private_call':
      return l10n.didWellRefusedPrivateCall;
    case 'asked_badge_number':
      return l10n.didWellAskedBadgeNumber;
    case 'recognized_urgency_tactic':
      return l10n.didWellRecognizedUrgencyTactic;
    case 'refused_money_transfer':
      return l10n.didWellRefusedMoneyTransfer;
    case 'tell_family':
      return l10n.didWellToldFamily;
    default:
      return l10n.didWellGeneric;
  }
}

String qualityName(AppLocalizations l10n, DebriefQuality quality) {
  return quality == DebriefQuality.full
      ? l10n.debriefQualityFull
      : l10n.debriefQualityQuick;
}
