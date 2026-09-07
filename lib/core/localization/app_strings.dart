import '../../services/voice_tts_service.dart';

/// Central in-app localization & regional language translation system
/// Covers Bengali (বাংলা), Hindi (हिन्दी), and English across all tabs and widgets.
class AppStrings {
  final TtsLanguage language;

  AppStrings(this.language);

  static AppStrings of(TtsLanguage lang) => AppStrings(lang);

  bool get isBengali => language == TtsLanguage.bengali;
  bool get isHindi => language == TtsLanguage.hindi;
  bool get isEnglish => language == TtsLanguage.english;

  // Bottom Navigation
  String get navHome => isBengali ? 'বাড়ি' : (isHindi ? 'होम' : 'Home');
  String get navScan => isBengali ? 'স্ক্যান' : (isHindi ? 'स्कैन' : 'Scan');
  String get navSensors => isBengali ? 'সেন্সর' : (isHindi ? 'सेंसर' : 'Sensors');
  String get navAdvisory => isBengali ? 'পরামর্শ' : (isHindi ? 'सलाह' : 'Advisory');
  String get navProfile => isBengali ? 'প্রোফাইল' : (isHindi ? 'प्रोफाइल' : 'Profile');

  // App Bar & Global
  String get appTitle => 'KrishiMitra AI';
  String get offlineTag => isBengali
      ? '১০০% অফলাইন // ফোন-অ্যাজ-ব্রেন'
      : (isHindi ? '100% ऑफलाइन // फोन-एज-ब्रेन' : '100% OFFLINE // PHONE-AS-BRAIN');

  // Auth Screen
  String get authTitle => isBengali ? 'কৃষিমিত্র' : (isHindi ? 'कृषिमित्र' : 'KRISHIMITRA');
  String get authSignInHeader => isBengali ? 'লগ ইন করুন' : (isHindi ? 'साइन इन करें' : 'Sign In');
  String get authCreateHeader => isBengali ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : (isHindi ? 'नया खाता बनाएँ' : 'Create Farmer Account');
  String get authNameLabel => isBengali ? 'আপনার পুরো নাম' : (isHindi ? 'आपका पूरा नाम' : 'FARMER FULL NAME');
  String get authUsernameLabel => isBengali ? 'ইউজারনেম' : (isHindi ? 'उपयोगकर्ता नाम' : 'USERNAME');
  String get authUsernameHint => isBengali ? 'উদাহরণ: কৃষক' : (isHindi ? 'उदाहरण: किसान' : 'e.g: farmer');
  String get authPasswordLabel => isBengali ? 'পাসওয়ার্ড' : (isHindi ? 'पासवर्ड' : 'PASSWORD');
  String get authSignInBtn => isBengali ? 'অ্যাপে প্রবেশ করুন' : (isHindi ? 'ऐप में साइन इन करें' : 'SIGN IN TO APP');
  String get authRegisterBtn => isBengali ? 'নিবন্ধন করুন' : (isHindi ? 'पंजीकरण करें' : 'REGISTER & SYNC PROFILE');
  String get authToggleToRegister => isBengali ? 'অ্যাকাউন্ট নেই? নিবন্ধন করুন' : (isHindi ? 'खाता नहीं है? पंजीकरण करें' : 'No account yet? Create one.');
  String get authToggleToSignIn => isBengali ? 'অ্যাকাউন্ট আছে? লগ ইন করুন' : (isHindi ? 'खाता है? साइन इन करें' : 'Already have an account? Sign in.');

  // Home Screen
  // Dynamic Time-Based Greeting (Morning, Afternoon, Evening, Night)
  String get greetingFarmer => getGreetingFarmer();
  String get greetingSubtitle => getGreetingSubtitle();

  String getGreetingFarmer([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 12) {
      return isBengali
          ? 'শুভ সকাল, কৃষক বন্ধু'
          : (isHindi ? 'शुभ प्रभात, किसान मित्र' : 'Good Morning, Farmer');
    } else if (hour >= 12 && hour < 17) {
      return isBengali
          ? 'শুভ দুপুর, কৃষক বন্ধু'
          : (isHindi ? 'शुभ दोपहर, किसान मित्र' : 'Good Afternoon, Farmer');
    } else if (hour >= 17 && hour < 21) {
      return isBengali
          ? 'শুভ সন্ধ্যা, কৃষক বন্ধু'
          : (isHindi ? 'शुभ संध्या, किसान मित्र' : 'Good Evening, Farmer');
    } else {
      return isBengali
          ? 'শুভ রাত্রি, কৃষক বন্ধু'
          : (isHindi ? 'शुभ रात्रि, किसान मित्र' : 'Good Night, Farmer');
    }
  }

