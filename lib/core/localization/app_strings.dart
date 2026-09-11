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
  String get offlineTag => isBengali ? '১০০% অফলাইন' : (isHindi ? '१००% ऑफलाइन' : '100% OFFLINE');

  // Home Screen
  String get greetingFarmer => getGreetingFarmer();
  String get greetingSubtitle => getGreetingSubtitle();

  String getGreetingFarmer([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 12) {
      return isBengali ? 'শুভ সকাল' : (isHindi ? 'सुप्रभात' : 'Good Morning');
      String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
} else if (hour >= 12 && hour < 17) {
      return isBengali ? 'শুভ অপরাহ্ন' : (isHindi ? 'शुभ दोपहर' : 'Good Afternoon');
      String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
} else if (hour >= 17 && hour < 20) {
      return isBengali ? 'শুভ সন্ধ্যা' : (isHindi ? 'शुभ संध्या' : 'Good Evening');
      String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
} else {
      return isBengali ? 'শুভ রাত্রি' : (isHindi ? 'शुभ रात्रि' : 'Good Night');
      String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
}
    String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
}

  String getGreetingSubtitle() {
    return isBengali 
        ? 'আপনার খামার সেন্সর আজ সুস্থ আছে।' 
        : (isHindi ? 'आज आपके खेत के सेंसर स्वस्थ हैं।' : 'Your farm sensors are healthy today.');
    String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
}

  String get latestAdviceTitle => isBengali ? 'সর্বশেষ পরামর্শ' : (isHindi ? 'नवीनतम सलाह' : 'Latest Advice');
  String get quickActions => isBengali ? 'দ্রুত পদক্ষেপ' : (isHindi ? 'त्वरित कार्रवाई' : 'QUICK ACTIONS');
  String get connectDevice => isBengali ? 'ডিভাইস সংযুক্ত করুন' : (isHindi ? 'डिवाइस कनेक्ट करें' : 'Connect Device');
  String get viewPrescription => isBengali ? 'প্রেসক্রিপশন দেখুন' : (isHindi ? 'नुस्खा देखें' : 'View Prescription');
  
  String get telemetryData => isBengali ? 'টেলিমেট্রি ডেটা' : (isHindi ? 'टेलीमेट्री डेटा' : 'Telemetry Data');
  String get scanLeaf => isBengali ? 'পাতা স্ক্যান করুন' : (isHindi ? 'पत्ता स्कैन करें' : 'Scan Leaf');

  String get rainDetected => isBengali ? 'বৃষ্টি হচ্ছে' : (isHindi ? 'बारिश सक्रिय' : 'Rain Active');
  String get noRain => isBengali ? 'শুষ্ক অবস্থা' : (isHindi ? 'शुष्क स्थिति' : 'Dry Conditions');
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
  String get appearanceTheme => isBengali ? 'চেহারা এবং থিম' : (isHindi ? 'रूप-रंग और थीम' : 'APPEARANCE & THEME');
  String get darkMode => isBengali ? 'ডার্ক মোড' : (isHindi ? 'डार्क मोड' : 'Dark Mode');
  String get lightMode => isBengali ? 'অর্গানিক লাইট মোড' : (isHindi ? 'ऑर्गेनिक लाइट मोड' : 'Organic Light Mode');
  String get safetyNetTitle => isBengali ? 'হার্ডওয়্যার বাইপাস // পিচ সেফটি নেট' : (isHindi ? 'हार्डवेयर बाईपास // पिच सेफ्टी नेट' : 'HARDWARE BYPASS // PITCH SAFETY NET');
  String get securitySettings => isBengali ? 'নিরাপত্তা এবং পরিচয়পত্র' : (isHindi ? 'सुरक्षा और क्रेडेंशियल' : 'SECURITY & CREDENTIALS');
  String get changePassword => isBengali ? 'পাসওয়ার্ড পরিবর্তন করুন' : (isHindi ? 'पासवर्ड बदलें' : 'Change Password');
  String get currentPassword => isBengali ? 'বর্তমান পাসওয়ার্ড' : (isHindi ? 'वर्तमान पासवर्ड' : 'Current Password');
  String get newPassword => isBengali ? 'নতুন পাসওয়ার্ড' : (isHindi ? 'नया पासवर्ड' : 'New Password');
  String get confirmNewPassword => isBengali ? 'নতুন পাসওয়ার্ড নিশ্চিত করুন' : (isHindi ? 'नया पासवर्ड जांचें' : 'Confirm New Password');
  String get updatePasswordBtn => isBengali ? 'পাসওয়ার্ড আপডেট করুন' : (isHindi ? 'पासवर्ड अपडेट करें' : 'UPDATE PASSWORD');

  // Missing Dashboard Strings
  String get cockpitTitle => isBengali ? 'ডেটা এবং বৃদ্ধি // ককপিট' : (isHindi ? 'डेटा और विकास // कॉकपिट' : 'DATA MEETS GROWTH // COCKPIT');
  String get interactive => isBengali ? 'ইন্টারেক্টিভ' : (isHindi ? 'इंटरएक्टिव' : 'INTERACTIVE');
  String get cockpitDesc => isBengali ? 'অ্যানিমেটেড মাটির আর্দ্রতা গ্রাফ এবং জলবায়ু গেজ।' : (isHindi ? 'एनिमेटेड मिट्टी की नमी ग्राफ और जलवायु गेज।' : 'Interactive animated Soil Wave area graphs, ClimateIQ 180A rainbow arc gauge.');
  String get openCockpit => isBengali ? 'ককপিট খুলুন' : (isHindi ? 'कॉकपिट खोलें' : 'Open Cockpit & Research Hub');
  String get weatherAlert => isBengali ? 'আবহাওয়া সতর্কতা' : (isHindi ? 'मौसम चेतावनी' : 'WEATHER ALERT');
  String get optimalCycle => isBengali ? 'সর্বোত্তম চক্র' : (isHindi ? 'इष्टतम चक्र' : 'OPTIMAL CYCLE');
  String get cropScore => isBengali ? 'ফসল স্কোর' : (isHindi ? 'फसल स्कोर' : 'CROP SCORE');
  String get overallHealth => isBengali ? 'সার্বিক খামার স্বাস্থ্য সূচক' : (isHindi ? 'समग्र खेत स्वास्थ्य सूचकांक' : 'Overall Farm Health Index');
  String get safetyNetSub => isBengali ? 'অফলাইন রোগ নির্ণয় পরীক্ষার জন্য উচ্চ-মানের পাতার ছবি লোড করুন।' : (isHindi ? 'ऑफ़लाइन रोग निदान परीक्षण के लिए उच्च-गुणवत्ता वाली पत्ती की छवियां लोड करें।' : 'Instantly inject high-res leaf assets to test offline neural diagnosis without requiring live ESP32 camera Wi-Fi.');

  // More misses
  String get cropDiagnostics => isBengali ? 'ফসল নির্ণয়' : (isHindi ? 'फसल निदान' : 'CROP DIAGNOSTICS');
  String get cropDiagSubtitle => isBengali ? 'এআই ভিত্তিক রোগ বিশ্লেষণ' : (isHindi ? 'एआई आधारित रोग विश्लेषण' : 'AI-Powered Disease Analysis');
  String get confidence => isBengali ? 'নিশ্চিত' : (isHindi ? 'आत्मविश्वास' : 'Confidence');
  String get sensorTelemetry => isBengali ? 'সেন্সর টেলিমেট্রি' : (isHindi ? 'सेंसर टेलीमेट्री' : 'SENSOR TELEMETRY');
  String get smartIrrigation => isBengali ? 'স্মার্ট সেচ' : (isHindi ? 'स्मार्ट सिंचाई' : 'SMART IRRIGATION');
  String get captureLeaf => isBengali ? 'পাতা স্ক্যান করুন' : (isHindi ? 'पत्ता स्कैन करें' : 'CAPTURE LEAF');
  String get todaysActionPlan => isBengali ? 'আজকের কর্মপরিকল্পনা' : (isHindi ? 'आज की कार्ययोजना' : 'Today\'s Action Plan');
}
