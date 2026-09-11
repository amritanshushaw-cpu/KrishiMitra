import '../../services/voice_tts_service.dart';

class AppStrings {
  final TtsLanguage language;

  AppStrings(this.language);

  static AppStrings of(TtsLanguage lang) => AppStrings(lang);

  bool get isBengali => language == TtsLanguage.bengali;
  bool get isHindi => language == TtsLanguage.hindi;
  bool get isEnglish => language == TtsLanguage.english;

  // Bottom Navigation
  String get navHome => isBengali ? 'হোম' : (isHindi ? 'होम' : 'Home');
  String get navScan => isBengali ? 'স্ক্যান' : (isHindi ? 'स्कैन' : 'Scan');
  String get navSensors => isBengali ? 'সেন্সর' : (isHindi ? 'सेंसर' : 'Sensors');
  String get navAdvisory => isBengali ? 'পরামর্শ' : (isHindi ? 'सलाह' : 'Advisory');
  String get navHistory => isBengali ? 'ইতিহাস' : (isHindi ? 'इतिहास' : 'History');
  String get historyTitle => isBengali ? 'ইতিহাস' : (isHindi ? 'इतिहास' : 'HISTORY LOGS');
  String get navProfile => isBengali ? 'প্রোফাইল' : (isHindi ? 'प्रोफाइल' : 'Profile');

  // App Bar & Global
  String get appTitle => 'KrishiMitra AI';
  String get offlineTag => isBengali ? '১০০% অফলাইন' : (isHindi ? '১০০% ऑफलाइन' : '100% OFFLINE');

  // Home Screen
  String get greetingFarmer => getGreetingFarmer();
  String get greetingSubtitle => getGreetingSubtitle();

  String getGreetingFarmer([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 12) {
      return isBengali ? 'শুভ সকাল' : (isHindi ? 'सुप्रभात' : 'Good Morning');
    } else if (hour >= 12 && hour < 17) {
      return isBengali ? 'শুভ অপরাহ্ন' : (isHindi ? 'शुभ दोपहर' : 'Good Afternoon');
    } else if (hour >= 17 && hour < 20) {
      return isBengali ? 'শুভ সন্ধ্যা' : (isHindi ? 'शुभ संध्या' : 'Good Evening');
    } else {
      return isBengali ? 'শুভ রাত্রি' : (isHindi ? 'शुभ रात्रि' : 'Good Night');
    }
  }

  String getGreetingSubtitle() {
    return isBengali 
        ? 'আপনার খামার সেন্সর আজ সুস্থ আছে।' 
        : (isHindi ? 'आज आपके खेत के सेंसर स्वस्थ हैं।' : 'Your farm sensors are healthy today.');
  }