  String getGreetingSubtitle([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 12) {
      return isBengali ? 'সকাল' : (isHindi ? 'सुबह' : 'Morning');
    } else if (hour >= 12 && hour < 17) {
      return isBengali ? 'দুপুর' : (isHindi ? 'दोपहर' : 'Afternoon');
    } else if (hour >= 17 && hour < 21) {
      return isBengali ? 'সন্ধ্যা' : (isHindi ? 'शाम' : 'Evening');
    } else {
      return isBengali ? 'রাত' : (isHindi ? 'रात' : 'Night');
    }
  }

  String get todaysActionPlan => isBengali
      ? 'আজকের কার্যপরিকল্পনা'
      : (isHindi ? 'आज की कार्ययोजना' : "TODAY'S ACTION PLAN");

  String get farmHealthTitle => isBengali ? 'খামারের স্বাস্থ্য' : (isHindi ? 'खेत का स्वास्थ्य' : 'Farm Health');
  String get healthyFarm => isBengali ? 'সুস্থ খামার' : (isHindi ? 'स्वस्थ खेत' : 'Healthy Farm');
  String get attentionRequired => isBengali ? 'দৃষ্টি আকর্ষণ প্রয়োজন' : (isHindi ? 'ध्यान देने योग्य' : 'Attention Required');
  String get fieldZones => isBengali ? 'জমির অঞ্চল পরিচালনা' : (isHindi ? 'खेत क्षेत्र प्रबंधन' : 'FIELD MANAGEMENT & ACTIVE ZONES');
  String get smartIrrigation => isBengali ? 'স্মার্ট সেচ ও জল পাম্প' : (isHindi ? 'स्मार्ट सिंचाई और जल पंप' : 'SMART IRRIGATION & WATER PUMP');
  String get hardwareDiag => isBengali ? 'হার্ডওয়্যার ডায়াগনস্টিকস' : (isHindi ? 'हार्डवेयर डायग्नोस्टिक्स' : 'OFFLINE HARDWARE DIAGNOSTICS');
  String get environmentOverview => isBengali ? 'খামারের পরিবেশ পরিস্থিতি' : (isHindi ? 'खेत पर्यावरण विवरण' : 'FARM ENVIRONMENT OVERVIEW');

  // Scan & Diagnostics Screen
  String get cropDiagnostics => isBengali ? 'এআই ফসল রোগ নির্ণয়' : (isHindi ? 'एआई फसल रोग निदान' : 'AI Crop Diagnostics');
  String get cropDiagSubtitle => isBengali
      ? '১০০% অফলাইন অন-ডিভাইস টিএফ-লাইট মডেল'
      : (isHindi ? '100% ऑफलाइन ऑन-डिवाइस टीएफ-लाइट मॉडल' : '100% Offline Neural Inference via Edge TFLite');
  String get captureLeaf => isBengali ? 'পাতা তুলুন' : (isHindi ? 'पत्ती कैप्चर करें' : 'CAPTURE LEAF');
  String get demoAsset => isBengali ? 'নমুনা পাতা' : (isHindi ? 'डेमो पत्ती' : 'DEMO ASSET');
  String get diagnosticMatrix => isBengali ? '৫-প্যারামিটার রোগ নির্ণয় ম্যাট্রিক্স' : (isHindi ? '5-पैरामीटर निदान मैट्रिक्स' : '5-PARAMETER DIAGNOSTIC MATRIX');
  String get viewPrescription => isBengali ? 'প্রেসক্রিপশন ও প্রতিকার দেখুন' : (isHindi ? 'प्रिस्क्रिप्शन और उपचार देखें' : 'VIEW PRESCRIPTION & REMEDIES');
  String get awaitLeafScan => isBengali
      ? 'পাতা স্ক্যান বা ডেমো পাতার অপেক্ষায়...'
      : (isHindi ? 'पत्ती स्कैन या डेमो पत्ती की प्रतीक्षा है...' : 'Awaiting Leaf Capture or Pitch Safety Net Injection');
  String get awaitLeafScanSub => isBengali
      ? 'রোগ নির্ণয় ও প্রতিকার দেখতে "পাতা তুলুন" বা "নমুনা পাতা" চাপুন।'
      : (isHindi
          ? 'रोग निदान और उपचार देखने के लिए "पत्ती कैप्चर करें" या "डेमो पत्ती" दबाएं।'
          : 'Tap "CAPTURE LEAF" or "DEMO ASSET" to run local neural inference and generate disease remedies.');
  String get confidence => isBengali ? 'নিশ্চিততা' : (isHindi ? 'सटीकता' : 'CONFIDENCE');

