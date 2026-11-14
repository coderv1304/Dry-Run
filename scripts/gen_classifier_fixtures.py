"""Generate synthetic classifier fixtures.  All content needs human review.

Run from the repository root: ``python scripts/gen_classifier_fixtures.py``.
"""

from __future__ import annotations

from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "tests" / "fixtures"

EN = {
    "P1": [
        "I will hang up now",
        "I am going to cut the call",
        "Please stop calling me",
        "I am not interested in this call",
        "I refuse to continue",
        "I will not send any money",
        "I will not share anything",
        "Goodbye, I am ending this call",
        "I want to disconnect now",
        "I will not talk to you",
    ],
    "P2": [
        "Can I see your badge",
        "Please show me your ID card",
        "I need to verify your identity",
        "What is your official number",
        "I will call you back",
        "Which department are you from",
        "Can I speak to your senior",
        "Give me a callback number",
        "I want verification of your badge",
        "Please verify your identity",
    ],
    "P3": [
        "I want to tell my family",
        "My wife is here",
        "I will call my husband",
        "Let me speak to my son",
        "I need to tell my daughter",
        "I will ask my mother",
        "My father is with me",
        "I want to call my lawyer",
        "I will tell my friend",
        "Can my colleague join",
    ],
    "P4": [
        "This is a scam",
        "I think this is fraud",
        "This call is fake",
        "This is not real",
        "This is a trick",
        "You are lying to me",
        "Are you cheating me",
        "This looks like spoofing",
        "This is phishing",
        "This feels like a scam",
    ],
    "C1": [
        "My name is Ahmed",
        "My aadhaar number is on file",
        "I can share my OTP",
        "Here is my card number",
        "I will give my CVV",
        "My date of birth is today",
        "I can read my PAN number",
        "I will share my account number",
        "I can tell you my identity number",
        "I will send my details",
    ],
    "C2": [
        "I am alone",
        "I will not tell anyone",
        "Nobody is with me",
        "No one else is here",
        "I will keep this between us",
        "I am alone at home",
        "I will stay quiet",
        "I will not tell my friend",
        "I am not telling anyone",
        "I will handle this alone",
    ],
    "C3": [
        "What should I do",
        "Tell me what to do",
        "I am scared",
        "I am afraid",
        "Please help me",
        "I will cooperate",
        "Yes sir",
        "Okay sir",
        "I understand",
        "I am listening",
    ],
    "C4": [
        "I will transfer the money",
        "I can send money now",
        "I will pay now",
        "I will make a payment",
        "Give me the bank account",
        "I will use UPI",
        "Tell me the IFSC code",
        "I will deposit the amount",
        "I will remit it",
        "I will send the money today",
    ],
}

HI = {
    "P1": [
        "मैं फोन रख देता हूँ",
        "मैं कॉल काट दूंगा",
        "मुझे बात नहीं करनी",
        "मैं पैसे नहीं भेजूंगा",
        "मैं मना करता हूँ",
        "यह कॉल बंद करो",
        "मुझ पर कॉल मत करो",
        "मैं बात नहीं करूंगा",
        "आपको फोन रखना होगा",
        "मैं यह नहीं करूंगा",
    ],
    "P2": [
        "मुझे आपका बैज दिखाइए",
        "आपकी पहचान क्या है",
        "मैं सत्यापन करना चाहता हूँ",
        "आपका आधिकारिक नंबर क्या है",
        "मैं वापस कॉल करूंगा",
        "आप किस विभाग से हैं",
        "मुझे आपके वरिष्ठ से बात करनी है",
        "आपकी आईडी दिखाइए",
        "मैं पहचान सत्यापित करना चाहता हूँ",
        "मुझे सत्यापन चाहिए",
    ],
    "P3": [
        "मैं अपने परिवार को बताना चाहता हूँ",
        "मेरी पत्नी यहाँ है",
        "मैं अपने पति को बुलाऊंगा",
        "मुझे अपने बेटे से बात करनी है",
        "मैं अपनी बेटी को बताऊंगा",
        "मैं अपनी माँ से पूछूंगा",
        "मेरे पिता मेरे साथ हैं",
        "मैं अपने वकील को बुलाऊंगा",
        "मैं अपने दोस्त को बताऊंगा",
        "मेरा भाई भी सुन सकता है",
    ],
    "P4": [
        "यह धोखा है",
        "यह ठगी लगती है",
        "यह कॉल फर्जी है",
        "आप झूठ बोल रहे हैं",
        "आप मुझे ठग रहे हैं",
        "यह नकली लगता है",
        "यह फ्रॉड है",
        "मुझे यह गलत लगता है",
        "यह सच नहीं है",
        "यह एक चाल है",
    ],
    "C1": [
        "मेरा नाम अहमद है",
        "मेरा आधार रिकॉर्ड में है",
        "मैं ओटीपी बता सकता हूँ",
        "मेरा कार्ड नंबर यह है",
        "मैं सीवीवी बता दूंगा",
        "मेरी जन्म तिथि आज है",
        "मैं अपना पैन बता सकता हूँ",
        "मैं खाता संख्या बता दूंगा",
        "मैं अपना ओटीपी बताऊंगा",
        "मैं अपना आधार बताऊंगा",
    ],
    "C2": [
        "मैं अकेला हूँ",
        "मैं किसी को नहीं बताऊंगा",
        "मेरे साथ कोई नहीं है",
        "घर पर कोई नहीं है",
        "मैं चुप रहूंगा",
        "मैं अकेली हूँ",
        "मैं किसी को नहीं बता रहा",
        "मैं चुप रहूंगा और सुनूंगा",
        "मेरे साथ कोई नहीं बैठा",
        "मैं किसी को नहीं बताऊंगा अभी",
    ],
    "C3": [
        "मुझे क्या करना चाहिए",
        "बताओ क्या करना है",
        "मुझे डर लग रहा है",
        "मैं डर गया हूँ",
        "कृपया मदद करो",
        "मैं सहयोग करूंगा",
        "हाँ सर",
        "ठीक है सर",
        "मैं समझ गया",
        "मैं सुन रहा हूँ",
    ],
    "C4": [
        "मैं पैसे भेज दूंगा",
        "मैं अभी पैसे भेज सकता हूँ",
        "मैं भुगतान कर दूंगा",
        "मैं ट्रांसफर करूंगा",
        "मुझे बैंक खाता बताइए",
        "मैं यूपीआई इस्तेमाल करूंगा",
        "मुझे आईएफएससी बताइए",
        "मैं राशि जमा कर दूंगा",
        "मैं पैसे भेज देता हूँ",
        "मैं आज भुगतान करूंगा",
    ],
}