  String get latestAdviceTitle => isBengali ? 'সর্বশেষ পরামর্শ' : (isHindi ? 'नवीनतम सलाह' : 'Latest Advice');
  String get quickActions => isBengali ? 'দ্রুত পদক্ষেপ' : (isHindi ? 'त्वरित कार्रवाई' : 'QUICK ACTIONS');
  String get connectDevice => isBengali ? 'ডিভাইস সংযুক্ত করুন' : (isHindi ? 'डिवाइस कनेक्ट करें' : 'Connect Device');
  String get telemetryData => isBengali ? 'টেলিমেট্রি ডেটা' : (isHindi ? 'टेलीमेट्री डेटा' : 'Telemetry Data');
  String get scanLeaf => isBengali ? 'পাতা স্ক্যান করুন' : (isHindi ? 'पत्ता स्कैन करें' : 'Scan Leaf');

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
  String get cropDiagnostics => isBengali ? 'এআই ফসল রোগ নির্ণয়' : (isHindi ? 'এআই फसल रोग निदान' : 'AI Crop Diagnostics');
  String get cropDiagSubtitle => isBengali
      ? '১০০% অফলাইন অন-ডিভাইস টিএফ-লাইট মডেল'
      : (isHindi ? '100% ऑफलाइन ऑन-डिवाइस टीएफ-लाइट मॉडल' : '100% Offline Neural Inference via Edge TFLite');
  String get captureLeaf => isBengali ? 'পাতা তুলুন' : (isHindi ? 'पत्ती कैप्चर करें' : 'CAPTURE LEAF');
  String get esp32Cam => isBengali ? 'ইএসপি৩২ ক্যামেরা' : (isHindi ? 'ईएसपी32 कैमरा' : 'ESP32 CAM');
  String get phoneCamera => isBengali ? 'ফোন ক্যামেরা' : (isHindi ? 'फ़ोन कैमरा' : 'PHONE CAMERA');
  String get captureWithPhone => isBengali ? 'ফোন ক্যামেরা দিয়ে তুলুন' : (isHindi ? 'फ़ोन कैमरे से लें' : 'CAPTURE FROM PHONE');
  String get captureWithEsp32 => isBengali ? 'ইএসপি৩২ দিয়ে তুলুন' : (isHindi ? 'ईएसपी32 से कैप्चर करें' : 'CAPTURE VIA ESP32');
  String get uploadFromStorage => isBengali ? 'ফোন স্টোরেজ থেকে আপলোড' : (isHindi ? 'फ़ोन स्टोरेज से अपलोड करें' : 'UPLOAD FROM PHONE STORAGE');
  String get demoAsset => isBengali ? 'নমুনা পাতা' : (isHindi ? 'डेमो पत्ती' : 'DEMO ASSET');
  String get diagnosticMatrix => isBengali ? '৫-প্যারামিটার রোগ নির্ণয় ম্যাট্রিক্স' : (isHindi ? '5-पैरामीटर निदान मैट्रिक्स' : '5-PARAMETER DIAGNOSTIC MATRIX');
  String get viewPrescription => isBengali ? 'প্রেসক্রিপশন ও প্রতিকার দেখুন' : (isHindi ? 'प्रिस्क्रिप्शन और उपचार देखें' : 'VIEW PRESCRIPTION & REMEDIES');
  String get awaitLeafScan => isBengali
      ? 'পাতা স্ক্যান বা ডেমো পাতার অপেক্ষায়...'
      : (isHindi ? 'पत्ती स्कैन या डेमो पत्ती की प्रतीक्षा है...' : 'Awaiting Leaf Capture or Pitch Safety Net Injection');
  String get awaitLeafScanSub => isBengali
      ? 'রোগ নির্ণয় ও প্রতিকার দেখতে "পাতা তুলুন" বা "নমুনা পাতা" চাপুন।'
      : (isHindi
          ? 'রোগ निदान और उपचार देखने के लिए "पत्ती कैप्चर करें" या "डेमो पत्ती" दबाएं।'
          : 'Tap "CAPTURE LEAF" or "DEMO ASSET" to run local neural inference and generate disease remedies.');
  String get confidence => isBengali ? 'নিশ্চিততা' : (isHindi ? 'सटीकता' : 'CONFIDENCE');

  // Text-to-Voice
  String get ttsTitle => isBengali ? 'টেক্সট টু ভয়েস (পরামর্শ)' : (isHindi ? 'টেক্সট টু वॉयस (सलाह)' : 'TEXT TO VOICE (TTS)');
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
  String get sensorTelemetry => isBengali ? 'হার্ডওয়্যার টেলিমেট্রি ও আইওটি সেন্সর' : (isHindi ? 'हार्डवेयर टेलीमेट्री और आईওটি সেন্সর' : 'HARDWARE TELEMETRY & IOT SENSORS');
  String get soilMoisture => isBengali ? 'মাটির আর্দ্রতা' : (isHindi ? 'मिट्टी की नमी' : 'Soil Moisture');
  String get ambientTemp => isBengali ? 'বায়ুর তাপমাত্রা' : (isHindi ? 'हवा का तापमान' : 'Ambient Temperature');
  String get rainSensor => isBengali ? 'বৃষ্টির স্থিতি' : (isHindi ? 'बारिश की स्थिति' : 'Rain Sensor');
  String get waterPump => isBengali ? 'জল পাম্প' : (isHindi ? 'पानी का पंप' : 'Water Pump');
  String get rainDetected => isBengali ? 'বৃষ্টি হচ্ছে' : (isHindi ? 'बारिश सक्रिय' : 'Rain Active');
  String get noRain => isBengali ? 'বৃষ্টি নেই (শুষ্ক)' : (isHindi ? 'শুষ্ক অবস্থা' : 'Dry Conditions');
  String get pumpLocked => isBengali ? 'লক করা (নিরাপদ)' : (isHindi ? 'लॉक (सुरक्षित)' : 'LOCKED (Safe)');
  String get pumpUnlocked => isBengali ? 'আনলক করা (সক্রিয়)' : (isHindi ? 'अनलॉक (सक्रिय)' : 'UNLOCKED (Active)');

