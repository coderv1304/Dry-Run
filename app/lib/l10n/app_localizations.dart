import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dry Run'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Practice, not protection'**
  String get appTagline;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice a digital arrest scam call'**
  String get homeTitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'A calm practice drill, not a real call'**
  String get homeTagline;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Learn what a digital arrest scam sounds like. You can stop at any time. This is practice, not protection.'**
  String get homeIntro;

  /// No description provided for @organizerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an invite'**
  String get organizerSectionTitle;

  /// No description provided for @organizerSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a language, then share a plain link with your group.'**
  String get organizerSectionBody;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @languageHinglish.
  ///
  /// In en, this message translates to:
  /// **'Hinglish'**
  String get languageHinglish;

  /// No description provided for @cohortLabel.
  ///
  /// In en, this message translates to:
  /// **'Cohort label (optional)'**
  String get cohortLabel;

  /// No description provided for @cohortHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ward-4'**
  String get cohortHint;

  /// No description provided for @cohortHelper.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers, and hyphens. Up to 24 characters.'**
  String get cohortHelper;

  /// No description provided for @cohortInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers, and hyphens only.'**
  String get cohortInvalid;

  /// No description provided for @createInviteButton.
  ///
  /// In en, this message translates to:
  /// **'Create invite link'**
  String get createInviteButton;

  /// No description provided for @creatingInvite.
  ///
  /// In en, this message translates to:
  /// **'Creating invite'**
  String get creatingInvite;

  /// No description provided for @inviteCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite ready'**
  String get inviteCreatedTitle;

  /// No description provided for @inviteLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get inviteLinkLabel;

  /// No description provided for @inviteLinkHelper.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this link can start a practice drill. It expires on {date}.'**
  String inviteLinkHelper(String date);

  /// No description provided for @shareInviteButton.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareInviteButton;

  /// No description provided for @copyInviteButton.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyInviteButton;

  /// No description provided for @inviteShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Practise spotting a digital arrest scam with Dry Run: {url}'**
  String inviteShareMessage(String url);

  /// No description provided for @openReportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a family report'**
  String get openReportSectionTitle;

  /// No description provided for @openReportSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Paste the report link you received.'**
  String get openReportSectionBody;

  /// No description provided for @reportLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Report link'**
  String get reportLinkLabel;

  /// No description provided for @reportLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a link or report token'**
  String get reportLinkHint;

  /// No description provided for @openReportButton.
  ///
  /// In en, this message translates to:
  /// **'Open report'**
  String get openReportButton;

  /// No description provided for @reportLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'That does not look like a report link.'**
  String get reportLinkInvalid;

  /// No description provided for @tryItYourself.
  ///
  /// In en, this message translates to:
  /// **'Try it yourself'**
  String get tryItYourself;

  /// No description provided for @tryItYourselfBody.
  ///
  /// In en, this message translates to:
  /// **'Start a solo practice call. No invite needed.'**
  String get tryItYourselfBody;

  /// No description provided for @aboutLink.
  ///
  /// In en, this message translates to:
  /// **'About and limits'**
  String get aboutLink;

  /// No description provided for @howItWorksLink.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorksLink;

  /// No description provided for @tryTitle.
  ///
  /// In en, this message translates to:
  /// **'Try it yourself'**
  String get tryTitle;

  /// No description provided for @tryBody.
  ///
  /// In en, this message translates to:
  /// **'Start a solo practice call. Choose a language.'**
  String get tryBody;

  /// No description provided for @tryStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start practice call'**
  String get tryStartButton;

  /// No description provided for @tryStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting practice call'**
  String get tryStarting;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a practice call'**
  String get joinTitle;

  /// No description provided for @joinTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite token'**
  String get joinTokenLabel;

  /// No description provided for @joinTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the token from your invite'**
  String get joinTokenHint;

  /// No description provided for @joinContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get joinContinueButton;

  /// No description provided for @joinValidating.
  ///
  /// In en, this message translates to:
  /// **'Checking invite'**
  String get joinValidating;

  /// No description provided for @joinInvalid.
  ///
  /// In en, this message translates to:
  /// **'This invite is not valid or has expired. Ask for a new link.'**
  String get joinInvalid;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we start'**
  String get consentTitle;

  /// No description provided for @consentPracticeLine1.
  ///
  /// In en, this message translates to:
  /// **'This is a practice call.'**
  String get consentPracticeLine1;

  /// No description provided for @consentPracticeLine2.
  ///
  /// In en, this message translates to:
  /// **'Nothing real is needed. Do not share a real OTP, card number, PIN, or account detail.'**
  String get consentPracticeLine2;

  /// No description provided for @consentPracticeLine3.
  ///
  /// In en, this message translates to:
  /// **'You can stop at any time.'**
  String get consentPracticeLine3;

  /// No description provided for @consentStatsOptInLabel.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous counts'**
  String get consentStatsOptInLabel;

  /// No description provided for @consentStatsOptInHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Only aggregate counts, never your words or personal details.'**
  String get consentStatsOptInHelp;

  /// No description provided for @consentStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start practice call'**
  String get consentStartButton;

  /// No description provided for @consentStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get consentStarting;

  /// No description provided for @consentDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get consentDecline;

  /// No description provided for @consentPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'No account, no payment, no history.'**
  String get consentPrivacyNote;

  /// No description provided for @consentInviteMeta.
  ///
  /// In en, this message translates to:
  /// **'Invite language: {language}'**
  String consentInviteMeta(String language);

  /// No description provided for @drillTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice call'**
  String get drillTitle;

  /// No description provided for @drillBadge.
  ///
  /// In en, this message translates to:
  /// **'DRILL'**
  String get drillBadge;

  /// No description provided for @drillBadgeMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a practice drill. No real agency is involved.'**
  String get drillBadgeMessage;

  /// No description provided for @drillEnd.
  ///
  /// In en, this message translates to:
  /// **'End drill'**
  String get drillEnd;

  /// No description provided for @drillEndConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End this drill?'**
  String get drillEndConfirmTitle;

  /// No description provided for @drillEndConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will go straight to your debrief. You can start again later.'**
  String get drillEndConfirmBody;

  /// No description provided for @drillEndConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'End and see debrief'**
  String get drillEndConfirmButton;

  /// No description provided for @drillEndCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get drillEndCancelButton;

  /// No description provided for @drillWaiting.
  ///
  /// In en, this message translates to:
  /// **'The officer is considering your reply.'**
  String get drillWaiting;

  /// No description provided for @drillWaitingShort.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get drillWaitingShort;

  /// No description provided for @drillYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your reply'**
  String get drillYourTurn;

  /// No description provided for @drillInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type what you would say'**
  String get drillInputHint;

  /// No description provided for @drillSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get drillSend;

  /// No description provided for @drillSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get drillSending;

  /// No description provided for @drillPiiWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not share real OTPs, card numbers, PINs, or account details. This is a practice drill.'**
  String get drillPiiWarning;

  /// No description provided for @drillOfficer.
  ///
  /// In en, this message translates to:
  /// **'Officer'**
  String get drillOfficer;

  /// No description provided for @drillYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get drillYou;

  /// No description provided for @drillSystem.
  ///
  /// In en, this message translates to:
  /// **'Drill'**
  String get drillSystem;

  /// No description provided for @drillTurnCount.
  ///
  /// In en, this message translates to:
  /// **'Turn {current} of {max}'**
  String drillTurnCount(int current, int max);

  /// No description provided for @drillEnded.
  ///
  /// In en, this message translates to:
  /// **'This drill has ended.'**
  String get drillEnded;

  /// No description provided for @drillGoToDebrief.
  ///
  /// In en, this message translates to:
  /// **'See your debrief'**
  String get drillGoToDebrief;

  /// No description provided for @drillSessionGoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Open your link again'**
  String get drillSessionGoneTitle;

  /// No description provided for @drillSessionGoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your session was cleared when the page reloaded. Your invite link is still the way back in.'**
  String get drillSessionGoneBody;

  /// No description provided for @drillSessionGoneTry.
  ///
  /// In en, this message translates to:
  /// **'Try it yourself instead'**
  String get drillSessionGoneTry;

  /// No description provided for @drillErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try sending again'**
  String get drillErrorRetry;

  /// No description provided for @debriefTitle.
  ///
  /// In en, this message translates to:
  /// **'Your debrief'**
  String get debriefTitle;

  /// No description provided for @debriefQuickLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick debrief'**
  String get debriefQuickLabel;

  /// No description provided for @debriefFullLabel.
  ///
  /// In en, this message translates to:
  /// **'Full debrief'**
  String get debriefFullLabel;

  /// No description provided for @debriefRefining.
  ///
  /// In en, this message translates to:
  /// **'Putting together the full debrief. The quick version is ready below.'**
  String get debriefRefining;

  /// No description provided for @debriefRefiningShort.
  ///
  /// In en, this message translates to:
  /// **'Refining'**
  String get debriefRefiningShort;

  /// No description provided for @debriefPending.
  ///
  /// In en, this message translates to:
  /// **'Preparing your debrief'**
  String get debriefPending;

  /// No description provided for @debriefLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'We may have misjudged some moments. Treat this as a guide, not a verdict.'**
  String get debriefLowConfidence;

  /// No description provided for @debriefStatePathTitle.
  ///
  /// In en, this message translates to:
  /// **'How the conversation moved'**
  String get debriefStatePathTitle;

  /// No description provided for @debriefTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Moments that mattered'**
  String get debriefTimelineTitle;

  /// No description provided for @debriefNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No labelled moments were recorded.'**
  String get debriefNoEvents;

  /// No description provided for @debriefFirstComplianceTitle.
  ///
  /// In en, this message translates to:
  /// **'First compliance'**
  String get debriefFirstComplianceTitle;

  /// No description provided for @debriefFirstComplianceBody.
  ///
  /// In en, this message translates to:
  /// **'This was the first moment where a request was followed.'**
  String get debriefFirstComplianceBody;

  /// No description provided for @debriefDidWellTitle.
  ///
  /// In en, this message translates to:
  /// **'What you did well'**
  String get debriefDidWellTitle;

  /// No description provided for @debriefHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'A habit to practise'**
  String get debriefHabitTitle;

  /// No description provided for @debriefConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent} percent'**
  String debriefConfidence(int percent);

  /// No description provided for @debriefQuote.
  ///
  /// In en, this message translates to:
  /// **'You said: {quote}'**
  String debriefQuote(String quote);

  /// No description provided for @debriefQuoteMissing.
  ///
  /// In en, this message translates to:
  /// **'No quote was recorded for this moment.'**
  String get debriefQuoteMissing;

  /// No description provided for @debriefTurnLabel.
  ///
  /// In en, this message translates to:
  /// **'Turn {number}'**
  String debriefTurnLabel(int number);

  /// No description provided for @debriefQualityQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get debriefQualityQuick;

  /// No description provided for @debriefQualityFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get debriefQualityFull;

  /// No description provided for @debriefShareButton.
  ///
  /// In en, this message translates to:
  /// **'Send report to my family'**
  String get debriefShareButton;

  /// No description provided for @debriefShareDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Share this report?'**
  String get debriefShareDialogTitle;

  /// No description provided for @debriefShareDialogBody.
  ///
  /// In en, this message translates to:
  /// **'A link will be created. Anyone with the link can read this debrief until it expires.'**
  String get debriefShareDialogBody;

  /// No description provided for @debriefShareConfirm.
  ///
  /// In en, this message translates to:
  /// **'Create link and share'**
  String get debriefShareConfirm;

  /// No description provided for @debriefShareCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get debriefShareCancel;

  /// No description provided for @debriefSharing.
  ///
  /// In en, this message translates to:
  /// **'Creating link'**
  String get debriefSharing;

  /// No description provided for @debriefShareFailed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be shared. Try again.'**
  String get debriefShareFailed;

  /// No description provided for @debriefDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete my session'**
  String get debriefDeleteButton;

  /// No description provided for @debriefDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get debriefDeleteDialogTitle;

  /// No description provided for @debriefDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the drill, transcript, and debrief. A shared report link stops working. This cannot be undone.'**
  String get debriefDeleteDialogBody;

  /// No description provided for @debriefDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get debriefDeleteConfirm;

  /// No description provided for @debriefDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep session'**
  String get debriefDeleteCancel;

  /// No description provided for @debriefDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get debriefDeleting;

  /// No description provided for @debriefDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get debriefDeletedTitle;

  /// No description provided for @debriefDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'The transcript and debrief are gone. The report link no longer works.'**
  String get debriefDeletedBody;

  /// No description provided for @debriefBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get debriefBackHome;

  /// No description provided for @debriefRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get debriefRetry;

  /// No description provided for @habitHangUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Hang up'**
  String get habitHangUpTitle;

  /// No description provided for @habitHangUpBody.
  ///
  /// In en, this message translates to:
  /// **'End the call, then check the number through an official channel.'**
  String get habitHangUpBody;

  /// No description provided for @habitCallBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Call back on an official number'**
  String get habitCallBackTitle;

  /// No description provided for @habitCallBackBody.
  ///
  /// In en, this message translates to:
  /// **'Use the number on your bank card or the official website, never a number from the caller.'**
  String get habitCallBackBody;

  /// No description provided for @habitTellFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell someone you trust'**
  String get habitTellFamilyTitle;

  /// No description provided for @habitTellFamilyBody.
  ///
  /// In en, this message translates to:
  /// **'Say it out loud to a family member before you do anything.'**
  String get habitTellFamilyBody;

  /// No description provided for @didWellRefusedPrivateCall.
  ///
  /// In en, this message translates to:
  /// **'You did not keep the call private just because you were asked.'**
  String get didWellRefusedPrivateCall;

  /// No description provided for @didWellAskedBadgeNumber.
  ///
  /// In en, this message translates to:
  /// **'You asked for a badge number or identity check.'**
  String get didWellAskedBadgeNumber;

  /// No description provided for @didWellRecognizedUrgencyTactic.
  ///
  /// In en, this message translates to:
  /// **'You noticed the urgency and did not rush.'**
  String get didWellRecognizedUrgencyTactic;

  /// No description provided for @didWellRefusedMoneyTransfer.
  ///
  /// In en, this message translates to:
  /// **'You did not send money.'**
  String get didWellRefusedMoneyTransfer;

  /// No description provided for @didWellToldFamily.
  ///
  /// In en, this message translates to:
  /// **'You involved someone you trust.'**
  String get didWellToldFamily;

  /// No description provided for @didWellGeneric.
  ///
  /// In en, this message translates to:
  /// **'You stayed in the practice and finished the drill.'**
  String get didWellGeneric;

  /// No description provided for @stageContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get stageContact;

  /// No description provided for @stageAccusation.
  ///
  /// In en, this message translates to:
  /// **'Accusation'**
  String get stageAccusation;

  /// No description provided for @stageIsolation.
  ///
  /// In en, this message translates to:
  /// **'Isolation'**
  String get stageIsolation;

  /// No description provided for @stageUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get stageUrgency;

  /// No description provided for @stageTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get stageTransfer;

  /// No description provided for @labelP1.
  ///
  /// In en, this message translates to:
  /// **'Stayed in the call'**
  String get labelP1;

  /// No description provided for @labelP2.
  ///
  /// In en, this message translates to:
  /// **'Asked for identity'**
  String get labelP2;

  /// No description provided for @labelP3.
  ///
  /// In en, this message translates to:
  /// **'Shared a detail'**
  String get labelP3;

  /// No description provided for @labelP4.
  ///
  /// In en, this message translates to:
  /// **'Noticed the pressure'**
  String get labelP4;

  /// No description provided for @labelC1.
  ///
  /// In en, this message translates to:
  /// **'Followed a request'**
  String get labelC1;

  /// No description provided for @labelC2.
  ///
  /// In en, this message translates to:
  /// **'Followed a request'**
  String get labelC2;

  /// No description provided for @labelC3.
  ///
  /// In en, this message translates to:
  /// **'Followed a request'**
  String get labelC3;

  /// No description provided for @labelC4.
  ///
  /// In en, this message translates to:
  /// **'Sent money'**
  String get labelC4;

  /// No description provided for @labelUnknown.
  ///
  /// In en, this message translates to:
  /// **'Moment'**
  String get labelUnknown;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared debrief'**
  String get reportTitle;

  /// No description provided for @reportIntro.
  ///
  /// In en, this message translates to:
  /// **'This debrief was shared by the participant.'**
  String get reportIntro;

  /// No description provided for @reportSharedAt.
  ///
  /// In en, this message translates to:
  /// **'Shared {date}'**
  String reportSharedAt(String date);

  /// No description provided for @reportLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the shared debrief'**
  String get reportLoading;

  /// No description provided for @reportGoneTitle.
  ///
  /// In en, this message translates to:
  /// **'This report is not available'**
  String get reportGoneTitle;

  /// No description provided for @reportGoneBody.
  ///
  /// In en, this message translates to:
  /// **'The participant may have deleted the session, or the link has expired.'**
  String get reportGoneBody;

  /// No description provided for @reportOpenAgain.
  ///
  /// In en, this message translates to:
  /// **'Open the report link again'**
  String get reportOpenAgain;

  /// No description provided for @reportBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get reportBackHome;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About and limits'**
  String get aboutTitle;

  /// No description provided for @aboutWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What Dry Run is'**
  String get aboutWhatTitle;

  /// No description provided for @aboutWhatBody.
  ///
  /// In en, this message translates to:
  /// **'A short practice drill for spotting a digital arrest scam call. The officer is scripted.'**
  String get aboutWhatBody;

  /// No description provided for @aboutNotTitle.
  ///
  /// In en, this message translates to:
  /// **'What it is not'**
  String get aboutNotTitle;

  /// No description provided for @aboutNotBody.
  ///
  /// In en, this message translates to:
  /// **'It is not a real agency, not a test of you, and not protection from fraud.'**
  String get aboutNotBody;

  /// No description provided for @aboutStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'What is stored'**
  String get aboutStorageTitle;

  /// No description provided for @aboutStorageBody.
  ///
  /// In en, this message translates to:
  /// **'The drill transcript and debrief are kept for up to {days} days, then deleted.'**
  String aboutStorageBody(int days);

  /// No description provided for @aboutDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion'**
  String get aboutDeletionTitle;

  /// No description provided for @aboutDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete the session and debrief from the debrief screen at any time.'**
  String get aboutDeletionBody;

  /// No description provided for @aboutAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get aboutAnalyticsTitle;

  /// No description provided for @aboutAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'There is no analytics or advertising tracking. Anonymous counts are optional and off by default.'**
  String get aboutAnalyticsBody;

  /// No description provided for @aboutPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice, not protection'**
  String get aboutPracticeTitle;

  /// No description provided for @aboutPracticeBody.
  ///
  /// In en, this message translates to:
  /// **'This drill cannot stop a real scam. If a real call feels wrong, hang up and use an official number.'**
  String get aboutPracticeBody;

  /// No description provided for @aboutHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get aboutHowItWorksTitle;

  /// No description provided for @aboutHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'The drill follows five scam stages. The officer adapts a little to your replies.'**
  String get aboutHowItWorksBody;

  /// No description provided for @aboutLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session limits'**
  String get aboutLimitsTitle;

  /// No description provided for @aboutLimitsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading limits'**
  String get aboutLimitsLoading;

  /// No description provided for @aboutLimitsFailed.
  ///
  /// In en, this message translates to:
  /// **'Limits could not be loaded.'**
  String get aboutLimitsFailed;

  /// No description provided for @aboutMaxTurns.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} turns'**
  String aboutMaxTurns(int count);

  /// No description provided for @aboutMaxDuration.
  ///
  /// In en, this message translates to:
  /// **'Up to {minutes} minutes'**
  String aboutMaxDuration(int minutes);

  /// No description provided for @aboutIdleTimeout.
  ///
  /// In en, this message translates to:
  /// **'Idle timeout {minutes} minutes'**
  String aboutIdleTimeout(int minutes);

  /// No description provided for @aboutRetention.
  ///
  /// In en, this message translates to:
  /// **'Retention {days} days'**
  String aboutRetention(int days);

  /// No description provided for @aboutChatOnly.
  ///
  /// In en, this message translates to:
  /// **'Chat only. Voice is off in this build.'**
  String get aboutChatOnly;

  /// No description provided for @aboutBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get aboutBackHome;

  /// No description provided for @graphLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the drill map'**
  String get graphLoading;

  /// No description provided for @graphFailed.
  ///
  /// In en, this message translates to:
  /// **'The drill map could not be loaded.'**
  String get graphFailed;

  /// No description provided for @graphStage.
  ///
  /// In en, this message translates to:
  /// **'Stage {number}: {name}'**
  String graphStage(int number, String name);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Try again in a moment.'**
  String get errorServer;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Open your link again.'**
  String get errorUnauthorized;

  /// No description provided for @errorTurnMismatch.
  ///
  /// In en, this message translates to:
  /// **'The conversation went out of sync. Try sending again.'**
  String get errorTurnMismatch;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment, then try again.'**
  String get errorRateLimited;

  /// No description provided for @errorSessionLimit.
  ///
  /// In en, this message translates to:
  /// **'This invite has reached its session limit.'**
  String get errorSessionLimit;

  /// No description provided for @errorConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent is needed before starting.'**
  String get errorConsent;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected problem occurred.'**
  String get errorUnknown;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @shareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing is not available here. The link was copied instead.'**
  String get shareUnavailable;

  /// No description provided for @shareReportMessage.
  ///
  /// In en, this message translates to:
  /// **'Dry Run practice debrief: {url}'**
  String shareReportMessage(String url);

  /// No description provided for @reportShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Dry Run practice debrief'**
  String get reportShareSubject;

  /// No description provided for @a11ySend.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get a11ySend;

  /// No description provided for @a11yEnd.
  ///
  /// In en, this message translates to:
  /// **'End practice drill'**
  String get a11yEnd;

  /// No description provided for @a11yShare.
  ///
  /// In en, this message translates to:
  /// **'Share the report'**
  String get a11yShare;

  /// No description provided for @a11yDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete the session'**
  String get a11yDelete;

  /// No description provided for @a11yBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get a11yBack;

  /// No description provided for @a11yDrillBadge.
  ///
  /// In en, this message translates to:
  /// **'Practice drill badge'**
  String get a11yDrillBadge;

  /// No description provided for @a11yLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get a11yLoading;

  /// No description provided for @a11yInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get a11yInviteLink;

  /// No description provided for @a11yReportLink.
  ///
  /// In en, this message translates to:
  /// **'Report link'**
  String get a11yReportLink;

  /// No description provided for @a11yLanguageSelector.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get a11yLanguageSelector;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