HINGLISH = {
    "P1": [
        "Main phone rakh deta hoon",
        "Main call kaat dunga",
        "Mujhe baat nahi karni",
        "Main paise nahi bhejunga",
        "Main mana karta hoon",
        "Yeh call band karo",
        "Mujh par call mat karo",
        "Main baat nahi karunga",
        "Aapko phone rakhna hoga",
        "Main yeh nahi karunga",
    ],
    "P2": [
        "Mujhe apna badge dikhaiye",
        "Aapki pehchan kya hai",
        "Main verify karna chahta hoon",
        "Aapka official number kya hai",
        "Main wapas call karunga",
        "Aap kis department se hain",
        "Mujhe aapke senior se baat karni hai",
        "Apni ID dikhaiye",
        "Main identity verify karna chahta hoon",
        "Mujhe verification chahiye",
    ],
    "P3": [
        "Main apne parivar ko batana chahta hoon",
        "Meri patni yahan hai",
        "Main apne pati ko bulaunga",
        "Mujhe apne bete se baat karni hai",
        "Main apni beti ko bataunga",
        "Main apni maa se poochunga",
        "Mere papa mere saath hain",
        "Main apne vakil ko bulaunga",
        "Main apne dost ko bataunga",
        "Mera bhai bhi sun sakta hai",
    ],
    "P4": [
        "Yeh dhoka hai",
        "Yeh thagi lagti hai",
        "Yeh call fake hai",
        "Yeh sach nahi hai",
        "Yeh ek trick hai",
        "Aap jhooth bol rahe hain",
        "Aap mujhe thag rahe hain",
        "Yeh nakli lagta hai",
        "Yeh fraud hai",
        "Mujhe yeh galat lagta hai",
    ],
    "C1": [
        "Mera naam Ahmed hai",
        "Mera aadhaar record mein hai",
        "Main OTP bata sakta hoon",
        "Mera card number yeh hai",
        "Main CVV bata dunga",
        "Meri janm tithi aaj hai",
        "Main apna PAN bata sakta hoon",
        "Main account number bata dunga",
        "Main apna OTP bataunga",
        "Main apna aadhaar bataunga",
    ],
    "C2": [
        "Main akela hoon",
        "Main kisi ko nahi bataunga",
        "Mere saath koi nahi hai",
        "Ghar par koi nahi hai",
        "Main chup rahunga",
        "Main akeli hoon",
        "Main kisi ko nahi bata raha",
        "Main chup rahunga aur sununga",
        "Mere saath koi nahi baitha",
        "Main kisi ko nahi bataunga abhi",
    ],
    "C3": [
        "Mujhe kya karna chahiye",
        "Batao kya karna hai",
        "Mujhe dar lag raha hai",
        "Main dar gaya hoon",
        "Please madad karo",
        "Main sahyog karunga",
        "Haan sir",
        "Theek hai sir",
        "Main samajh gaya",
        "Main sun raha hoon",
    ],
    "C4": [
        "Main paise bhej dunga",
        "Main abhi paise bhej sakta hoon",
        "Main payment kar dunga",
        "Main transfer karunga",
        "Mujhe bank account bataiye",
        "Main UPI use karunga",
        "Mujhe IFSC bataiye",
        "Main amount jama kar dunga",
        "Main paise bhej deta hoon",
        "Main aaj payment karunga",
    ],
}

SUFFIXES = {
    "en": ["", " please", " right now"],
    "hi": ["", " कृपया", " अभी"],
    "hinglish": ["", " please", " abhi"],
}


def build(language: str, groups: dict[str, list[str]]) -> dict[str, object]:
    """Expand ten base phrases per label into thirty utterances."""
    utterances: dict[str, list[dict[str, str]]] = {}
    for label, phrases in groups.items():
        rows: list[dict[str, str]] = []
        index = 0
        for phrase in phrases:
            for suffix in SUFFIXES[language]:
                index += 1
                rows.append(
                    {
                        "id": f"{language}-{label}-{index:02d}",
                        "text": f"{phrase}{suffix}".strip(),
                    }
                )
        utterances[label] = rows
    return {
        "meta": {
            "synthetic": True,
            "human_review": "pending",
            "language": language,
            "warning": "Internal evaluation only. Never cite as an accuracy claim.",
        },
        "utterances": utterances,
    }


def main() -> None:
    """Write the three fixture files."""
    OUT.mkdir(parents=True, exist_ok=True)
    for language, groups in (("en", EN), ("hi", HI), ("hinglish", HINGLISH)):
        path = OUT / f"utterances_{language}.yaml"
        path.write_text(
            yaml.safe_dump(build(language, groups), allow_unicode=True, sort_keys=False),
            encoding="utf-8",
        )
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