  // Text-to-Voice
  String get ttsTitle => isBengali ? 'টেক্সট টু ভয়েস (পরামর্শ)' : (isHindi ? 'टेक्स्ट टू वॉयस (सलाह)' : 'TEXT TO VOICE (TTS)');
  String get ttsSubtitle => isBengali
      ? 'কৃষকদের জন্য আঞ্চলিক মৌখিক পরামর্শ'
      : (isHindi ? 'किसानों के लिए क्षेत्रीय मौखिक सलाह' : 'ICAR/FAO oral advisory for regional farmers');
  String get readAloud => isBengali ? 'পড়ে শোনান' : (isHindi ? 'बोलकर सुनाएं' : 'READ ALOUD');
  String get testVoice => isBengali ? 'ভয়েস পরীক্ষা' : (isHindi ? 'आवाज परीक्षण' : 'TEST VOICE');
  String get stopVoice => isBengali ? 'থামান' : (isHindi ? 'रोकें' : 'STOP');
  String get statusAutoOn => isBengali ? 'স্বয়ংক্রিয় চালু' : (isHindi ? 'ऑटो चालू' : 'AUTO ON');
  String get statusMuted => isBengali ? 'নিঃশব্দ' : (isHindi ? 'म्यूट' : 'MUTED');
  String get statusSpeaking => isBengali ? 'বলছে...' : (isHindi ? 'बोल रहा है...' : 'SPEAKING');

  // Sensors & Telemetry
  String get sensorTelemetry => isBengali ? 'হার্ডওয়্যার টেলিমেট্রি ও আইওটি সেন্সর' : (isHindi ? 'हार्डवेयर टेलीमेट्री और आईओटी सेंसर' : 'HARDWARE TELEMETRY & IOT SENSORS');
  String get soilMoisture => isBengali ? 'মাটির আর্দ্রতা' : (isHindi ? 'मिट्टी की नमी' : 'Soil Moisture');
  String get ambientTemp => isBengali ? 'বায়ুর তাপমাত্রা' : (isHindi ? 'हवा का तापमान' : 'Ambient Temperature');
  String get rainSensor => isBengali ? 'বৃষ্টির স্থিতি' : (isHindi ? 'बारिश की स्थिति' : 'Rain Sensor');
  String get waterPump => isBengali ? 'জল পাম্প' : (isHindi ? 'पानी का पंप' : 'Water Pump');
  String get rainDetected => isBengali ? 'বৃষ্টি হচ্ছে' : (isHindi ? 'बारिश हो रही है' : 'Rain Active');
  String get noRain => isBengali ? 'বৃষ্টি নেই (শুষ্ক)' : (isHindi ? 'बारिश नहीं (शुष्क)' : 'Dry Conditions');
  String get pumpLocked => isBengali ? 'লক করা (নিরাপদ)' : (isHindi ? 'लॉक (सुरक्षित)' : 'LOCKED (Safe)');
  String get pumpUnlocked => isBengali ? 'আনলক (সক্রিয়)' : (isHindi ? 'अनलॉक (सक्रिय)' : 'UNLOCKED (Active)');

  // Settings & Profile
  String get languageSettings => isBengali ? 'অ্যাপ ও আঞ্চলিক ভয়েস ভাষা' : (isHindi ? 'ऐप और क्षेत्रीय आवाज भाषा' : 'APP & REGIONAL LANGUAGE');
  String get appearanceTheme => isBengali ? 'চেহারা ও থিম' : (isHindi ? 'दिखावट और थीम' : 'APPEARANCE & THEME');
  String get darkMode => isBengali ? 'ডার্ক মোড' : (isHindi ? 'डार्क मोड' : 'Dark Mode');
  String get lightMode => isBengali ? 'অর্গানিক লাইট মোড' : (isHindi ? 'ऑर्गेनिक लाइट मोड' : 'Organic Light Mode');
  String get safetyNetTitle => isBengali ? 'হার্ডওয়্যার বাইপাস ও ডেমো নেট' : (isHindi ? 'हार्डवेयर बाईपास और डेमो नेट' : 'HARDWARE BYPASS // PITCH SAFETY NET');
}
