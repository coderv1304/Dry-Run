// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Dry Run';

  @override
  String get appTagline => 'अभ्यास, सुरक्षा नहीं';

  @override
  String get homeTitle => 'डिजिटल अरेस्ट ठगी की कॉल का अभ्यास करें';

  @override
  String get homeTagline => 'एक शांत अभ्यास ड्रिल, असली कॉल नहीं';

  @override
  String get homeIntro =>
      'जानिए डिजिटल अरेस्ट ठगी की कॉल कैसी लगती है। आप कभी भी रुक सकते हैं। यह अभ्यास है, सुरक्षा नहीं।';

  @override
  String get organizerSectionTitle => 'निमंत्रण बनाएं';

  @override
  String get organizerSectionBody =>
      'भाषा चुनें, फिर अपने समूह के साथ सादा लिंक साझा करें।';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageHinglish => 'Hinglish';

  @override
  String get cohortLabel => 'समूह लेबल (वैकल्पिक)';

  @override
  String get cohortHint => 'जैसे ward-4';

  @override
  String get cohortHelper => 'छोटे अक्षर, अंक और हाइफ़न। अधिकतम 24 अक्षर।';

  @override
  String get cohortInvalid => 'केवल छोटे अक्षर, अंक और हाइफ़न इस्तेमाल करें।';

  @override
  String get createInviteButton => 'निमंत्रण लिंक बनाएं';

  @override
  String get creatingInvite => 'निमंत्रण बन रहा है';

  @override
  String get inviteCreatedTitle => 'निमंत्रण तैयार है';

  @override
  String get inviteLinkLabel => 'निमंत्रण लिंक';

  @override
  String inviteLinkHelper(String date) {
    return 'इस लिंक से कोई भी अभ्यास ड्रिल शुरू कर सकता है। यह $date को समाप्त होगा।';
  }

  @override
  String get shareInviteButton => 'लिंक साझा करें';

  @override
  String get copyInviteButton => 'लिंक कॉपी करें';

  @override
  String inviteShareMessage(String url) {
    return 'Dry Run के साथ डिजिटल अरेस्ट ठगी पहचानने का अभ्यास करें: $url';
  }

  @override
  String get openReportSectionTitle => 'परिवार की रिपोर्ट खोलें';

  @override
  String get openReportSectionBody => 'आपको मिला रिपोर्ट लिंक पेस्ट करें।';

  @override
  String get reportLinkLabel => 'रिपोर्ट लिंक';

  @override
  String get reportLinkHint => 'लिंक या रिपोर्ट टोकन पेस्ट करें';

  @override
  String get openReportButton => 'रिपोर्ट खोलें';

  @override
  String get reportLinkInvalid => 'यह रिपोर्ट लिंक जैसा नहीं दिखता।';

  @override
  String get tryItYourself => 'स्वयं आज़माएं';

  @override
  String get tryItYourselfBody =>
      'अकेले अभ्यास कॉल शुरू करें। निमंत्रण की ज़रूरत नहीं।';

  @override
  String get aboutLink => 'परिचय और सीमाएं';

  @override
  String get howItWorksLink => 'यह कैसे काम करता है';

  @override
  String get tryTitle => 'स्वयं आज़माएं';

  @override
  String get tryBody => 'अकेले अभ्यास कॉल शुरू करें। भाषा चुनें।';

  @override
  String get tryStartButton => 'अभ्यास कॉल शुरू करें';

  @override
  String get tryStarting => 'अभ्यास कॉल शुरू हो रही है';

  @override
  String get joinTitle => 'अभ्यास कॉल में शामिल हों';

  @override
  String get joinTokenLabel => 'निमंत्रण टोकन';

  @override
  String get joinTokenHint => 'अपने निमंत्रण से टोकन पेस्ट करें';

  @override
  String get joinContinueButton => 'आगे बढ़ें';

  @override
  String get joinValidating => 'निमंत्रण जांचा जा रहा है';

  @override
  String get joinInvalid =>
      'यह निमंत्रण मान्य नहीं है या समाप्त हो गया है। नया लिंक मांगें।';

  @override
  String get consentTitle => 'शुरू करने से पहले';

  @override
  String get consentPracticeLine1 => 'यह एक अभ्यास कॉल है।';

  @override
  String get consentPracticeLine2 =>
      'असली कुछ भी देने की ज़रूरत नहीं। असली ओटीपी, कार्ड नंबर, पिन या खाते की जानकारी साझा न करें।';

  @override
  String get consentPracticeLine3 => 'आप कभी भी रुक सकते हैं।';

  @override
  String get consentStatsOptInLabel => 'गिनती साझा करें';

  @override
  String get consentStatsOptInHelp =>
      'वैकल्पिक। केवल कुल गिनती, कभी आपके शब्द या निजी जानकारी नहीं।';

  @override
  String get consentStartButton => 'अभ्यास कॉल शुरू करें';

  @override
  String get consentStarting => 'शुरू हो रहा है';

  @override
  String get consentDecline => 'अभी नहीं';

  @override
  String get consentPrivacyNote =>
      'कोई खाता नहीं, कोई भुगतान नहीं, कोई इतिहास नहीं।';

  @override
  String consentInviteMeta(String language) {
    return 'निमंत्रण की भाषा: $language';
  }

  @override
  String get drillTitle => 'अभ्यास कॉल';

  @override
  String get drillBadge => 'ड्रिल';

  @override
  String get drillBadgeMessage =>
      'यह एक अभ्यास ड्रिल है। इसमें कोई असली एजेंसी शामिल नहीं है।';

  @override
  String get drillEnd => 'ड्रिल समाप्त करें';

  @override
  String get drillEndConfirmTitle => 'यह ड्रिल समाप्त करें?';

  @override
  String get drillEndConfirmBody =>
      'आप सीधे अपनी समीक्षा पर जाएंगे। बाद में फिर शुरू कर सकते हैं।';

  @override
  String get drillEndConfirmButton => 'समाप्त करें और समीक्षा देखें';

  @override
  String get drillEndCancelButton => 'जारी रखें';

  @override
  String get drillWaiting => 'अधिकारी आपके जवाब पर विचार कर रहे हैं।';

  @override
  String get drillWaitingShort => 'प्रतीक्षा';

  @override
  String get drillYourTurn => 'आपका जवाब';

  @override
  String get drillInputHint => 'जो कहना हो, लिखें';

  @override
  String get drillSend => 'भेजें';

  @override
  String get drillSending => 'भेजा जा रहा है';

  @override
  String get drillPiiWarning =>
      'असली ओटीपी, कार्ड नंबर, पिन या खाते की जानकारी साझा न करें। यह अभ्यास ड्रिल है।';

  @override
  String get drillOfficer => 'अधिकारी';

  @override
  String get drillYou => 'आप';

  @override
  String get drillSystem => 'ड्रिल';

  @override
  String drillTurnCount(int current, int max) {
    return 'बारी $current / $max';
  }

  @override
  String get drillEnded => 'यह ड्रिल समाप्त हो गई है।';

  @override
  String get drillGoToDebrief => 'अपनी समीक्षा देखें';

  @override
  String get drillSessionGoneTitle => 'अपना लिंक फिर खोलें';

  @override
  String get drillSessionGoneBody =>
      'पेज दोबारा खुलने पर आपका सत्र मिट गया। आपका निमंत्रण लिंक ही वापस जाने का रास्ता है।';

  @override
  String get drillSessionGoneTry => 'इसके बजाय स्वयं आज़माएं';

  @override
  String get drillErrorRetry => 'फिर भेजने की कोशिश करें';

  @override
  String get voiceUse => 'आवाज़ का इस्तेमाल करें';

  @override
  String get voiceBadge => 'आवाज़';

  @override
  String get voiceHelper => 'वैकल्पिक। चैट हमेशा उपलब्ध रहती है।';

  @override
  String get voiceCheckLink => 'आवाज़ की जाँच';

  @override
  String get voiceDisclosureTitle =>
      'इस अभ्यास कॉल में आवाज़ का इस्तेमाल करें?';

  @override
  String get voiceDisclosureBody =>
      'आपके फ़ोन की वाक् सेवा आपकी आवाज़ को पाठ में बदलती है। यह ऑडियो अपने प्रदाता को भेज सकती है। ड्राई रन ऑडियो संग्रहित नहीं करता। पाठ चैट हमेशा काम करती है और आप किसी भी समय ड्रिल समाप्त कर सकते हैं।';

  @override
  String get voiceDisclosureConfirm => 'आवाज़ चालू करें';

  @override
  String get voiceDisclosureCancel => 'चैट जारी रखें';

  @override
  String get voiceDisclosureTest => 'पहले फ़ोन जाँचें';

  @override
  String get voiceReady => 'आवाज़ चालू है। बोलने के लिए दबाएँ।';

  @override
  String get voiceSpeak => 'अपना जवाब बोलें';

  @override
  String get voiceStop => 'सुनना बंद करें';

  @override
  String get voiceListening => 'सुन रहे हैं। अब बोलें।';

  @override
  String get voiceThinking => 'अधिकारी की प्रतीक्षा है।';

  @override
  String get voiceSpeaking => 'अधिकारी बोल रहे हैं।';

  @override
  String get voiceTurnOff => 'आवाज़ बंद करें';

  @override
  String get voiceFiller => 'एक क्षण।';

  @override
  String get voiceProblemPermission =>
      'माइक्रोफ़ोन की अनुमति बंद है। आप लिखते रह सकते हैं।';

  @override
  String get voiceProblemRecognizer =>
      'इस फ़ोन पर वाक् पहचान उपलब्ध नहीं है। आप लिखते रह सकते हैं।';

  @override
  String get voiceProblemLanguage =>
      'इस फ़ोन पर हिंदी वाक् पहचान नहीं है। आप लिखते रह सकते हैं।';

  @override
  String get voiceProblemTts =>
      'इस भाषा के लिए फ़ोन की आवाज़ उपलब्ध नहीं है। आप लिखते रह सकते हैं।';

  @override
  String get voiceProblemListen =>
      'मैं समझ नहीं पाया। फिर कोशिश करें या जवाब लिखें।';

  @override
  String get voiceProblemReply =>
      'जवाब नहीं आया। लिखते रहें या आवाज़ फिर आज़माएँ।';

  @override
  String get voiceProblemTimeout =>
      'आवाज़ में बहुत समय लगा। लिखते रहें या आवाज़ फिर आज़माएँ।';

  @override
  String get voiceProblemSpeech => 'आवाज़ रुक गई। आपकी चैट अभी भी काम करती है।';

  @override
  String get voiceProblemUnavailable =>
      'इस फ़ोन पर आवाज़ तैयार नहीं है। आप लिखते रह सकते हैं।';

  @override
  String get voiceRetry => 'आवाज़ फिर आज़माएँ';

  @override
  String get voiceKeepTyping => 'लिखते रहें';

  @override
  String voiceRoundTrip(int ms) {
    return 'जवाब में $ms मि.से. लगे';
  }

  @override
  String get voiceOverBudget =>
      'इस जवाब में 2 सेकंड की सीमा से अधिक समय लगा। चैट अभी भी उपलब्ध है।';

  @override
  String get voiceCheckTitle => 'आवाज़ की जाँच';

  @override
  String get voiceCheckIntro =>
      'माइक्रोफ़ोन, अंग्रेज़ी और हिंदी की पहचान, और फ़ोन की आवाज़ जाँचें। ऑडियो संग्रहित नहीं होता।';

  @override
  String get voiceCheckStart => 'आवाज़ की जाँच शुरू करें';

  @override
  String get voiceCheckMicrophone => 'माइक्रोफ़ोन';

  @override
  String get voiceCheckMicrophoneOn => 'माइक्रोफ़ोन की अनुमति चालू है।';

  @override
  String get voiceCheckMicrophoneOff =>
      'माइक्रोफ़ोन की अनुमति बंद है। फ़ोन की सेटिंग में अनुमति दें।';

  @override
  String get voiceCheckRecognition => 'वाक् पहचान';

  @override
  String voiceCheckLanguageTest(String language) {
    return '$language पहचान जाँचें';
  }

  @override
  String voiceCheckHeard(String text) {
    return 'सुना: $text';
  }

  @override
  String get voiceCheckNothingHeard => 'कुछ सुनाई नहीं दिया। फिर कोशिश करें।';

  @override
  String get voiceCheckTts => 'फ़ोन की आवाज़';

  @override
  String voiceCheckTtsTest(String language) {
    return '$language आवाज़ जाँचें';
  }

  @override
  String voiceCheckTtsOn(String language) {
    return 'फ़ोन $language बोल सकता है।';
  }

  @override
  String voiceCheckTtsOff(String language) {
    return 'फ़ोन $language नहीं बोल सकता।';
  }

  @override
  String get voiceCheckRoundTrip => 'पूरा चक्र';

  @override
  String get voiceCheckRoundTripTest => 'पूरे चक्र की जाँच करें';

  @override
  String voiceCheckRoundTripResult(int ms) {
    return 'पूरे चक्र में $ms मि.से.';
  }

  @override
  String voiceCheckRoundTripSlow(int ms) {
    return 'पूरे चक्र में $ms मि.से. लगे। यह 2 सेकंड की सीमा से अधिक है।';
  }

  @override
  String get voiceCheckPass => 'इस फ़ोन पर आवाज़ तैयार है।';

  @override
  String get voiceCheckFail => 'इस फ़ोन पर आवाज़ चैट में ही रहेगी।';

  @override
  String get voiceCheckBadge => 'जाँच';

  @override
  String get voiceCheckPending => 'अभी जाँच नहीं हुई';

  @override
  String get voiceCheckTesting => 'जाँच हो रही है';

  @override
  String get voiceCheckPassShort => 'सफल';

  @override
  String get voiceCheckFailShort => 'असफल';

  @override
  String get voiceCheckNote =>
      'ऑडियो आपके फ़ोन की वाक् सेवा संभालती है और उसे अपने प्रदाता को भेज सकती है। ड्राई रन उसे संग्रहित नहीं करता।';

  @override
  String get voiceCheckBack => 'ड्रिल पर वापस जाएँ';

  @override
  String get demoBadge => 'डेमो';

  @override
  String get demoBanner => 'रिकॉर्डेड वॉकथ्रू। कोई नेटवर्क इस्तेमाल नहीं होता।';

  @override
  String get debriefTitle => 'आपकी समीक्षा';

  @override
  String get debriefQuickLabel => 'छोटी समीक्षा';

  @override
  String get debriefFullLabel => 'पूरी समीक्षा';

  @override
  String get debriefRefining =>
      'पूरी समीक्षा तैयार हो रही है। छोटी समीक्षा नीचे तैयार है।';

  @override
  String get debriefRefiningShort => 'तैयार हो रही है';

  @override
  String get debriefPending => 'आपकी समीक्षा तैयार की जा रही है';

  @override
  String get debriefLowConfidence =>
      'हो सकता है कुछ पलों को हमने गलत समझा हो। इसे मार्गदर्शन मानें, फैसला नहीं।';

  @override
  String get debriefStatePathTitle => 'बातचीत कैसे आगे बढ़ी';

  @override
  String get debriefTimelineTitle => 'अहम पल';

  @override
  String get debriefNoEvents => 'कोई चिह्नित पल दर्ज नहीं हुआ।';

  @override
  String get debriefFirstComplianceTitle => 'पहला पालन';

  @override
  String get debriefFirstComplianceBody =>
      'यह पहला मौका था जब किसी मांग का पालन हुआ।';

  @override
  String get debriefDidWellTitle => 'आपने क्या अच्छा किया';

  @override
  String get debriefHabitTitle => 'अभ्यास करने योग्य आदत';

  @override
  String debriefConfidence(int percent) {
    return 'भरोसा $percent प्रतिशत';
  }

  @override
  String debriefQuote(String quote) {
    return 'आपने कहा: $quote';
  }

  @override
  String get debriefQuoteMissing => 'इस पल के लिए कोई उद्धरण दर्ज नहीं हुआ।';

  @override
  String debriefTurnLabel(int number) {
    return 'बारी $number';
  }

  @override
  String get debriefQualityQuick => 'छोटी';

  @override
  String get debriefQualityFull => 'पूरी';

  @override
  String get debriefShareButton => 'अपने परिवार को रिपोर्ट भेजें';

  @override
  String get debriefShareDialogTitle => 'यह रिपोर्ट साझा करें?';

  @override
  String get debriefShareDialogBody =>
      'एक लिंक बनेगा। लिंक वाला कोई भी व्यक्ति समाप्ति तक यह समीक्षा पढ़ सकता है।';

  @override
  String get debriefShareConfirm => 'लिंक बनाएं और साझा करें';

  @override
  String get debriefShareCancel => 'रद्द करें';

  @override
  String get debriefSharing => 'लिंक बन रहा है';

  @override
  String get debriefShareFailed => 'रिपोर्ट साझा नहीं हो सकी। फिर कोशिश करें।';

  @override
  String get debriefDeleteButton => 'मेरा सत्र मिटाएं';

  @override
  String get debriefDeleteDialogTitle => 'यह सत्र मिटाएं?';

  @override
  String get debriefDeleteDialogBody =>
      'इससे ड्रिल, बातचीत और समीक्षा हमेशा के लिए मिट जाएंगी। साझा किया गया रिपोर्ट लिंक काम करना बंद कर देगा। इसे वापस नहीं लाया जा सकता।';

  @override
  String get debriefDeleteConfirm => 'सत्र मिटाएं';

  @override
  String get debriefDeleteCancel => 'सत्र रखें';

  @override
  String get debriefDeleting => 'मिटाया जा रहा है';

  @override
  String get debriefDeletedTitle => 'सत्र मिट गया';

  @override
  String get debriefDeletedBody =>
      'बातचीत और समीक्षा चली गई। रिपोर्ट लिंक अब काम नहीं करता।';

  @override
  String get debriefBackHome => 'शुरुआत पर वापस';

  @override
  String get debriefRetry => 'फिर कोशिश करें';

  @override
  String get habitHangUpTitle => 'कॉल काटें';

  @override
  String get habitHangUpBody =>
      'कॉल समाप्त करें, फिर आधिकारिक माध्यम से नंबर जांचें।';

  @override
  String get habitCallBackTitle => 'आधिकारिक नंबर पर वापस कॉल करें';

  @override
  String get habitCallBackBody =>
      'अपने बैंक कार्ड या आधिकारिक वेबसाइट पर दिया नंबर इस्तेमाल करें, कॉल करने वाले का नंबर कभी नहीं।';

  @override
  String get habitTellFamilyTitle => 'किसी भरोसेमंद को बताएं';

  @override
  String get habitTellFamilyBody =>
      'कुछ भी करने से पहले परिवार के किसी सदस्य से ज़ोर से कहें।';

  @override
  String get didWellRefusedPrivateCall =>
      'आपने सिर्फ कहने पर कॉल को गुप्त नहीं रखा।';

  @override
  String get didWellAskedBadgeNumber => 'आपने बैज नंबर या पहचान की जांच मांगी।';

  @override
  String get didWellRecognizedUrgencyTactic =>
      'आपने जल्दबाज़ी को पहचाना और जल्दी नहीं की।';

  @override
  String get didWellRefusedMoneyTransfer => 'आपने पैसे नहीं भेजे।';

  @override
  String get didWellToldFamily => 'आपने किसी भरोसेमंद को शामिल किया।';

  @override
  String get didWellGeneric => 'आप अभ्यास में टिके रहे और ड्रिल पूरी की।';

  @override
  String get stageContact => 'संपर्क';

  @override
  String get stageAccusation => 'आरोप';

  @override
  String get stageIsolation => 'अलगाव';

  @override
  String get stageUrgency => 'जल्दबाज़ी';

  @override
  String get stageTransfer => 'पैसा ट्रांसफर';

  @override
  String get labelP1 => 'कॉल पर बने रहे';

  @override
  String get labelP2 => 'पहचान मांगी';

  @override
  String get labelP3 => 'जानकारी साझा की';

  @override
  String get labelP4 => 'दबाव पहचाना';

  @override
  String get labelC1 => 'मांग का पालन किया';

  @override
  String get labelC2 => 'मांग का पालन किया';

  @override
  String get labelC3 => 'मांग का पालन किया';

  @override
  String get labelC4 => 'पैसे भेजे';

  @override
  String get labelUnknown => 'पल';

  @override
  String get reportTitle => 'साझा समीक्षा';

  @override
  String get reportIntro => 'यह समीक्षा प्रतिभागी ने साझा की थी।';

  @override
  String reportSharedAt(String date) {
    return '$date को साझा किया';
  }

  @override
  String get reportLoading => 'साझा समीक्षा लोड हो रही है';

  @override
  String get reportGoneTitle => 'यह रिपोर्ट उपलब्ध नहीं है';

  @override
  String get reportGoneBody =>
      'प्रतिभागी ने सत्र मिटा दिया हो या लिंक समाप्त हो गया हो।';

  @override
  String get reportOpenAgain => 'रिपोर्ट लिंक फिर खोलें';

  @override
  String get reportBackHome => 'शुरुआत पर वापस';

  @override
  String get aboutTitle => 'परिचय और सीमाएं';

  @override
  String get aboutWhatTitle => 'Dry Run क्या है';

  @override
  String get aboutWhatBody =>
      'डिजिटल अरेस्ट ठगी की कॉल पहचानने के लिए छोटी अभ्यास ड्रिल। अधिकारी की बातें पहले से तय हैं।';

  @override
  String get aboutNotTitle => 'यह क्या नहीं है';

  @override
  String get aboutNotBody =>
      'यह असली एजेंसी नहीं, आपकी परीक्षा नहीं, और ठगी से सुरक्षा नहीं है।';

  @override
  String get aboutStorageTitle => 'क्या संग्रह होता है';

  @override
  String aboutStorageBody(int days) {
    return 'ड्रिल की बातचीत और समीक्षा अधिकतम $days दिन रखी जाती है, फिर मिटा दी जाती है।';
  }

  @override
  String get aboutDeletionTitle => 'मिटाना';

  @override
  String get aboutDeletionBody =>
      'आप समीक्षा स्क्रीन से कभी भी सत्र और समीक्षा मिटा सकते हैं।';

  @override
  String get aboutAnalyticsTitle => 'कोई ट्रैकिंग नहीं';

  @override
  String get aboutAnalyticsBody =>
      'कोई एनालिटिक्स या विज्ञापन ट्रैकिंग नहीं है। गिनती साझा करना वैकल्पिक है और डिफ़ॉल्ट रूप से बंद है।';

  @override
  String get aboutPracticeTitle => 'अभ्यास, सुरक्षा नहीं';

  @override
  String get aboutPracticeBody =>
      'यह ड्रिल असली ठगी नहीं रोक सकती। असली कॉल गलत लगे तो कॉल काटें और आधिकारिक नंबर इस्तेमाल करें।';

  @override
  String get aboutHowItWorksTitle => 'यह कैसे काम करता है';

  @override
  String get aboutHowItWorksBody =>
      'ड्रिल ठगी के पांच चरणों से चलती है। अधिकारी आपके जवाबों के हिसाब से थोड़ा बदलता है।';

  @override
  String get aboutLimitsTitle => 'सत्र की सीमाएं';

  @override
  String get aboutLimitsLoading => 'सीमाएं लोड हो रही हैं';

  @override
  String get aboutLimitsFailed => 'सीमाएं लोड नहीं हो सकीं।';

  @override
  String aboutMaxTurns(int count) {
    return 'अधिकतम $count बारियां';
  }

  @override
  String aboutMaxDuration(int minutes) {
    return 'अधिकतम $minutes मिनट';
  }

  @override
  String aboutIdleTimeout(int minutes) {
    return 'निष्क्रियता समय $minutes मिनट';
  }

  @override
  String aboutRetention(int days) {
    return 'संग्रहण $days दिन';
  }

  @override
  String get aboutChatOnly =>
      'आवाज़ वैकल्पिक है और डिफ़ॉल्ट में बंद है। चैट हमेशा काम करती है।';

  @override
  String get aboutBackHome => 'शुरुआत पर वापस';

  @override
  String get graphLoading => 'ड्रिल का नक्शा लोड हो रहा है';

  @override
  String get graphFailed => 'ड्रिल का नक्शा लोड नहीं हो सका।';

  @override
  String graphStage(int number, String name) {
    return 'चरण $number: $name';
  }

  @override
  String get errorTitle => 'कुछ गड़बड़ हुई';

  @override
  String get errorNetwork => 'अपना कनेक्शन जांचें और फिर कोशिश करें।';

  @override
  String get errorServer =>
      'सर्वर में समस्या आई। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errorUnauthorized =>
      'आपका सत्र समाप्त हो गया। अपना लिंक फिर खोलें।';

  @override
  String get errorTurnMismatch =>
      'बातचीत का क्रम बिगड़ गया। फिर भेजने की कोशिश करें।';

  @override
  String get errorRateLimited =>
      'बहुत ज़्यादा अनुरोध। थोड़ी देर रुककर फिर कोशिश करें।';

  @override
  String get errorSessionLimit => 'इस निमंत्रण की सत्र सीमा पूरी हो गई है।';

  @override
  String get errorConsent => 'शुरू करने से पहले सहमति ज़रूरी है।';

  @override
  String get errorUnknown => 'एक अनपेक्षित समस्या आई।';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get close => 'बंद करें';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String get linkCopied => 'लिंक कॉपी हो गया';

  @override
  String get shareUnavailable =>
      'यहां साझा करना उपलब्ध नहीं है। इसके बजाय लिंक कॉपी कर दिया गया।';

  @override
  String shareReportMessage(String url) {
    return 'Dry Run अभ्यास समीक्षा: $url';
  }

  @override
  String get reportShareSubject => 'Dry Run अभ्यास समीक्षा';

  @override
  String get a11ySend => 'जवाब भेजें';

  @override
  String get a11yEnd => 'अभ्यास ड्रिल समाप्त करें';

  @override
  String get a11yShare => 'रिपोर्ट साझा करें';

  @override
  String get a11yDelete => 'सत्र मिटाएं';

  @override
  String get a11yBack => 'वापस जाएं';

  @override
  String get a11yDrillBadge => 'अभ्यास ड्रिल बैज';

  @override
  String get a11yLoading => 'लोड हो रहा है';

  @override
  String get a11yInviteLink => 'निमंत्रण लिंक';

  @override
  String get a11yReportLink => 'रिपोर्ट लिंक';

  @override
  String get a11yLanguageSelector => 'भाषा चुनें';
}