  // Auth Screen
  String get authTitle => isBengali ? 'কৃষিমিত্র' : (isHindi ? 'कृषिमित्र' : 'KRISHIMITRA');
  String get authSignInHeader => isBengali ? 'সাইন ইন করুন' : (isHindi ? 'साइन इन करें' : 'Sign In');
  String get authCreateHeader => isBengali ? 'কৃষক অ্যাকাউন্ট তৈরি করুন' : (isHindi ? 'किसान खाता बनाएँ' : 'Create Farmer Account');
  String get authNameLabel => isBengali ? 'কৃষকের পুরো নাম' : (isHindi ? 'किसान का पूरा नाम' : 'FARMER FULL NAME');
  String get authMobileLabel => isBengali ? 'মোবাইল নম্বর' : (isHindi ? 'मोबाइल नंबर' : 'MOBILE NUMBER');
  String get authMobileHint => isBengali ? 'যেমন: 9876543210' : (isHindi ? 'जैसे: 9876543210' : 'e.g: 9876543210');
  String get authPasswordLabel => isBengali ? 'পাসওয়ার্ড' : (isHindi ? 'पासवर्ड' : 'PASSWORD');
  String get authSignInBtn => isBengali ? 'অ্যাপে সাইন ইন করুন' : (isHindi ? 'ऐप में साइन इन करें' : 'SIGN IN TO APP');
  String get authRegisterBtn => isBengali ? 'নিবন্ধন এবং সিঙ্ক প্রোফাইল' : (isHindi ? 'पंजीकरण और सिंक प्रोफाइल' : 'REGISTER & SYNC PROFILE');
  String get authToggleToRegister => isBengali ? 'এখনও কোনো অ্যাকাউন্ট নেই? একটি তৈরি করুন।' : (isHindi ? 'अभी तक कोई खाता नहीं है? एक बनाएँ।' : 'No account yet? Create one.');
  String get authToggleToSignIn => isBengali ? 'ইতোমধ্যে একটি অ্যাকাউন্ট আছে? সাইন ইন করুন।' : (isHindi ? 'पहले से ही एक खाता है? साइन इन करें।' : 'Already have an account? Sign in.');

  // Settings & Profile
  String get languageSettings => isBengali ? 'অ্যাপ এবং আঞ্চলিক ভাষা' : (isHindi ? 'ऐप और क्षेत्रीय भाषा' : 'APP & REGIONAL LANGUAGE');
  String get appearanceTheme => isBengali ? 'চেহারা এবং থিম' : (isHindi ? 'রূপ-রंग और थीम' : 'APPEARANCE & THEME');
  String get darkMode => isBengali ? 'ডার্ক মোড' : (isHindi ? 'डार्क मोड' : 'Dark Mode');
  String get lightMode => isBengali ? 'অর্গানিক লাইট মোড' : (isHindi ? 'ऑर्गेनिक लाइट मोड' : 'Organic Light Mode');
  String get safetyNetTitle => isBengali ? 'হার্ডওয়্যার বাইপাস // পিচ সেফটি নেট' : (isHindi ? 'हार्डवेयर बाईपास // पिच सेफ्टी नेट' : 'HARDWARE BYPASS // PITCH SAFETY NET');
  String get securitySettings => isBengali ? 'নিরাপত্তা এবং পরিচয়পত্র' : (isHindi ? 'सुरक्षा और क्रेडेंशियल' : 'SECURITY & CREDENTIALS');
  String get changePassword => isBengali ? 'পাসওয়ার্ড পরিবর্তন করুন' : (isHindi ? 'पासवर्ड बदलें' : 'Change Password');
  String get currentPassword => isBengali ? 'বর্তমান পাসওয়ার্ড' : (isHindi ? 'वर्तमान पासवर्ड' : 'Current Password');
  String get newPassword => isBengali ? 'নতুন পাসওয়ার্ড' : (isHindi ? 'नया पासवर्ड' : 'New Password');
  String get confirmNewPassword => isBengali ? 'নতুন পাসওয়ার্ড নিশ্চিত করুন' : (isHindi ? 'नया पासवर्ड जांचें' : 'Confirm New Password');
  String get updatePasswordBtn => isBengali ? 'পাসওয়ার্ড আপডেট করুন' : (isHindi ? 'पासवर्ड अपडेट करें' : 'UPDATE PASSWORD');

