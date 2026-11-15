// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dry Run';

  @override
  String get appTagline => 'Practice, not protection';

  @override
  String get homeTitle => 'Practice a digital arrest scam call';

  @override
  String get homeTagline => 'A calm practice drill, not a real call';

  @override
  String get homeIntro =>
      'Learn what a digital arrest scam sounds like. You can stop at any time. This is practice, not protection.';

  @override
  String get organizerSectionTitle => 'Create an invite';

  @override
  String get organizerSectionBody =>
      'Choose a language, then share a plain link with your group.';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageHinglish => 'Hinglish';

  @override
  String get cohortLabel => 'Cohort label (optional)';

  @override
  String get cohortHint => 'e.g. ward-4';

  @override
  String get cohortHelper =>
      'Lowercase letters, numbers, and hyphens. Up to 24 characters.';

  @override
  String get cohortInvalid =>
      'Use lowercase letters, numbers, and hyphens only.';

  @override
  String get createInviteButton => 'Create invite link';

  @override
  String get creatingInvite => 'Creating invite';

  @override
  String get inviteCreatedTitle => 'Invite ready';

  @override
  String get inviteLinkLabel => 'Invite link';

  @override
  String inviteLinkHelper(String date) {
    return 'Anyone with this link can start a practice drill. It expires on $date.';
  }

  @override
  String get shareInviteButton => 'Share link';

  @override
  String get copyInviteButton => 'Copy link';

  @override
  String inviteShareMessage(String url) {
    return 'Practise spotting a digital arrest scam with Dry Run: $url';
  }

  @override
  String get openReportSectionTitle => 'Open a family report';

  @override
  String get openReportSectionBody => 'Paste the report link you received.';

  @override
  String get reportLinkLabel => 'Report link';

  @override
  String get reportLinkHint => 'Paste a link or report token';

  @override
  String get openReportButton => 'Open report';

  @override
  String get reportLinkInvalid => 'That does not look like a report link.';

  @override
  String get tryItYourself => 'Try it yourself';

  @override
  String get tryItYourselfBody =>
      'Start a solo practice call. No invite needed.';

  @override
  String get aboutLink => 'About and limits';

  @override
  String get howItWorksLink => 'How it works';

  @override
  String get tryTitle => 'Try it yourself';

  @override
  String get tryBody => 'Start a solo practice call. Choose a language.';

  @override
  String get tryStartButton => 'Start practice call';

  @override
  String get tryStarting => 'Starting practice call';

  @override
  String get joinTitle => 'Join a practice call';

  @override
  String get joinTokenLabel => 'Invite token';

  @override
  String get joinTokenHint => 'Paste the token from your invite';

  @override
  String get joinContinueButton => 'Continue';

  @override
  String get joinValidating => 'Checking invite';

  @override
  String get joinInvalid =>
      'This invite is not valid or has expired. Ask for a new link.';

  @override
  String get consentTitle => 'Before we start';

  @override
  String get consentPracticeLine1 => 'This is a practice call.';

  @override
  String get consentPracticeLine2 =>
      'Nothing real is needed. Do not share a real OTP, card number, PIN, or account detail.';

  @override
  String get consentPracticeLine3 => 'You can stop at any time.';

  @override
  String get consentStatsOptInLabel => 'Share anonymous counts';

  @override
  String get consentStatsOptInHelp =>
      'Optional. Only aggregate counts, never your words or personal details.';

  @override
  String get consentStartButton => 'Start practice call';

  @override
  String get consentStarting => 'Starting';

  @override
  String get consentDecline => 'Not now';

  @override
  String get consentPrivacyNote => 'No account, no payment, no history.';

  @override
  String consentInviteMeta(String language) {
    return 'Invite language: $language';
  }

  @override
  String get drillTitle => 'Practice call';

  @override
  String get drillBadge => 'DRILL';

  @override
  String get drillBadgeMessage =>
      'This is a practice drill. No real agency is involved.';

  @override
  String get drillEnd => 'End drill';

  @override
  String get drillEndConfirmTitle => 'End this drill?';

  @override
  String get drillEndConfirmBody =>
      'You will go straight to your debrief. You can start again later.';

  @override
  String get drillEndConfirmButton => 'End and see debrief';

  @override
  String get drillEndCancelButton => 'Keep going';

  @override
  String get drillWaiting => 'The officer is considering your reply.';

  @override
  String get drillWaitingShort => 'Waiting';

  @override
  String get drillYourTurn => 'Your reply';

  @override
  String get drillInputHint => 'Type what you would say';

  @override
  String get drillSend => 'Send';

  @override
  String get drillSending => 'Sending';

  @override
  String get drillPiiWarning =>
      'Do not share real OTPs, card numbers, PINs, or account details. This is a practice drill.';

  @override
  String get drillOfficer => 'Officer';

  @override
  String get drillYou => 'You';

  @override
  String get drillSystem => 'Drill';

  @override
  String drillTurnCount(int current, int max) {
    return 'Turn $current of $max';
  }

  @override
  String get drillEnded => 'This drill has ended.';

  @override
  String get drillGoToDebrief => 'See your debrief';

  @override
  String get drillSessionGoneTitle => 'Open your link again';

  @override
  String get drillSessionGoneBody =>
      'Your session was cleared when the page reloaded. Your invite link is still the way back in.';

  @override
  String get drillSessionGoneTry => 'Try it yourself instead';

  @override
  String get drillErrorRetry => 'Try sending again';

  @override
  String get debriefTitle => 'Your debrief';

  @override
  String get debriefQuickLabel => 'Quick debrief';

  @override
  String get debriefFullLabel => 'Full debrief';

  @override
  String get debriefRefining =>
      'Putting together the full debrief. The quick version is ready below.';

  @override
  String get debriefRefiningShort => 'Refining';

  @override
  String get debriefPending => 'Preparing your debrief';

  @override
  String get debriefLowConfidence =>
      'We may have misjudged some moments. Treat this as a guide, not a verdict.';

  @override
  String get debriefStatePathTitle => 'How the conversation moved';

  @override
  String get debriefTimelineTitle => 'Moments that mattered';

  @override
  String get debriefNoEvents => 'No labelled moments were recorded.';

  @override
  String get debriefFirstComplianceTitle => 'First compliance';

  @override
  String get debriefFirstComplianceBody =>
      'This was the first moment where a request was followed.';

  @override
  String get debriefDidWellTitle => 'What you did well';

  @override
  String get debriefHabitTitle => 'A habit to practise';

  @override
  String debriefConfidence(int percent) {
    return 'Confidence $percent percent';
  }

  @override
  String debriefQuote(String quote) {
    return 'You said: $quote';
  }

  @override
  String get debriefQuoteMissing => 'No quote was recorded for this moment.';

  @override
  String debriefTurnLabel(int number) {
    return 'Turn $number';
  }

  @override
  String get debriefQualityQuick => 'Quick';

  @override
  String get debriefQualityFull => 'Full';

  @override
  String get debriefShareButton => 'Send report to my family';

  @override
  String get debriefShareDialogTitle => 'Share this report?';

  @override
  String get debriefShareDialogBody =>
      'A link will be created. Anyone with the link can read this debrief until it expires.';

  @override
  String get debriefShareConfirm => 'Create link and share';

  @override
  String get debriefShareCancel => 'Cancel';

  @override
  String get debriefSharing => 'Creating link';

  @override
  String get debriefShareFailed => 'The report could not be shared. Try again.';

  @override
  String get debriefDeleteButton => 'Delete my session';

  @override
  String get debriefDeleteDialogTitle => 'Delete this session?';

  @override
  String get debriefDeleteDialogBody =>
      'This permanently deletes the drill, transcript, and debrief. A shared report link stops working. This cannot be undone.';

  @override
  String get debriefDeleteConfirm => 'Delete session';

  @override
  String get debriefDeleteCancel => 'Keep session';

  @override
  String get debriefDeleting => 'Deleting';

  @override
  String get debriefDeletedTitle => 'Session deleted';

  @override
  String get debriefDeletedBody =>
      'The transcript and debrief are gone. The report link no longer works.';

  @override
  String get debriefBackHome => 'Back to start';

  @override
  String get debriefRetry => 'Try again';

  @override
  String get habitHangUpTitle => 'Hang up';

  @override
  String get habitHangUpBody =>
      'End the call, then check the number through an official channel.';

  @override
  String get habitCallBackTitle => 'Call back on an official number';

  @override
  String get habitCallBackBody =>
      'Use the number on your bank card or the official website, never a number from the caller.';

  @override
  String get habitTellFamilyTitle => 'Tell someone you trust';

  @override
  String get habitTellFamilyBody =>
      'Say it out loud to a family member before you do anything.';

  @override
  String get didWellRefusedPrivateCall =>
      'You did not keep the call private just because you were asked.';

  @override
  String get didWellAskedBadgeNumber =>
      'You asked for a badge number or identity check.';

  @override
  String get didWellRecognizedUrgencyTactic =>
      'You noticed the urgency and did not rush.';

  @override
  String get didWellRefusedMoneyTransfer => 'You did not send money.';

  @override
  String get didWellToldFamily => 'You involved someone you trust.';

  @override
  String get didWellGeneric =>
      'You stayed in the practice and finished the drill.';

  @override
  String get stageContact => 'Contact';

  @override
  String get stageAccusation => 'Accusation';

  @override
  String get stageIsolation => 'Isolation';

  @override
  String get stageUrgency => 'Urgency';

  @override
  String get stageTransfer => 'Transfer';

  @override
  String get labelP1 => 'Stayed in the call';

  @override
  String get labelP2 => 'Asked for identity';

  @override
  String get labelP3 => 'Shared a detail';

  @override
  String get labelP4 => 'Noticed the pressure';

  @override
  String get labelC1 => 'Followed a request';

  @override
  String get labelC2 => 'Followed a request';

  @override
  String get labelC3 => 'Followed a request';

  @override
  String get labelC4 => 'Sent money';

  @override
  String get labelUnknown => 'Moment';

  @override
  String get reportTitle => 'Shared debrief';

  @override
  String get reportIntro => 'This debrief was shared by the participant.';

  @override
  String reportSharedAt(String date) {
    return 'Shared $date';
  }

  @override
  String get reportLoading => 'Loading the shared debrief';

  @override
  String get reportGoneTitle => 'This report is not available';

  @override
  String get reportGoneBody =>
      'The participant may have deleted the session, or the link has expired.';

  @override
  String get reportOpenAgain => 'Open the report link again';

  @override
  String get reportBackHome => 'Back to start';

  @override
  String get aboutTitle => 'About and limits';

  @override
  String get aboutWhatTitle => 'What Dry Run is';

  @override
  String get aboutWhatBody =>
      'A short practice drill for spotting a digital arrest scam call. The officer is scripted.';

  @override
  String get aboutNotTitle => 'What it is not';

  @override
  String get aboutNotBody =>
      'It is not a real agency, not a test of you, and not protection from fraud.';

  @override
  String get aboutStorageTitle => 'What is stored';

  @override
  String aboutStorageBody(int days) {
    return 'The drill transcript and debrief are kept for up to $days days, then deleted.';
  }

  @override
  String get aboutDeletionTitle => 'Deletion';

  @override
  String get aboutDeletionBody =>
      'You can delete the session and debrief from the debrief screen at any time.';

  @override
  String get aboutAnalyticsTitle => 'No tracking';

  @override
  String get aboutAnalyticsBody =>
      'There is no analytics or advertising tracking. Anonymous counts are optional and off by default.';

  @override
  String get aboutPracticeTitle => 'Practice, not protection';

  @override
  String get aboutPracticeBody =>
      'This drill cannot stop a real scam. If a real call feels wrong, hang up and use an official number.';

  @override
  String get aboutHowItWorksTitle => 'How it works';

  @override
  String get aboutHowItWorksBody =>
      'The drill follows five scam stages. The officer adapts a little to your replies.';

  @override
  String get aboutLimitsTitle => 'Session limits';

  @override
  String get aboutLimitsLoading => 'Loading limits';

  @override
  String get aboutLimitsFailed => 'Limits could not be loaded.';

  @override
  String aboutMaxTurns(int count) {
    return 'Up to $count turns';
  }

  @override
  String aboutMaxDuration(int minutes) {
    return 'Up to $minutes minutes';
  }

  @override
  String aboutIdleTimeout(int minutes) {
    return 'Idle timeout $minutes minutes';
  }

  @override
  String aboutRetention(int days) {
    return 'Retention $days days';
  }

  @override
  String get aboutChatOnly => 'Chat only. Voice is off in this build.';

  @override
  String get aboutBackHome => 'Back to start';

  @override
  String get graphLoading => 'Loading the drill map';

  @override
  String get graphFailed => 'The drill map could not be loaded.';

  @override
  String graphStage(int number, String name) {
    return 'Stage $number: $name';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorNetwork => 'Check your connection and try again.';

  @override
  String get errorServer => 'The server had a problem. Try again in a moment.';

  @override
  String get errorUnauthorized =>
      'Your session has ended. Open your link again.';

  @override
  String get errorTurnMismatch =>
      'The conversation went out of sync. Try sending again.';

  @override
  String get errorRateLimited =>
      'Too many requests. Wait a moment, then try again.';

  @override
  String get errorSessionLimit => 'This invite has reached its session limit.';

  @override
  String get errorConsent => 'Consent is needed before starting.';

  @override
  String get errorUnknown => 'An unexpected problem occurred.';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get shareUnavailable =>
      'Sharing is not available here. The link was copied instead.';

  @override
  String shareReportMessage(String url) {
    return 'Dry Run practice debrief: $url';
  }

  @override
  String get reportShareSubject => 'Dry Run practice debrief';

  @override
  String get a11ySend => 'Send reply';

  @override
  String get a11yEnd => 'End practice drill';

  @override
  String get a11yShare => 'Share the report';

  @override
  String get a11yDelete => 'Delete the session';

  @override
  String get a11yBack => 'Go back';

  @override
  String get a11yDrillBadge => 'Practice drill badge';

  @override
  String get a11yLoading => 'Loading';

  @override
  String get a11yInviteLink => 'Invite link';

  @override
  String get a11yReportLink => 'Report link';

  @override
  String get a11yLanguageSelector => 'Choose a language';
}
