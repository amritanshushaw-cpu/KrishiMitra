import 'translation_map.dart';
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

  // Dashboard & Telemetry Cards
  String get soilStatusDry => isBengali ? 'শুষ্ক' : (isHindi ? 'सूखी' : 'Dry');
  String get soilStatusOptimal => isBengali ? 'অনুকূল' : (isHindi ? 'इष्टतम' : 'Optimal');
  String get waterPumpControl => isBengali ? 'জল পাম্প নিয়ন্ত্রণ' : (isHindi ? 'जल पंप नियंत्रण' : 'Water Pump Control');
  String get pumpIsOn => isBengali ? 'পাম্প চালু আছে' : (isHindi ? 'पंप चालू है' : 'Pump is ON');
  String get pumpIsOff => isBengali ? 'পাম্প বন্ধ আছে' : (isHindi ? 'पंप बंद है' : 'Pump is OFF');
  String get turnOn => isBengali ? 'চালু করুন' : (isHindi ? 'चालू करें' : 'TURN ON');
  String get turnOff => isBengali ? 'বন্ধ করুন' : (isHindi ? 'बंद करें' : 'TURN OFF');
  String get latestAdvice => isBengali ? 'সর্বশেষ পরামর্শ' : (isHindi ? 'नवीनतम सलाह' : 'Latest Advice');
  String get diagComplete => isBengali ? 'রোগ নির্ণয় সম্পন্ন' : (isHindi ? 'निदान पूरा हुआ' : 'Diagnosis Complete');
  
  // Sensors Tab
  String get liveEdgeNode => isBengali ? 'ESP32 লাইভ নোড' : (isHindi ? 'ESP32 लाइव नोड' : 'ESP32 Live Edge Node');
  String get pingNode => isBengali ? 'পিং নোড' : (isHindi ? 'पिंग नोड' : 'Ping Node');
  String get captureFrame => isBengali ? 'ছবি তুলুন' : (isHindi ? 'तस्वीर लें' : 'Capture Frame');
  
  // Tools & Calculators Hub
  String get agronomicCalculators => isBengali ? 'কৃষি ক্যালকুলেটর' : (isHindi ? 'कृषि कैलकुलेटर' : 'Agronomic Calculators');
  String get icarStandard => isBengali ? 'ICAR ও FAO স্ট্যান্ডার্ড ইঞ্জিন' : (isHindi ? 'ICAR और FAO मानक इंजन' : 'ICAR & FAO Standard Advisory Engine');
  
  // Calculator Content
  String get selectTargetCrop => isBengali ? 'ফসল নির্বাচন করুন' : (isHindi ? 'फसल चुनें' : 'SELECT TARGET CROP');
  String get plotSurfaceArea => isBengali ? 'প্লটের ক্ষেত্রফল' : (isHindi ? 'खेत का क्षेत्रफल' : 'Plot Surface Area');
  String get totalFertilizer => isBengali ? 'মোট সারের প্রয়োজন' : (isHindi ? 'कुल उर्वरक की आवश्यकता' : 'TOTAL FERTILIZER REQUIRED');
  String get subBudget => isBengali ? 'ভর্তুকি সারের বাজেট:' : (isHindi ? 'सब्सिडी उर्वरक बजट:' : 'Subsidized Fertilizer Budget:');
  String get splitTimeline => isBengali ? 'প্রয়োগের সময়সূচী (ICAR)' : (isHindi ? 'अनुप्रयोग समयरेखा (ICAR)' : 'SPLIT APPLICATION TIMELINE (ICAR PROTOCOL)');
  
  // Location
  String get farmLocation => isBengali ? 'খামারের অবস্থান' : (isHindi ? 'खेत का स्थान' : 'FARM LOCATION & GPS SYNCHRONIZATION');
  String get edgeGeo => isBengali ? 'এজ জিওলোকেশন' : (isHindi ? 'एज जियोलोकेशन' : 'EDGE GEOLOCATION');
  String get autoFetch => isBengali ? 'অটো-ফেচ অবস্থান' : (isHindi ? 'ऑटो-फेच स्थान' : 'AUTO-FETCH LOCATION');
  String get fetching => isBengali ? 'অবস্থান আনা হচ্ছে...' : (isHindi ? 'स्थान प्राप्त किया जा रहा है...' : 'FETCHING LOCATION...');
  
  // Additional translations
  String get bags => isBengali ? 'ব্যাগ' : (isHindi ? 'बैग' : 'Bags');
  String get kgTotal => isBengali ? 'কেজি মোট' : (isHindi ? 'किलो कुल' : 'kg total');

  // Weather Status Bar & Environment
  String get envOverview => isBengali ? 'খামার পরিবেশ' : (isHindi ? 'खेत का वातावरण' : 'FARM ENVIRONMENT OVERVIEW');
  String get envSoilMoisture => isBengali ? 'মাটির আর্দ্রতা' : (isHindi ? 'मिट्टी की नमी' : 'Soil Moisture');
  String get envAirTemp => isBengali ? 'বায়ুর তাপমাত্রা' : (isHindi ? 'हवा का तापमान' : 'Air Temp');
  String get envHumidity => isBengali ? 'আর্দ্রতা' : (isHindi ? 'नमी' : 'Humidity');
  String get envRainSky => isBengali ? 'বৃষ্টি / আকাশ' : (isHindi ? 'बारिश / आसमान' : 'Rain / Sky');
  
  String get envDryAlert => isBengali ? 'শুষ্ক সতর্কতা' : (isHindi ? 'सूखा अलर्ट' : 'Dry Alert');
  String get envSaturated => isBengali ? 'সম্পৃক্ত' : (isHindi ? 'संतृप्त' : 'Saturated');
  String get envOptimal => isBengali ? 'অনুকূল' : (isHindi ? 'इष्टतम' : 'Optimal');
  String get envPrecipitation => isBengali ? 'বৃষ্টিপাত' : (isHindi ? 'बारिश' : 'Precipitation');
  String get envClearSky => isBengali ? 'পরিষ্কার আকাশ' : (isHindi ? 'साफ आसमान' : 'Clear Sky');
  String get envThermalStress => isBengali ? 'তাপীয় চাপ' : (isHindi ? 'थर्मल स्ट्रेस' : 'Thermal Stress');
  String get envDaytime => isBengali ? 'দিনের বেলা' : (isHindi ? 'दिन का समय' : 'Daytime');
  String get envNightCycle => isBengali ? 'রাতের চক্র' : (isHindi ? 'रात का चक्र' : 'Night Cycle');

  // Calculator Constants
  String get calcAreaLabel => isBengali ? 'ক্ষেত্রফল:' : (isHindi ? 'क्षेत्रफल:' : 'Area:');
  String get calcIcarNpk => isBengali ? 'ICAR NPK:' : (isHindi ? 'ICAR NPK:' : 'ICAR NPK:');
  String get calcDapUreaMop => isBengali ? 'ড্যাপ + ইউরিয়া + এমওপি' : (isHindi ? 'डीएपी + यूरिया + एमओपी' : 'DAP + Urea + MOP');
  String get calcSspUreaMop => isBengali ? 'এসএসপি + ইউরিয়া + এমওপি' : (isHindi ? 'एसएसपी + यूरिया + एमओपी' : 'SSP + Urea + MOP');
  String get calcCommonStd => isBengali ? 'সাধারণ স্ট্যান্ডার্ড' : (isHindi ? 'सामान्य मानक' : 'Common Standard');
  String get calcSulfurFort => isBengali ? 'সালফার ফর্টিফাইড' : (isHindi ? 'सल्फर फोर्टिफाइड' : 'Sulfur Fortified');
  
  String get calcUreaL => isBengali ? 'ইউরিয়া (৪৬% N)' : (isHindi ? 'यूरिया (46% N)' : 'Urea (46% N)');
  String get calcDapL => isBengali ? 'ড্যাপ (P+N)' : (isHindi ? 'डीएपी (P+N)' : 'DAP (P+N)');
  String get calcSspL => isBengali ? 'এসএসপি (১৬% P)' : (isHindi ? 'एसएसपी (16% P)' : 'SSP (16% P)');
  String get calcMopL => isBengali ? 'এমওপি (৬০% K)' : (isHindi ? 'एमओपी (60% K)' : 'MOP (60% K)');
  
  String get calcStage1 => isBengali ? 'পর্যায় ১ - বেসাল প্রয়োগ' : (isHindi ? 'चरण 1 - बेसल अनुप्रयोग' : 'Stage 1 — Basal Application');
  String get calcTiming1 => isBengali ? 'রোপণ বা জমি তৈরির সময়' : (isHindi ? 'रोपाई या जमीन की तैयारी के समय' : 'At transplanting or final land tilling');
  String get calcStage2 => isBengali ? 'পর্যায় ২ - ভেজিটেটিভ টপ-ড্রেসিং' : (isHindi ? 'चरण 2 - वनस्पति टॉप-ड्रेसिंग' : 'Stage 2 — Vegetative Top-Dressing');
  String get calcTiming2 => isBengali ? 'রোপণের ২১-২৫ দিন পর (টিলারিং)' : (isHindi ? 'रोपाई के 21-25 दिन बाद (टिलरिंग)' : '21 to 25 days after planting (Tillering)');
  String get calcStage3 => isBengali ? 'পর্যায় ৩ - ফুল / প্যানিকেল' : (isHindi ? 'चरण 3 - फूल / पैनिकल' : 'Stage 3 — Flowering / Panicle Stage');
  String get calcTiming3 => isBengali ? '৪৫-৫০ দিন পর' : (isHindi ? '45-50 दिन बाद' : '45 to 50 days (Flower bud & grain fill)');

  // Diagnosis Detail Screen (Output Window)
  String get diagOverview => isBengali ? 'ওভারভিউ' : (isHindi ? 'अवलोकन' : 'OVERVIEW');
  String get diagTreatment => isBengali ? 'চিকিৎসা পরিকল্পনা' : (isHindi ? 'उपचार योजना' : 'TREATMENT PLAN');
  String get diagOrganic => isBengali ? 'জৈব' : (isHindi ? 'जैविक' : 'Organic');
  String get diagChemical => isBengali ? 'রাসায়নিক' : (isHindi ? 'रासायनिक' : 'Chemical');
  String get diagDisease => isBengali ? 'রোগের বিবরণ' : (isHindi ? 'रोग का विवरण' : 'DISEASE DETAILS');
  String get diagSymptoms => isBengali ? 'লক্ষণ' : (isHindi ? 'लक्षण' : 'Symptoms');
  String get diagPumpInterlock => isBengali ? 'পাম্প ইন্টারলক' : (isHindi ? 'पंप इंटरलॉक' : 'PUMP INTERLOCK');
  String get diagSprayOverride => isBengali ? 'স্প্রে ওভাররাইড সক্রিয়' : (isHindi ? 'स्प्रे ओवरराइड सक्रिय' : 'SPRAY OVERRIDE ACTIVE');

  // Calculator New Strings
  String get calcSelectCrop => isBengali ? 'লক্ষ্য ফসল নির্বাচন করুন' : (isHindi ? 'लक्ष्य फसल चुनें' : 'SELECT TARGET CROP');
  String get calcRecoveryPlan => isBengali ? 'রোগ নিরাময় পরিকল্পনা' : (isHindi ? 'रोग रिकवरी योजना' : 'Disease Recovery Plan');
  String get calcCureGuide => isBengali ? 'নিরাময় গাইড' : (isHindi ? 'इलाज गाइड' : 'CURE & RECOVERY GUIDE');
  String get calcStepPlan => isBengali ? 'ধাপে ধাপে পরিকল্পনা' : (isHindi ? 'चरण-दर-चरण योजना' : 'STEP-BY-STEP PLAN');
  String get calcAppProtocol => isBengali ? 'প্রয়োগের সময়সূচী' : (isHindi ? 'अनुप्रयोग समयरेखा' : 'FIELD APPLICATION SCHEDULE');
  String get calcSubBudget => isBengali ? 'ভর্তুকি সারের বাজেট:' : (isHindi ? 'सब्सिडी उर्वरक बजट:' : 'Subsidized Fertilizer Budget:');

  // Missing translations for Profile Settings and Health Ring
  String get profileFarmerSettings => isBengali ? 'কৃষক প্রোফাইল এবং সেটিংস' : (isHindi ? 'किसान प्रोफ़ाइल और सेटिंग्स' : 'Farmer Profile & Settings');
  String get ringSoil => isBengali ? 'মাটি' : (isHindi ? 'मिट्टी' : 'Soil');
  String get ringMoist => isBengali ? 'আর্দ্র' : (isHindi ? 'नम' : 'Moist');

  // Profile Login Strings
  String get accountLoginCredentials => isBengali ? 'অ্যাকাউন্ট লগইন শংসাপত্র' : (isHindi ? 'खाता लॉगिन क्रेडेंशियल' : 'Account login credentials');
  String get updateLocalSqlite => isBengali ? 'স্থানীয় SQLite এবং প্রোফাইল শংসাপত্র আপডেট করুন' : (isHindi ? 'स्थानीय SQLite और प्रोफ़ाइल क्रेडेंशियल अपडेट करें' : 'Update local SQLite and profile credentials');
  String get setNewPassword => isBengali ? 'কৃষক অ্যাকাউন্টের জন্য একটি নতুন সুরক্ষিত পাসওয়ার্ড সেট করুন' : (isHindi ? 'किसान खाते के लिए एक नया सुरक्षित पासवर्ड सेट करें' : 'Set a new secure password for farmer account');

  // Health Ring Statuses
  String get healthThriving => isBengali ? '🌿 সমৃদ্ধশালী এবং সুস্থ' : (isHindi ? '🌿 संपन्न और स्वस्थ' : '🌿 Thriving & Healthy');
  String get healthAttention => isBengali ? '⚠️ মনোযোগ প্রয়োজন' : (isHindi ? '⚠️ ध्यान देने की आवश्यकता है' : '⚠️ Attention Needed');

  String translate(String text) {
    if (isBengali) return bengaliTranslationMap[text] ?? text;
    if (isHindi) return hindiTranslationMap[text] ?? text;
    return text;
  }
}