  // Dashboard & Cockpit
  String get cockpitTitle => isBengali ? 'ডেটা এবং বৃদ্ধি // ককপিট' : (isHindi ? 'ডेटा और विकास // कॉकपिट' : 'DATA MEETS GROWTH // COCKPIT');
  String get interactive => isBengali ? 'ইন্টারেক্টিভ' : (isHindi ? 'इंटरएक्टिव' : 'INTERACTIVE');
  String get cockpitDesc => isBengali ? 'অ্যানিমেটেড মাটির আর্দ্রতা গ্রাফ এবং জলবায়ু গেজ।' : (isHindi ? 'एनिमेटेड मिट्टी की नमी ग्राफ और जलवायु गेज।' : 'Interactive animated Soil Wave area graphs, ClimateIQ 180A rainbow arc gauge.');
  String get openCockpit => isBengali ? 'ককপিট খুলুন' : (isHindi ? 'कॉकपिट खोलें' : 'Open Cockpit & Research Hub');
  String get weatherAlert => isBengali ? 'আবহাওয়া সতর্কতা' : (isHindi ? 'मौसम चेतावनी' : 'WEATHER ALERT');
  String get optimalCycle => isBengali ? 'সর্বোত্তম চক্র' : (isHindi ? 'इष्टतम चक्र' : 'OPTIMAL CYCLE');
  String get cropScore => isBengali ? 'ফসল স্কোর' : (isHindi ? 'फसल स्कोर' : 'CROP SCORE');
  String get overallHealth => isBengali ? 'সার্বিক খামার স্বাস্থ্য সূচক' : (isHindi ? 'समग्र खेत स्वास्थ्य सूचकांक' : 'Overall Farm Health Index');
  String get safetyNetSub => isBengali ? 'অফলাইন রোগ নির্ণয় পরীক্ষার জন্য উচ্চ-মানের পাতার ছবি লোড করুন।' : (isHindi ? 'ऑफ़लाइन रोग निदान परीक्षण के लिए उच्च-गुणवत्ता वाली पत्ती की छवियां लोड करें।' : 'Instantly inject high-res leaf assets to test offline neural diagnosis without requiring live ESP32 camera Wi-Fi.');

  // History Logs & Headers
  String get colDate => isBengali ? 'তারিখ' : (isHindi ? 'तारीख' : 'Date');
  String get colTime => isBengali ? 'সময়' : (isHindi ? 'समय' : 'Time');
  String get colTemp => isBengali ? 'তাপমাত্রা (°C)' : (isHindi ? 'तापमान (°C)' : 'Temp (°C)');
  String get colHumidity => isBengali ? 'আর্দ্রতা (%)' : (isHindi ? 'नमी (%)' : 'Humidity (%)');
  String get colSoil => isBengali ? 'মাটির আর্দ্রতা' : (isHindi ? 'मिट्टी की नमी' : 'Soil Moisture');
  String get colAdvice => isBengali ? 'উত্পাদিত পরামর্শ' : (isHindi ? 'उत्पन्न सलाह' : 'Advice Generated');
  String get noLogsYet => isBengali ? 'এখনও কোনো ডেটা নেই। ESP32 ডেটা এখানে আসবে।' : (isHindi ? 'अभी कोई डेटा नहीं। ESP32 डेटा यहाँ आएगा।' : 'No logs yet. ESP32 data will appear here.');
  String get historyDesc => isBengali ? 'রিয়েল-টাইম ESP32 সেন্সর ক্যাপচার এবং এআই পরামর্শ রেকর্ড।' : (isHindi ? 'रियल-टाइम ESP32 सेंसर कैप्चर और एআই सलाह रिकॉर्ड।' : 'Real-time ESP32 sensor captures and AI advisory records.');
  String get downloadHistoryBtn => isBengali ? 'ইতিহাস ডাউনলোড করুন (TXT)' : (isHindi ? 'इतिहास डाउनलोड करें (TXT)' : 'Download History (TXT)');
  String get selectDuration => isBengali ? 'সময়কাল নির্বাচন করুন' : (isHindi ? 'अवधि चुनें' : 'Select Duration');
  String get daysPrefix => isBengali ? 'শেষ' : (isHindi ? 'पिछले' : 'Last');
  String get daysSuffix => isBengali ? 'দিন' : (isHindi ? 'दिन' : 'Days');
  String get daySuffix => isBengali ? 'দিন' : (isHindi ? 'दिन' : 'Day');
  String get scanHistoryTitle => isBengali ? '৭-দিনের স্ক্যান ইতিহাস' : (isHindi ? '7-दिन स्कैन इतिहास' : '7-Day Scan History');
  String get scanPrefix => isBengali ? 'স্ক্যান #' : (isHindi ? 'स्कैन #' : 'Scan #');
}
