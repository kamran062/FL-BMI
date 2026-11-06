// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'بی ایم آئی کیلکولیٹر اور صحت';

  @override
  String get appTagline => 'اپنے جسم کو جانیں۔ اپنی صحت بہتر بنائیں۔';

  @override
  String get navCalculate => 'حساب';

  @override
  String get navHistory => 'ریکارڈ';

  @override
  String get navTips => 'مشورے';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get categoryUnder => 'کم وزن';

  @override
  String get categoryNormal => 'نارمل';

  @override
  String get categoryOver => 'زیادہ وزن';

  @override
  String get categoryObese => 'موٹاپا';

  @override
  String get genderFemale => 'خاتون';

  @override
  String get genderMale => 'مرد';

  @override
  String get genderOther => 'دیگر';

  @override
  String get homeTitle => 'بی ایم آئی کیلکولیٹر';

  @override
  String get homeSubtitle => 'اپنے جسم کو جانیں۔ اپنی صحت پر نظر رکھیں۔';

  @override
  String get fieldHeight => 'قد';

  @override
  String get fieldWeight => 'وزن';

  @override
  String get fieldAge => 'عمر';

  @override
  String get fieldGender => 'جنس';

  @override
  String get yearsShort => 'سال';

  @override
  String get calculateBmi => 'بی ایم آئی معلوم کریں';

  @override
  String lastResult(String date) {
    return 'آخری نتیجہ · $date';
  }

  @override
  String bmiValue(String value) {
    return 'بی ایم آئی $value';
  }

  @override
  String get errorEnterHeightWeight => 'حساب کے لیے اپنا قد اور وزن درج کریں۔';

  @override
  String get errorHeightRange => 'قد 50 سے 272 سینٹی میٹر (20 سے 107 انچ) کے درمیان درج کریں۔';

  @override
  String get errorWeightRange => 'وزن 2 سے 635 کلوگرام (5 سے 1400 پاؤنڈ) کے درمیان درج کریں۔';

  @override
  String get resultTitle => 'آپ کا نتیجہ';

  @override
  String get recommendation => 'مشورہ';

  @override
  String get healthyRange => 'صحت مند حد';

  @override
  String get saveResult => 'نتیجہ محفوظ کریں';

  @override
  String get setGoal => 'ہدف مقرر کریں';

  @override
  String get shareResult => 'نتیجہ شیئر کریں';

  @override
  String get shareTitle => 'شیئر کریں';

  @override
  String get saveImage => 'تصویر محفوظ کریں';

  @override
  String get sharing => 'شیئر ہو رہا ہے…';

  @override
  String shareText(String value) {
    return 'میرا بی ایم آئی $value ہے — بی ایم آئی کیلکولیٹر اور صحت کے ساتھ';
  }

  @override
  String get shareError => 'ابھی شیئر نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get shareCardToday => 'آج';

  @override
  String get shareCardHealthy => 'صحت مند حد میں — یہ سلسلہ جاری ہے۔';

  @override
  String get shareCardTracking => 'ہر ہفتے اپنی صحت پر نظر۔';

  @override
  String get onboardTitle1 => 'اپنی صحت آسانی سے ٹریک کریں';

  @override
  String get onboardBody1 => 'سیکنڈوں میں اپنا بی ایم آئی معلوم کریں، کسی اکاؤنٹ کی ضرورت نہیں۔';

  @override
  String get onboardTitle2 => 'سمارٹ مشورے حاصل کریں';

  @override
  String get onboardBody2 => 'آپ کے جسم اور اہداف کے مطابق ذاتی مشورے۔';

  @override
  String get onboardTitle3 => 'وقت کے ساتھ اپنی پیش رفت دیکھیں';

  @override
  String get onboardBody3 => 'ہفتہ بہ ہفتہ اپنے وزن کا سفر دیکھیں۔';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get continueLabel => 'جاری رکھیں';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get sectionAppearance => 'ظاہری شکل';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get sectionLanguage => 'زبان';

  @override
  String get appLanguage => 'ایپ کی زبان';

  @override
  String get languageSystem => 'سسٹم کے مطابق';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get sectionUnits => 'اکائیاں';

  @override
  String get sectionNotifications => 'اطلاعات';

  @override
  String get dailyReminders => 'روزانہ یاد دہانی';

  @override
  String get weeklyCheckIn => 'ہفتہ وار جائزہ';

  @override
  String get sectionAbout => 'معلومات';

  @override
  String get privacy => 'پرائیویسی';

  @override
  String get onDevice => 'صرف فون پر';

  @override
  String get adPrivacyChoices => 'اشتہارات کی پرائیویسی';

  @override
  String get version => 'ورژن';

  @override
  String get settingsFooter => 'توجہ سے بنایا گیا  ·  کوئی اکاؤنٹ درکار نہیں۔';

  @override
  String get privacyPolicy => 'پرائیویسی پالیسی';

  @override
  String get privacyDataTitle => '🔒 ڈیٹا آپ کے فون پر رہتا ہے';

  @override
  String get privacyDataBody => 'بی ایم آئی کیلکولیٹر اور صحت آپ کا سارا ڈیٹا — وزن کے ریکارڈ، اہداف اور پروفائل — آپ کے فون پر ہی SQLite میں محفوظ کرتی ہے۔ کچھ بھی کسی سرور پر نہیں بھیجا جاتا۔';

  @override
  String get privacyAnalyticsTitle => '📊 کوئی اینالیٹکس یا ٹریکنگ نہیں';

  @override
  String get privacyAnalyticsBody => 'ہم کوئی اینالیٹکس یا ٹریکنگ ٹول استعمال نہیں کرتے۔ اگر ایپ کریش ہو جائے تو ایک گمنام کریش رپورٹ (فون کا ماڈل، اینڈرائیڈ یا آئی او ایس ورژن اور تکنیکی خرابی) ہماری کریش رپورٹنگ سروس Sentry کو بھیجی جا سکتی ہے تاکہ ہم مسئلہ حل کر سکیں۔ کریش رپورٹس میں آپ کا وزن، بی ایم آئی یا صحت کا کوئی اور ڈیٹا کبھی شامل نہیں ہوتا۔';

  @override
  String get privacyAdsTitle => '📢 اشتہارات';

  @override
  String get privacyAdsBody => 'بی ایم آئی کیلکولیٹر اور صحت مفت ہے اور گوگل ایڈموب کے اشتہارات سے چلتی ہے۔ ایڈموب متعلقہ اشتہارات دکھانے کے لیے آپ کے فون کی ایڈورٹائزنگ آئی ڈی استعمال کر سکتا ہے۔ آپ کسی بھی وقت فون کی سیٹنگز میں Google → Ads → Delete advertising ID سے ذاتی نوعیت کے اشتہارات بند کر سکتے ہیں۔';

  @override
  String get privacyThirdPartyTitle => '🔗 تھرڈ پارٹی اشتہاری سروسز';

  @override
  String get privacyThirdPartyBody => 'گوگل ایڈموب اشتہارات دکھانے کے لیے فون کی کچھ معلومات (جیسے آئی پی ایڈریس، ڈیوائس آئی ڈی اور عمومی مقام) جمع کر سکتا ہے۔ یہ ڈیٹا گوگل کی پرائیویسی پالیسی کے تحت ہے۔ بی ایم آئی کیلکولیٹر اور صحت کو اس ڈیٹا تک رسائی نہیں ہے۔';

  @override
  String get privacyDeleteTitle => '🗑 اپنا ڈیٹا حذف کرنا';

  @override
  String get privacyDeleteBody => 'ایپ ان انسٹال کرنے سے آپ کا صحت کا سارا ڈیٹا فون سے مستقل طور پر حذف ہو جاتا ہے۔ کوئی کلاؤڈ بیک اپ نہیں — آپ کا ڈیٹا کبھی آپ کے فون سے باہر نہیں جاتا۔';

  @override
  String get gotIt => 'ٹھیک ہے';

  @override
  String get historyTitle => 'ریکارڈ';

  @override
  String get periodAll => 'تمام وقت';

  @override
  String get period7d => 'پچھلے 7 دن';

  @override
  String get period30d => 'پچھلے 30 دن';

  @override
  String get period3m => 'پچھلے 3 مہینے';

  @override
  String get period1y => 'پچھلا سال';

  @override
  String get categoryAll => 'تمام';

  @override
  String get clearAll => 'سب ہٹائیں';

  @override
  String get noEntriesMatch => 'آپ کے فلٹر سے کوئی اندراج نہیں ملا';

  @override
  String get clearFilters => 'فلٹر ہٹائیں';

  @override
  String entriesCount(int count) {
    return 'اندراجات  ·  $count';
  }

  @override
  String entriesCountOf(int count, int total) {
    return 'اندراجات  ·  $total میں سے $count';
  }

  @override
  String get filterEntries => 'اندراجات فلٹر کریں';

  @override
  String get timePeriod => 'مدت';

  @override
  String get bmiCategoryLabel => 'بی ایم آئی زمرہ';

  @override
  String get applyFilter => 'فلٹر لگائیں';

  @override
  String get noHistoryYet => 'ابھی کوئی ریکارڈ نہیں';

  @override
  String get noHistoryBody => 'آج سے ٹریکنگ شروع کریں — ہر اندراج آپ کا رجحان بناتا ہے۔';

  @override
  String get addFirstEntry => 'پہلا اندراج کریں';

  @override
  String get bmiTrend => 'بی ایم آئی کا رجحان';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اندراجات',
      one: '1 اندراج',
    );
    return '$_temp0';
  }

  @override
  String bmiDelta(String delta) {
    return '$delta بی ایم آئی';
  }

  @override
  String get goalTitle => 'ہدف مقرر کریں';

  @override
  String get goalCurrent => 'موجودہ';

  @override
  String get goalTarget => 'ہدف';

  @override
  String get goalTargetWeight => 'ہدف وزن';

  @override
  String get goalTimeline => 'مدت';

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ہفتے',
      one: '1 ہفتہ',
    );
    return '$_temp0';
  }

  @override
  String get goalYourPlan => 'آپ کا منصوبہ';

  @override
  String get goalMaintain => 'اپنا موجودہ وزن برقرار رکھیں';

  @override
  String goalLose(String amount, int weeks) {
    return '$weeks ہفتوں میں $amount کم کریں';
  }

  @override
  String goalGain(String amount, int weeks) {
    return '$weeks ہفتوں میں $amount بڑھائیں';
  }

  @override
  String goalRate(String value) {
    return '$value کلوگرام فی ہفتہ';
  }

  @override
  String goalPaceSafe(String rate) {
    return 'یعنی $rate — ایک محفوظ اور پائیدار رفتار۔';
  }

  @override
  String goalPaceFast(String rate) {
    return 'یعنی $rate — تجویز کردہ رفتار سے تیز۔ لمبی مدت منتخب کریں۔';
  }

  @override
  String get goalReachBy => 'ہدف کی تاریخ';

  @override
  String get goalDailyCalories => 'روزانہ کیلوریز';

  @override
  String get goalStart => 'ہدف ٹریک کرنا شروع کریں';

  @override
  String get tipsTitle => 'مشورے';

  @override
  String get tipCatDiet => 'غذا';

  @override
  String get tipCatExercise => 'ورزش';

  @override
  String get tipCatHydration => 'پانی';

  @override
  String get tipCatLifestyle => 'طرزِ زندگی';

  @override
  String tipToday(String category) {
    return 'آج · $category';
  }

  @override
  String get tip1Title => 'آدھی پلیٹ سبزیاں';

  @override
  String get tip1Body => 'ایک آسان اصول جو کیلوریز گنے بغیر زیادہ کیلوری والی غذا کو کم کر دیتا ہے۔';

  @override
  String get tip2Title => 'کافی سے پہلے پانی';

  @override
  String get tip2Body => 'رات بھر کی پانی کی کمی پوری کرنے کے لیے دن کی پہلی کافی سے پہلے 200 ملی لیٹر پانی پئیں۔';

  @override
  String get tip3Title => 'کھانے کے بعد 10 منٹ کی واک';

  @override
  String get tip3Body => 'تحقیق کے مطابق کھانے کے بعد مختصر واک خون میں شوگر کے اضافے کو نمایاں طور پر کم کرتی ہے۔';

  @override
  String get tip4Title => 'اچھی نیند سب کچھ بہتر کرتی ہے';

  @override
  String get tip4Body => '7 گھنٹے سے کم نیند اگلے دن بھوک کے ہارمون بڑھا دیتی ہے۔ سونے سے پہلے پرسکون معمول اپنائیں۔';

  @override
  String get tip5Title => 'ہر کھانے میں پہلے پروٹین';

  @override
  String get tip5Body => 'پلیٹ میں موجود پروٹین کاربوہائیڈریٹس سے پہلے کھائیں — پیٹ دیر تک بھرا رہتا ہے۔';

  @override
  String get tip6Title => 'ہفتے میں دو بار طاقت کی ورزش';

  @override
  String get tip6Body => 'ہفتے میں دو بار مزاحمتی ورزش میٹابولک صحت کو نمایاں طور پر بہتر کرتی ہے۔';

  @override
  String get tip7Title => 'کھانے کے ساتھ بھی پانی';

  @override
  String get tip7Body => 'کھانے کے دوران گھونٹ گھونٹ پانی پینا ہاضمے میں مدد دیتا ہے اور زیادہ کھانے سے بچاتا ہے۔';

  @override
  String get tip8Title => 'ذہنی دباؤ بھوک بڑھاتا ہے';

  @override
  String get tip8Body => 'کورٹیسول بڑھنے سے بھوک بڑھتی ہے۔ کھانے سے پہلے 5 منٹ گہری سانس لیں۔';

  @override
  String get adviceUnderHeadline => 'آپ کا وزن صحت مند حد سے کم ہے';

  @override
  String get adviceUnderCopy => 'کم وزن قوتِ مدافعت کمزور کر سکتا ہے، ہڈیوں کی مضبوطی کم کر سکتا ہے اور توانائی پر اثر ڈال سکتا ہے۔ مقصد آہستہ آہستہ اور معیاری طریقے سے وزن بڑھانا ہے — صرف زیادہ جنک فوڈ کھانا نہیں۔';

  @override
  String get adviceUnderStep1 => 'زیادہ کیلوری والی قدرتی غذائیں کھائیں: میوے، پینٹ بٹر، ایواکاڈو، انڈے، فل کریم دودھ، جو کا دلیہ اور براؤن چاول';

  @override
  String get adviceUnderStep2 => 'روزانہ 300–500 اضافی کیلوریز شامل کریں — اتنی کہ ہر ہفتے تقریباً 0.3–0.5 کلوگرام وزن پائیدار طریقے سے بڑھے';

  @override
  String get adviceUnderStep3 => 'روزانہ 3 بڑے کھانے اور 2–3 اسنیکس کھائیں؛ ناشتہ کبھی نہ چھوڑیں';

  @override
  String get adviceUnderStep4 => 'ہر کھانے میں پروٹین شامل کریں — پٹھے بنانے کے لیے جسمانی وزن کے ہر کلوگرام پر 1.2–1.6 گرام کا ہدف رکھیں';

  @override
  String get adviceUnderStep5 => 'ہفتے میں 2–3 بار طاقت کی ورزش کریں (اسکواٹس، پش اپس، رو) تاکہ بڑھنے والا وزن صرف چربی نہیں بلکہ پٹھے بنے';

  @override
  String get adviceUnderStep6 => 'اگر وزن بغیر وجہ یا تیزی سے کم ہو رہا ہو تو ڈاکٹر سے ملیں — یہ کسی اندرونی بیماری کی علامت ہو سکتی ہے';

  @override
  String get adviceUnderNote => 'اگر آپ کا وزن کافی عرصے سے کم ہے تو ذاتی رہنمائی کے لیے ڈاکٹر یا مستند ماہرِ غذائیت سے مشورہ کریں۔';

  @override
  String get adviceNormalHeadline => 'آپ کا وزن صحت مند حد میں ہے';

  @override
  String get adviceNormalCopy => 'صحت مند بی ایم آئی ایک بہترین بنیاد ہے۔ اب ترجیح مستقل عادات کے ذریعے اسے برقرار رکھنا ہے — جسمانی سرگرمی، معیاری غذا، نیند اور ذہنی دباؤ پر قابو سب اہم ہیں۔';

  @override
  String get adviceNormalStep1 => 'ہفتے میں 150–300 منٹ درمیانی ایروبک سرگرمی کریں: تیز چہل قدمی، سائیکلنگ یا تیراکی';

  @override
  String get adviceNormalStep2 => 'عمر کے ساتھ پٹھوں کو برقرار رکھنے کے لیے ہفتے میں 2–3 بار طاقت کی ورزش کریں';

  @override
  String get adviceNormalStep3 => 'ہر بڑے کھانے میں آدھی پلیٹ سبزیوں اور پھلوں سے بھریں';

  @override
  String get adviceNormalStep4 => 'انتہائی پراسیسڈ غذا، اضافی چینی اور الکحل کم کریں — ان میں کیلوریز زیادہ اور غذائیت کم ہوتی ہے';

  @override
  String get adviceNormalStep5 => 'رات کو 7–9 گھنٹے سوئیں؛ کم نیند گھریلن (بھوک کا ہارمون) بڑھاتی ہے اور زیادہ کھانے کا سبب بنتی ہے';

  @override
  String get adviceNormalStep6 => 'ہر 4–6 ہفتے بعد اپنا بی ایم آئی دوبارہ چیک کریں تاکہ کسی تبدیلی کا جلد پتا چل سکے';

  @override
  String get adviceNormalNote => 'بی ایم آئی صرف ابتدائی جانچ کا ذریعہ ہے، صحت کی مکمل تصویر نہیں۔ جسم کی ساخت، بلڈ پریشر اور بلڈ شوگر بھی اہم ہیں۔';

  @override
  String get adviceOverHeadline => 'آپ کا وزن صحت مند حد سے کچھ زیادہ ہے';

  @override
  String get adviceOverCopy => 'زیادہ وزن وقت کے ساتھ ٹائپ 2 ذیابیطس، ہائی بلڈ پریشر اور جوڑوں کے مسائل کا خطرہ بڑھاتا ہے۔ جسمانی وزن میں صرف 5–10% کمی بھی ان خطرات کو نمایاں طور پر کم کر دیتی ہے۔';

  @override
  String get adviceOverStep1 => 'روزانہ 300–500 کیلوریز کی معتدل کمی کریں — ہر ہفتے 0.3–0.5 کلوگرام کمی کا ہدف رکھیں (پائیدار رفتار)';

  @override
  String get adviceOverStep2 => 'روزانہ 8,000–10,000 قدم چلیں؛ 30 منٹ کی تیز واک سے شروع کریں اور آہستہ آہستہ بڑھائیں';

  @override
  String get adviceOverStep3 => 'میٹھے مشروبات (سوڈا، جوس، انرجی ڈرنکس) کی جگہ پانی، سوڈا واٹر یا بغیر چینی کی چائے پئیں';

  @override
  String get adviceOverStep4 => 'ہر کھانے میں پہلے پروٹین کھائیں — اس سے پیٹ زیادہ بھرتا ہے اور مجموعی کیلوریز کم ہوتی ہیں';

  @override
  String get adviceOverStep5 => 'دوپہر اور رات کے کھانے میں آدھی پلیٹ کم نشاستے والی سبزیوں (بروکولی، پالک، کھیرا، شملہ مرچ) سے بھریں';

  @override
  String get adviceOverStep6 => 'سونے سے 2–3 گھنٹے پہلے کھانے سے پرہیز کریں — رات دیر سے کھانا چربی جمع ہونے کا باعث بنتا ہے';

  @override
  String get adviceOverNote => 'سخت ڈائٹ الٹا نقصان دیتی ہے۔ 300–500 کیلوریز کی کمی کافی ہے — آہستہ وزن کم کرنے سے پٹھے محفوظ رہتے ہیں اور اسے برقرار رکھنا آسان ہوتا ہے۔';

  @override
  String get adviceObeseHeadline => 'آپ کا وزن موٹاپے کی حد میں ہے';

  @override
  String get adviceObeseCopy => 'موٹاپا دل کی بیماری، ٹائپ 2 ذیابیطس، نیند میں سانس رکنے (سلیپ ایپنیا) اور جوڑوں کے درد کا خطرہ بڑھاتا ہے۔ اچھی خبر یہ ہے کہ جسمانی وزن میں صرف 5–10% کمی سے بھی صحت میں نمایاں بہتری آتی ہے۔';

  @override
  String get adviceObeseStep1 => 'پہلا ہدف موجودہ وزن کا 5–10% رکھیں — 100 کلوگرام والے شخص کے لیے یہ صرف 5–10 کلوگرام ہے';

  @override
  String get adviceObeseStep2 => 'ہر ہفتے 0.5–1.0 کلوگرام کمی کا ہدف رکھیں؛ اس سے تیز کمی عموماً پٹھوں کے نقصان اور دوبارہ وزن بڑھنے کا سبب بنتی ہے';

  @override
  String get adviceObeseStep3 => 'روزانہ ہلکی پھلکی سرگرمی سے شروع کریں: 30 منٹ چہل قدمی، تیراکی یا اسٹیشنری سائیکلنگ — گھٹنوں اور جوڑوں پر کم بوجھ';

  @override
  String get adviceObeseStep4 => 'سب سے پہلے انتہائی پراسیسڈ غذا، تلی ہوئی چیزیں اور اضافی چینی ختم کریں — صرف اس سے روزانہ 500 سے زیادہ کیلوریز کم ہو سکتی ہیں';

  @override
  String get adviceObeseStep5 => 'کھانوں کی بنیاد پروٹین (مرغی، مچھلی، دالیں، انڈے) اور سبزیوں پر رکھیں؛ یہ دیر تک پیٹ بھرا رکھتی ہیں';

  @override
  String get adviceObeseStep6 => 'بنیادی معائنے کے لیے ڈاکٹر سے ملیں — بلڈ پریشر، بلڈ شوگر اور کولیسٹرول — اور منظم رہنمائی کے پروگراموں کے بارے میں پوچھیں';

  @override
  String get adviceObeseNote => 'صرف بی ایم آئی سے صحت کی تشخیص نہیں ہوتی۔ اپنی طبی تاریخ کے مطابق منصوبے کے لیے ڈاکٹر یا مستند ماہرِ غذائیت سے بات کریں۔';

  @override
  String stepOf(int current, int total) {
    return 'مرحلہ $current از $total';
  }

  @override
  String get later => 'بعد میں';

  @override
  String get back => 'پیچھے';

  @override
  String get finish => 'مکمل کریں';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get personalDetails => 'ذاتی معلومات';

  @override
  String get notSet => 'شامل نہیں';

  @override
  String get setupIntro => 'چند مختصر سوالات تاکہ ایپ ورزش اور اہداف آپ کے مطابق بنا سکے۔';

  @override
  String get setupNameTitle => 'ہم آپ کو کس نام سے پکاریں؟';

  @override
  String get setupNameHint => 'آپ کا نام (اختیاری)';

  @override
  String get setupGenderTitle => 'آپ کی جنس کیا ہے؟';

  @override
  String get setupGenderBody => 'ہم اسے کیلوریز اور جسمانی چربی کے فارمولوں کے لیے اور ورزش کی ویڈیوز میں مناسب ٹرینر دکھانے کے لیے استعمال کرتے ہیں۔ آپ اسے کسی بھی وقت بدل سکتے ہیں۔';

  @override
  String get setupFormulaTitle => 'حساب کی بنیاد';

  @override
  String get setupFormulaBody => 'کیلوریز اور جسمانی چربی کے فارمولے مرد اور خاتون کے جسم کے لیے مختلف ہوتے ہیں۔ جو آپ کے لیے بہتر ہو وہ منتخب کریں۔';

  @override
  String get bodyMale => 'مردانہ جسم';

  @override
  String get bodyFemale => 'زنانہ جسم';

  @override
  String get setupDemonstratorTitle => 'ورزش کی ویڈیوز میں';

  @override
  String get demonstratorAuto => 'میرے پروفائل کے مطابق';

  @override
  String get demonstratorMale => 'مرد ٹرینر';

  @override
  String get demonstratorFemale => 'خاتون ٹرینر';

  @override
  String get setupBodyTitle => 'آپ کے جسم کے بارے میں';

  @override
  String get setupGoalTitle => 'آپ کا بنیادی ہدف کیا ہے؟';

  @override
  String get goalLoseFat => 'چربی کم کرنا';

  @override
  String get goalLoseFatBody => 'پٹھے برقرار رکھتے ہوئے چربی کم کریں';

  @override
  String get goalBuildMuscle => 'پٹھے بنانا';

  @override
  String get goalBuildMuscleBody => 'جسم کو مضبوط اور سڈول بنائیں';

  @override
  String get goalGetStronger => 'طاقتور بننا';

  @override
  String get goalGetStrongerBody => 'قدم بہ قدم زیادہ وزن اٹھائیں';

  @override
  String get goalStayFit => 'فٹ اور صحت مند رہنا';

  @override
  String get goalStayFitBody => 'زیادہ متحرک رہیں اور بہتر محسوس کریں';

  @override
  String get setupExperienceTitle => 'ورزش کا آپ کا تجربہ کتنا ہے؟';

  @override
  String get expBeginner => 'نیا';

  @override
  String get expBeginnerBody => 'ورزش میں نئے یا لمبے وقفے کے بعد واپسی';

  @override
  String get expIntermediate => 'درمیانہ';

  @override
  String get expIntermediateBody => '6 مہینے سے زیادہ باقاعدہ ورزش';

  @override
  String get expAdvanced => 'تجربہ کار';

  @override
  String get expAdvancedBody => 'کئی سال کی مسلسل ورزش';

  @override
  String get setupEquipmentTitle => 'آپ کہاں ورزش کریں گے؟';

  @override
  String get equipGym => 'جم';

  @override
  String get equipGymBody => 'مشینوں اور فری ویٹس تک مکمل رسائی';

  @override
  String get equipHome => 'گھر پر کچھ سامان کے ساتھ';

  @override
  String get equipHomeBody => 'ڈمبل، بینڈز یا بینچ';

  @override
  String get equipNone => 'بغیر سامان';

  @override
  String get equipNoneBody => 'صرف جسمانی وزن والی ورزشیں';

  @override
  String get setupDaysTitle => 'آپ ہفتے میں کتنے دن ورزش کر سکتے ہیں؟';

  @override
  String daysPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ہفتے میں $count دن',
    );
    return '$_temp0';
  }

  @override
  String get setupDaysTip => 'زیادہ تر لوگوں کے لیے 3–4 دن بہترین آغاز ہے۔';

  @override
  String get sectionProfile => 'پروفائل';

  @override
  String get navBody => 'جسم';

  @override
  String get bodyTitle => 'جسم';

  @override
  String get logWeight => 'وزن درج کریں';

  @override
  String get weightEmpty => 'اپنا رجحان دیکھنے کے لیے باقاعدگی سے وزن درج کریں۔';

  @override
  String weightAverage(String value) {
    return '7 دن کا اوسط: $value';
  }

  @override
  String lastLogged(String date) {
    return 'آخری اندراج $date';
  }

  @override
  String get bodyFatTitle => 'جسمانی چربی (اندازہ)';

  @override
  String get bodyFatNeedsMale => 'جسمانی چربی کا اندازہ لگانے کے لیے گردن اور کمر کی پیمائش شامل کریں۔';

  @override
  String get bodyFatNeedsFemale => 'جسمانی چربی کا اندازہ لگانے کے لیے گردن، کمر اور کولہوں کی پیمائش شامل کریں۔';

  @override
  String get bodyFatMethod => 'امریکی نیوی ٹیپ طریقہ — یہ ایک اندازہ ہے، طبی پیمائش نہیں۔';

  @override
  String get measurementsTitle => 'پیمائشیں';

  @override
  String get addMeasurements => 'پیمائشیں شامل کریں';

  @override
  String get measurementsEmpty => 'کمر، کولہوں اور دیگر پیمائشوں کو ٹریک کریں تاکہ وہ تبدیلیاں نظر آئیں جو ترازو نہیں دکھاتا۔';

  @override
  String get measureNeck => 'گردن';

  @override
  String get measureChest => 'سینہ';

  @override
  String get measureBust => 'سینہ';

  @override
  String get measureWaist => 'کمر';

  @override
  String get measureHips => 'کولہے';

  @override
  String get measureArm => 'بازو';

  @override
  String get measureThigh => 'ران';

  @override
  String get measureHint => 'آرام کی حالت میں، سب سے چوڑی جگہ سے، ٹیپ کو زیادہ کسے بغیر ناپیں۔';

  @override
  String get measureRangeError => 'پیمائش 5 سے 300 سینٹی میٹر (2 سے 118 انچ) کے درمیان ہونی چاہیے۔';

  @override
  String get bmiHistory => 'بی ایم آئی ریکارڈ';

  @override
  String get viewAll => 'سب دیکھیں';

  @override
  String get noBmiYet => 'ابھی کوئی بی ایم آئی محفوظ نہیں';

  @override
  String get wellnessDisclaimer => 'صرف عمومی صحت کے لیے۔ یہ طبی مشورہ نہیں ہے۔';

  @override
  String get navTrain => 'ورزش';

  @override
  String get trainTitle => 'ورزش';

  @override
  String get startEmptyWorkout => 'خالی ورزش شروع کریں';

  @override
  String get resumeWorkout => 'ورزش جاری رکھیں';

  @override
  String workoutInProgress(String elapsed) {
    return 'ورزش جاری ہے · $elapsed';
  }

  @override
  String get exerciseLibrary => 'ورزشوں کی لائبریری';

  @override
  String get routines => 'روٹینز';

  @override
  String get routinesEmpty => 'کسی ورزش کو روٹین کے طور پر محفوظ کریں تاکہ ایک ٹیپ میں دہرا سکیں۔';

  @override
  String get recentWorkouts => 'حالیہ ورزشیں';

  @override
  String get noWorkoutsYet => 'آپ کی مکمل ورزشیں یہاں نظر آئیں گی۔';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ورزشیں',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int count) {
    return '$count منٹ';
  }

  @override
  String prCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نئے ریکارڈ',
    );
    return '$_temp0';
  }

  @override
  String volumeLabel(String value) {
    return 'حجم $value';
  }

  @override
  String get workoutDefaultName => 'ورزش';

  @override
  String get addExercise => 'ورزش شامل کریں';

  @override
  String get addSet => 'سیٹ شامل کریں';

  @override
  String get setLabel => 'سیٹ';

  @override
  String get previousLabel => 'پچھلا';

  @override
  String get repsLabel => 'ریپس';

  @override
  String get finishWorkout => 'ختم کریں';

  @override
  String get discardWorkout => 'ورزش منسوخ کریں';

  @override
  String get discardConfirm => 'یہ ورزش منسوخ کریں؟ درج سیٹس حذف ہو جائیں گے۔';

  @override
  String get discard => 'منسوخ کریں';

  @override
  String get removeExercise => 'ورزش ہٹائیں';

  @override
  String restTimer(String time) {
    return 'آرام $time';
  }

  @override
  String get skip2 => 'چھوڑیں';

  @override
  String get workoutComplete => 'ورزش مکمل';

  @override
  String newPrs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نئے ذاتی ریکارڈ!',
    );
    return '$_temp0';
  }

  @override
  String get saveAsRoutine => 'روٹین کے طور پر محفوظ کریں';

  @override
  String get routineName => 'روٹین کا نام';

  @override
  String get done => 'ہو گیا';

  @override
  String get nothingLogged => 'کوئی سیٹ مکمل نہیں ہوا، اس لیے ورزش محفوظ نہیں ہوئی۔';

  @override
  String get searchExercises => 'ورزشیں تلاش کریں';

  @override
  String get myEquipmentOnly => 'میرا سامان';

  @override
  String get allMuscles => 'تمام';

  @override
  String get howTo => 'طریقہ';

  @override
  String get videoComingSoon => 'ویڈیو جلد آ رہی ہے';

  @override
  String videoWithTrainer(String trainer) {
    return '$trainer کے ساتھ';
  }

  @override
  String get targetMuscles => 'ہدف پٹھے';

  @override
  String get muscleChest => 'سینہ';

  @override
  String get muscleBack => 'کمر';

  @override
  String get muscleShoulders => 'کندھے';

  @override
  String get muscleBiceps => 'بائسیپس';

  @override
  String get muscleTriceps => 'ٹرائیسیپس';

  @override
  String get muscleQuads => 'رانوں کے اگلے پٹھے';

  @override
  String get muscleHamstrings => 'ہیمسٹرنگز';

  @override
  String get muscleGlutes => 'کولہوں کے پٹھے';

  @override
  String get muscleCalves => 'پنڈلیاں';

  @override
  String get muscleCore => 'پیٹ اور کمر';

  @override
  String get eqBarbell => 'باربیل';

  @override
  String get eqDumbbell => 'ڈمبل';

  @override
  String get eqMachine => 'مشین';

  @override
  String get eqCable => 'کیبل';

  @override
  String get eqBodyweight => 'جسمانی وزن';

  @override
  String get eqBand => 'بینڈ';

  @override
  String get eqKettlebell => 'کیٹل بیل';

  @override
  String get navToday => 'آج';

  @override
  String get navFuel => 'غذا';

  @override
  String get fuelTitle => 'غذا';

  @override
  String get caloriesTitle => 'کیلوریز';

  @override
  String kcalOf(int eaten, int target) {
    return '$eaten / $target کیلوکیلوریز';
  }

  @override
  String kcalLeft(int count) {
    return '$count کیلوکیلوریز باقی';
  }

  @override
  String kcalOver(int count) {
    return '$count کیلوکیلوریز زیادہ';
  }

  @override
  String get macroProtein => 'پروٹین';

  @override
  String get macroCarbs => 'کاربوہائیڈریٹس';

  @override
  String get macroFat => 'چکنائی';

  @override
  String gramsOf(int eaten, int target) {
    return '$eaten / $target گرام';
  }

  @override
  String gramsTarget(int target) {
    return '$target گرام';
  }

  @override
  String get logFood => 'کھانا درج کریں';

  @override
  String get foodName => 'آپ نے کیا کھایا؟ (اختیاری)';

  @override
  String get foodKcal => 'کیلوریز (kcal)';

  @override
  String get foodProtein => 'پروٹین (گرام، اختیاری)';

  @override
  String get foodKcalError => '1 سے 5000 کے درمیان کیلوریز درج کریں۔';

  @override
  String get foodEmpty => 'آج کچھ درج نہیں ہوا۔ ہر کھانے کے بعد کیلوریز شامل کریں۔';

  @override
  String get foodUnnamed => 'کھانا';

  @override
  String get waterTitle => 'پانی';

  @override
  String waterOf(int drunk, int goal) {
    return '$drunk / $goal ملی لیٹر';
  }

  @override
  String get addGlass => '+250 ملی لیٹر';

  @override
  String get removeGlass => '−250 ملی لیٹر';

  @override
  String get targetsExplain => 'آپ کی عمر، قد، وزن، جنس، ہدف اور ورزش کے دنوں کی بنیاد پر (مفلن سینٹ جیور)۔ یہ ابتدائی رہنمائی ہے، طبی نسخہ نہیں۔';

  @override
  String get completeProfileForTargets => 'ذاتی اہداف کے لیے ذاتی معلومات میں اپنا ہدف مقرر کریں۔';

  @override
  String greeting(String name) {
    return 'السلام علیکم، $name';
  }

  @override
  String get greetingNoName => 'آج';

  @override
  String thisWeekWorkouts(int done, int target) {
    return 'اس ہفتے $target میں سے $done ورزشیں';
  }

  @override
  String get startWorkout => 'ورزش شروع کریں';

  @override
  String get latestWeight => 'تازہ ترین وزن';

  @override
  String get tipOfTheDay => 'آج کا مشورہ';

  @override
  String get moreTips => 'مزید مشورے';

  @override
  String get calculateBmiShort => 'بی ایم آئی معلوم کریں';

  @override
  String get reminderChannel => 'یاد دہانیاں';

  @override
  String get dailyReminderTitle => 'فوری جائزے کا وقت';

  @override
  String get dailyReminderBody => 'آج کا وزن، پانی اور کھانا درج کریں تاکہ آپ کا رجحان درست رہے۔';

  @override
  String get weeklyReminderTitle => 'آپ کا ہفتہ وار جائزہ';

  @override
  String get weeklyReminderBody => 'دیکھیں آپ کا ہفتہ کیسا رہا اور اگلی ورزشوں کی منصوبہ بندی کریں۔';

  @override
  String get dailyReminderAt => 'ہر روز رات 8 بجے';

  @override
  String get weeklyReminderAt => 'اتوار صبح 10 بجے';

  @override
  String get notificationsDenied => 'اس ایپ کی اطلاعات بند ہیں۔ یاد دہانیاں حاصل کرنے کے لیے فون کی ترتیبات میں انہیں آن کریں۔';

  @override
  String get stepsTitle => 'قدم';

  @override
  String stepsOf(int steps, int goal) {
    return '$steps / $goal';
  }

  @override
  String get stepsConnectBody => 'اپنے روزانہ کے قدم یہاں دیکھیں۔ قدم ہیلتھ کنیکٹ سے پڑھے جاتے ہیں اور آپ کے فون پر ہی رہتے ہیں۔';

  @override
  String get stepsConnectBodyIos => 'اپنے روزانہ کے قدم یہاں دیکھیں۔ قدم ایپل ہیلتھ سے پڑھے جاتے ہیں اور آپ کے فون پر ہی رہتے ہیں۔';

  @override
  String get connectSteps => 'جوڑیں';

  @override
  String get installHealthConnect => 'ہیلتھ کنیکٹ حاصل کریں';

  @override
  String get stepsNeedsInstall => 'قدم گننے کے لیے گوگل کی ہیلتھ کنیکٹ ایپ درکار ہے۔';

  @override
  String get activityChannel => 'سرگرمی';

  @override
  String get movementTitle => 'ٹائم لائن';

  @override
  String get movementCardTitle => 'آپ کا دن';

  @override
  String get trackingOff => 'ٹریکنگ آن کریں تاکہ دیکھ سکیں آپ کہاں گئے، کتنی دیر رہے اور کتنا چلے۔ آپ کا مقام کبھی اس فون سے باہر نہیں جاتا۔';

  @override
  String get trackingOn => 'ٹریکنگ آن ہے';

  @override
  String get startTracking => 'ٹریکنگ شروع کریں';

  @override
  String get stopTracking => 'ٹریکنگ بند کریں';

  @override
  String get trackingNotificationTitle => 'آپ کا دن ٹریک ہو رہا ہے';

  @override
  String get trackingNotificationBody => 'آپ کی نجی ٹائم لائن بن رہی ہے۔ کھولنے کے لیے ٹیپ کریں۔';

  @override
  String get locationDenied => 'مقام تک رسائی بند ہے۔ ٹائم لائن کے لیے فون کی ترتیبات میں اجازت دیں۔';

  @override
  String get locationServiceOff => 'اپنا دن ٹریک کرنے کے لیے فون کا مقام (جی پی ایس) آن کریں۔';

  @override
  String placesVisited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جگہیں',
      zero: 'ابھی کوئی جگہ نہیں',
    );
    return '$_temp0';
  }

  @override
  String distanceKm(String km) {
    return '$km کلومیٹر';
  }

  @override
  String durationHm(int hours, int minutes) {
    return '$hours گھنٹے $minutes منٹ';
  }

  @override
  String get unnamedPlace => 'بے نام جگہ';

  @override
  String get modeWalk => 'پیدل';

  @override
  String get modeRun => 'دوڑ / سائیکل';

  @override
  String get modeVehicle => 'گاڑی';

  @override
  String get namePlace => 'اس جگہ کا نام رکھیں';

  @override
  String get placeName => 'جگہ کا نام';

  @override
  String get thisIsMyGym => 'یہ میرا جم ہے';

  @override
  String get noTimelineYet => 'اس دن کی کوئی حرکت ریکارڈ نہیں ہوئی۔';

  @override
  String get deleteDay => 'یہ دن حذف کریں';

  @override
  String get deleteAllLocation => 'مقام کی پوری تاریخ حذف کریں';

  @override
  String get deleteLocationConfirm => 'یہ منتخب مقام کی تاریخ اس فون سے مستقل طور پر حذف کر دے گا۔';

  @override
  String get delete => 'حذف کریں';

  @override
  String gymTimeWeek(String time) {
    return 'اس ہفتے جم میں وقت: $time';
  }

  @override
  String get gymCheckInTitle => 'آپ جم میں ہیں 💪';

  @override
  String get gymCheckInBody => 'آج کی ورزش شروع کریں؟ لاگ کرنا شروع کرنے کے لیے ایپ کھولیں۔';

  @override
  String get trackingLimitNote => 'اگر آپ حالیہ ایپس سے ایپ بند کر دیں تو ٹریکنگ رک جاتی ہے۔';

  @override
  String get programs => 'پروگرام';

  @override
  String programDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ہفتے میں $count دن',
    );
    return '$_temp0';
  }

  @override
  String startDay(int day) {
    return 'دن $day شروع کریں';
  }

  @override
  String get recommended => 'تجویز کردہ';

  @override
  String suggestionIncrease(String weight, int reps) {
    return '$weight × $reps آزمائیں';
  }

  @override
  String suggestionAddRep(String weight, int reps) {
    return '$weight پر $reps ریپس کا ہدف';
  }

  @override
  String suggestionDeload(String weight, int reps) {
    return '$weight × $reps پر واپس آئیں';
  }

  @override
  String suggestionRepsOnly(int reps) {
    return '$reps ریپس کا ہدف';
  }

  @override
  String get muscleMapTitle => 'اس ہفتے کے پٹھے';

  @override
  String get muscleMapHint => 'ہر پٹھے کے لیے سخت سیٹس (ثانوی پٹھے آدھے شمار ہوتے ہیں)۔ ہفتے میں تقریباً 10 سیٹ پٹھے بناتے ہیں۔';

  @override
  String undertrained(String muscles) {
    return 'مزید توجہ درکار: $muscles';
  }

  @override
  String setsCount(String count) {
    return '$count سیٹ';
  }

  @override
  String get repCounter => 'ریپ کاؤنٹر';

  @override
  String get repCounterIntro => 'فون ایسے رکھیں کہ پہلو سے آپ کا پورا جسم نظر آئے، پھر ورزش شروع کریں۔';

  @override
  String get repCounterPrivacy => 'آپ کے فون پر ہی تجزیہ ہوتا ہے۔ کچھ بھی ریکارڈ یا اپ لوڈ نہیں ہوتا۔';

  @override
  String repsCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ریپس',
    );
    return '$_temp0';
  }

  @override
  String get cueGoLower => 'مزید نیچے جائیں';

  @override
  String get cueKeepHipsUp => 'کولہے اوپر رکھیں';

  @override
  String get cueFullExtension => 'پوری حرکت کریں';

  @override
  String get cueStepIntoFrame => 'فریم میں آئیں';

  @override
  String get countSquat => 'اسکواٹ';

  @override
  String get countPushUp => 'پش اپ';

  @override
  String get countCurl => 'کرل';

  @override
  String get countShoulderPress => 'شولڈر پریس';

  @override
  String get countLunge => 'لنج';

  @override
  String get resetCount => 'دوبارہ';

  @override
  String get logSet => 'سیٹ درج کریں';

  @override
  String setLogged(int count) {
    return 'سیٹ درج ہو گیا: $count ریپس';
  }

  @override
  String get cameraDenied => 'کیمرے تک رسائی بند ہے۔ ریپس گننے کے لیے فون کی ترتیبات میں اجازت دیں۔';

  @override
  String get cameraUnavailable => 'اس آلے پر کوئی کیمرا دستیاب نہیں۔';

  @override
  String get goPremium => 'پریمیم حاصل کریں';

  @override
  String get premiumActive => 'پریمیم فعال ہے';

  @override
  String get premiumBadge => 'پریمیم';

  @override
  String get premiumHeadline => 'بغیر رکاوٹ ورزش کریں';

  @override
  String get premiumBody => 'تمام اشتہارات ہٹائیں اور نئے فیچرز میں مدد کریں۔';

  @override
  String get premiumWelcome => 'پریمیم میں خوش آمدید!';

  @override
  String get premiumThanksBody => 'اشتہارات ہٹا دیے گئے۔ بی ایم آئی ہیلتھ کی مدد کا شکریہ۔';

  @override
  String get premiumFeatureNoAds => 'کوئی بینر یا فل اسکرین اشتہار نہیں';

  @override
  String get premiumFeatureSupport => 'ایک آزاد ایپ کی مدد کریں';

  @override
  String get premiumFeaturePrivacy => 'وہی پرائیویسی: آپ کا صحت کا ڈیٹا آپ کے فون پر رہتا ہے';

  @override
  String get planMonthly => 'ماہانہ';

  @override
  String get planYearly => 'سالانہ';

  @override
  String get planLifetime => 'تاحیات';

  @override
  String get planPerMonth => 'فی مہینہ';

  @override
  String planYearlyPerMonth(String price) {
    return '$price فی مہینہ، سالانہ بل';
  }

  @override
  String get planOneTime => 'ایک بار ادائیگی';

  @override
  String get bestValue => 'بہترین قیمت';

  @override
  String get restore => 'بحال کریں';

  @override
  String get processing => 'جاری ہے…';

  @override
  String get upgradeNow => 'ابھی اپ گریڈ کریں';

  @override
  String get allSet => 'سب تیار ہے!';

  @override
  String get storeUnavailable => 'اس آلے پر اسٹور دستیاب نہیں۔';

  @override
  String get pricesLoading => 'قیمتیں لوڈ ہو رہی ہیں…';

  @override
  String get renewNote => 'سبسکرپشن منسوخ کرنے تک خود بخود تجدید ہوتی ہے۔ گوگل پلے یا ایپ اسٹور کی سبسکرپشنز میں کسی بھی وقت منسوخ کریں۔ کوئی ٹریکنگ نہیں۔ کوئی ڈیٹا فروخت نہیں ہوتا۔';

  @override
  String get thanksNote => 'بی ایم آئی ہیلتھ کی مدد کا شکریہ۔';

  @override
  String get recoveryTitle => 'بحالی';

  @override
  String recoveryScore(int score) {
    return '$score / 100';
  }

  @override
  String get adviceTrainHard => 'آج سخت ورزش کے لیے اچھا دن ہے';

  @override
  String get adviceTrainLight => 'آج ہلکی ورزش کریں: آسان سیٹ یا کارڈیو';

  @override
  String get adviceRest => 'آج آرام کریں یا ہلکی چہل قدمی';

  @override
  String get limiterSleep => 'کم نیند کی وجہ سے کم';

  @override
  String get limiterRestingHr => 'آرام کی دل کی دھڑکن معمول سے زیادہ ہے';

  @override
  String get limiterHrv => 'دل کی دھڑکن کا تغیر معمول سے کم ہے';

  @override
  String get limiterLoad => 'آپ نے حال ہی میں معمول سے بہت زیادہ ورزش کی ہے';

  @override
  String get limiterSoreness => 'آپ کے پٹھوں میں درد ہے';

  @override
  String get sorenessQuestion => 'آج آپ کے پٹھوں میں کتنا درد ہے؟';

  @override
  String get sorenessScale => '1 = بالکل نہیں، 5 = بہت زیادہ';

  @override
  String get connectSleepHeart => 'نیند اور دل کا ڈیٹا جوڑیں';

  @override
  String get connectSleepHeartBody => 'اختیاری: زیادہ درست اسکور کے لیے آپ کی گھڑی یا فون سے نیند، آرام کی دل کی دھڑکن اور HRV شامل کرتا ہے۔';

  @override
  String get recoveryEmpty => 'اپنی بحالی دیکھنے کے لیے سوال کا جواب دیں یا ورزش درج کریں۔';

  @override
  String get sleepTitle => 'نیند';

  @override
  String sleepLastNight(String time) {
    return 'گزشتہ رات: $time';
  }

  @override
  String sleepAverage(String time) {
    return '7 راتوں کی اوسط: $time';
  }

  @override
  String sleepDebt(String time) {
    return 'اس ہفتے نیند کی کمی: $time';
  }

  @override
  String get sleepRegular => 'آپ کے سونے کے اوقات باقاعدہ ہیں، جو نیند کے معیار میں مدد کرتا ہے۔';

  @override
  String get sleepIrregular => 'سونے کے اوقات میں بہت فرق ہے۔ ایک مقررہ وقت عموماً نیند بہتر بناتا ہے۔';

  @override
  String get cycleTitle => 'سائیکل';

  @override
  String get cycleTracking => 'ماہواری ٹریکنگ';

  @override
  String get cycleOptInBody => 'اپنی ماہواری اور علامات ٹریک کریں اور ہر مرحلے کے لیے ورزش اور غذائیت کے مشورے حاصل کریں۔ صرف اسی فون پر محفوظ۔ آپ کسی بھی وقت سب حذف کر سکتے ہیں۔';

  @override
  String get cycleLock => 'فنگر پرنٹ یا پن سے لاک کریں';

  @override
  String get cycleUnlockReason => 'اپنا سائیکل ڈیٹا کھولیں';

  @override
  String get cycleUnlock => 'کھولیں';

  @override
  String get cycleLocked => 'سائیکل ڈیٹا لاک ہے۔';

  @override
  String get cycleDeleteAll => 'تمام سائیکل ڈیٹا حذف کریں';

  @override
  String get cycleDeleteConfirm => 'یہ تمام ماہواری اور علامات اس فون سے مستقل طور پر حذف کر دے گا اور ٹریکنگ بند کر دے گا۔';

  @override
  String cycleDay(int day) {
    return 'دن $day';
  }

  @override
  String get periodStartedToday => 'میری ماہواری آج شروع ہوئی';

  @override
  String get periodEndedToday => 'میری ماہواری آج ختم ہوئی';

  @override
  String get periodStartedOn => 'پچھلی ماہواری درج کریں';

  @override
  String nextPeriodIn(int days) {
    return 'اگلی ماہواری تقریباً $days دن میں';
  }

  @override
  String get nextPeriodToday => 'اگلی ماہواری تقریباً آج متوقع';

  @override
  String nextPeriodWindow(String from, String to) {
    return 'ممکنہ طور پر $from اور $to کے درمیان';
  }

  @override
  String get periodLate => 'آپ کی ماہواری معمول سے دیر سے ہے۔ سائیکل اکثر بدلتے ہیں؛ اگر فکر ہو تو ڈاکٹر سے بات کریں۔';

  @override
  String get cycleIrregular => 'آپ کے سائیکل کی لمبائی بدلتی رہتی ہے، اس لیے اندازے وسیع ہیں۔';

  @override
  String get cycleNoData => 'اندازے حاصل کرنے کے لیے اپنی ماہواری درج کریں۔';

  @override
  String get phaseMenstrual => 'ماہواری';

  @override
  String get phaseFollicular => 'فولیکولر مرحلہ';

  @override
  String get phaseOvulation => 'بیضہ ریزی کے قریب';

  @override
  String get phaseLuteal => 'لیوٹیل مرحلہ';

  @override
  String get tipMenstrual => 'اپنی کیفیت کے مطابق ورزش کریں: ہلکے سیشن، چہل قدمی اور اسٹریچنگ ٹھیک ہیں۔ آئرن والی غذائیں (دالیں، پالک، گوشت) کمی پوری کرتی ہیں۔';

  @override
  String get tipFollicular => 'توانائی اکثر بڑھتی ہے: بھاری وزن اور نئے ریکارڈ آزمانے کا اچھا وقت۔';

  @override
  String get tipOvulation => 'طاقت زیادہ محسوس ہو سکتی ہے۔ اچھی طرح وارم اپ کریں اور چھلانگ اور تیز موڑ پر درست انداز رکھیں۔';

  @override
  String get tipLuteal => 'آپ کو زیادہ گرمی اور بھوک لگ سکتی ہے۔ پروٹین برقرار رکھیں، پانی پیتے رہیں، اور اس مرحلے کے آخر میں زیادہ سے زیادہ کوشش کے بجائے مستقل ورزش کریں۔';

  @override
  String get cycleTipNote => 'عمومی رہنمائی؛ ہر کسی کا سائیکل مختلف محسوس ہوتا ہے۔';

  @override
  String get symptomsToday => 'آج کی علامات';

  @override
  String get symptomCramps => 'مروڑ';

  @override
  String get symptomHeadache => 'سر درد';

  @override
  String get symptomBloating => 'پیٹ پھولنا';

  @override
  String get symptomFatigue => 'تھکاوٹ';

  @override
  String get symptomLowMood => 'اداسی';

  @override
  String get symptomAcne => 'مہاسے';

  @override
  String get symptomCravings => 'کھانے کی خواہش';

  @override
  String get symptomTenderBreasts => 'چھاتی میں درد';

  @override
  String get pastPeriods => 'پچھلی ماہواریاں';

  @override
  String periodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String periodOngoing(String from) {
    return '$from – جاری';
  }

  @override
  String get scanBarcode => 'بارکوڈ اسکین کریں';

  @override
  String get scanHint => 'کیمرا پیکٹ پر بارکوڈ کی طرف کریں۔';

  @override
  String get lookingUp => 'پروڈکٹ تلاش ہو رہی ہے…';

  @override
  String get productNotFound => 'پروڈکٹ نہیں ملی۔ آپ خود درج کر سکتے ہیں۔';

  @override
  String get productNoNutrition => 'اس پروڈکٹ میں ابھی کیلوریز کی معلومات نہیں۔ آپ خود درج کر سکتے ہیں۔';

  @override
  String get lookupOffline => 'فوڈ ڈیٹا بیس سے رابطہ نہیں ہو سکا۔ کنکشن چیک کریں یا خود درج کریں۔';

  @override
  String get enterManually => 'خود درج کریں';

  @override
  String get scanAgain => 'دوبارہ اسکین کریں';

  @override
  String per100g(String kcal) {
    return '$kcal کیلوری فی 100 گرام';
  }

  @override
  String get portionGrams => 'مقدار (گرام)';

  @override
  String oneServing(String grams) {
    return '1 سرونگ ($grams گرام)';
  }

  @override
  String portionTotal(int kcal, String protein) {
    return '$kcal کیلوری · $protein گرام پروٹین';
  }

  @override
  String portionTotalKcal(int kcal) {
    return '$kcal کیلوری';
  }

  @override
  String get logThis => 'درج کریں';

  @override
  String foodLogged(String name) {
    return 'درج ہو گیا: $name';
  }

  @override
  String get offAttribution => 'پروڈکٹ ڈیٹا: اوپن فوڈ فیکٹس (ODbL)';

  @override
  String get progressPhotos => 'پیش رفت کی تصاویر';

  @override
  String get progressPhotosBody => 'نجی: اس فون پر خفیہ کردہ اور آپ کی گیلری میں کبھی شامل نہیں۔';

  @override
  String get addPhoto => 'تصویر شامل کریں';

  @override
  String get takePhoto => 'تصویر لیں';

  @override
  String get chooseFromGallery => 'گیلری سے منتخب کریں';

  @override
  String get comparePhotos => 'پہلی اور تازہ ترین کا موازنہ کریں';

  @override
  String get deletePhoto => 'تصویر حذف کریں';

  @override
  String get deletePhotoConfirm => 'یہ تصویر اس فون سے مستقل طور پر حذف کر دے گا۔';

  @override
  String photoDate(String date) {
    return '$date';
  }

  @override
  String get coachTitle => 'اے آئی کوچ';

  @override
  String get coachCardBody => 'ورزش، کھانے یا بحالی کے بارے میں پوچھیں۔';

  @override
  String get coachHint => 'سوال پوچھیں…';

  @override
  String get coachWelcome => 'السلام علیکم! میں ورزش، غذائیت، بحالی اور عادات میں مدد کر سکتا ہوں۔ میں ڈاکٹر نہیں ہوں، اس لیے طبی سوالات کے لیے کسی ماہر سے رجوع کریں۔';

  @override
  String get aiConsentTitle => 'شروع کرنے سے پہلے';

  @override
  String get aiConsentBody => 'آپ کے سوالات اور مختصر پروفائل (عمر، جنس، وزن، ہدف، تجربہ، ورزش کے دن) جوابات لکھنے کے لیے ہمارے سرور اور اینتھروپک کے کلاڈ اے آئی کو بھیجے جاتے ہیں۔ کیلوری کے اندازے کے لیے بھیجی گئی تصاویر بھی اسی طرح جاتی ہیں۔ کچھ بھی محفوظ یا اشتہارات کے لیے استعمال نہیں ہوتا۔ جوابات عمومی رہنمائی ہیں، طبی مشورہ نہیں۔';

  @override
  String get aiAgree => 'میں متفق ہوں';

  @override
  String get aiLimit => 'آج کی حد پوری ہو گئی۔ کل دوبارہ کوشش کریں۔';

  @override
  String get aiUnavailable => 'کوچ سے رابطہ نہیں ہو سکا۔ کنکشن چیک کر کے دوبارہ کوشش کریں۔';

  @override
  String get coachThinking => 'سوچ رہا ہے…';

  @override
  String get photoEstimate => 'تصویر سے اندازہ';

  @override
  String get photoEstimating => 'کیلوریز کا اندازہ ہو رہا ہے…';

  @override
  String get photoNotFood => 'یہ کھانا نہیں لگتا۔ دوسری تصویر آزمائیں۔';

  @override
  String get photoEstimateNote => 'تصویر سے اے آئی کا اندازہ — مقدار میں 20–40٪ فرق ہو سکتا ہے۔ اگر آپ بہتر جانتے ہیں تو تبدیل کریں۔';

  @override
  String get photoConfidenceLow => 'کم یقین';

  @override
  String photoTotal(int kcal) {
    return 'کل: $kcal کیلوری';
  }

  @override
  String get logSelected => 'منتخب درج کریں';

  @override
  String get estimateSuffix => '(اندازہ)';

  @override
  String get progressTitle => 'پیش رفت';

  @override
  String weekStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ہفتوں کا سلسلہ',
      zero: 'ابھی کوئی سلسلہ نہیں',
    );
    return '$_temp0';
  }

  @override
  String streakGoal(int count) {
    return 'سلسلہ جاری رکھنے کے لیے ہفتے میں $count ورزشیں کریں۔';
  }

  @override
  String badgesEarned(int earned, int total) {
    return '$total میں سے $earned بیجز';
  }

  @override
  String get thisMonth => 'اس مہینے';

  @override
  String get lastMonth => 'پچھلے مہینے';

  @override
  String recapWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ورزشیں',
    );
    return '$_temp0';
  }

  @override
  String recapSets(int count, String kg) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سیٹ · $kg کلو اٹھایا',
    );
    return '$_temp0';
  }

  @override
  String recapPrs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ذاتی ریکارڈ',
    );
    return '$_temp0';
  }

  @override
  String recapTime(String time) {
    return '$time ورزش';
  }

  @override
  String recapDistance(String km) {
    return '$km کلومیٹر حرکت';
  }

  @override
  String recapGym(String time) {
    return 'جم میں $time';
  }

  @override
  String recapWeight(String change) {
    return 'وزن $change کلو';
  }

  @override
  String get recapEmpty => 'اس مدت میں ابھی کچھ درج نہیں۔';

  @override
  String get shareRecap => 'شیئر کریں';

  @override
  String get badgesTitle => 'بیجز';

  @override
  String get badgeFirstWorkout => 'پہلی ورزش';

  @override
  String get badgeWorkouts10 => '10 ورزشیں';

  @override
  String get badgeWorkouts50 => '50 ورزشیں';

  @override
  String get badgeWorkouts100 => '100 ورزشیں';

  @override
  String get badgeStreak4 => '4 ہفتوں کا سلسلہ';

  @override
  String get badgeStreak12 => '12 ہفتوں کا سلسلہ';

  @override
  String get badgeFirstPr => 'پہلا ذاتی ریکارڈ';

  @override
  String get badgePrs10 => '10 ذاتی ریکارڈ';

  @override
  String get badgeTon => '1,000 کلو اٹھایا';

  @override
  String get badgeSteps10k => 'ایک دن میں 10,000 قدم';

  @override
  String get appName => 'بی ایم آئی ہیلتھ';

  @override
  String get sectionBackup => 'بیک اپ اور ایکسپورٹ';

  @override
  String get createBackup => 'بیک اپ بنائیں';

  @override
  String get restoreBackup => 'بیک اپ سے بحال کریں';

  @override
  String get exportCsv => 'اسپریڈشیٹ (CSV) کے طور پر ایکسپورٹ کریں';

  @override
  String get backupBody => 'آپ کا ڈیٹا کلاؤڈ بیک اپ میں نہیں جاتا۔ ایک خفیہ بیک اپ فائل بنائیں اور گوگل ڈرائیو، آئی کلاؤڈ یا کہیں بھی محفوظ کریں۔ صرف آپ کا پاس فریز اسے کھول سکتا ہے — اگر یہ گم ہو جائے تو بیک اپ بحال نہیں ہو سکتا۔';

  @override
  String get passphrase => 'پاس فریز';

  @override
  String get passphraseRepeat => 'پاس فریز دوبارہ';

  @override
  String passphraseTooShort(int count) {
    return 'کم از کم $count حروف استعمال کریں۔';
  }

  @override
  String get passphraseMismatch => 'پاس فریز مماثل نہیں۔';

  @override
  String get includeCycle => 'سائیکل ڈیٹا شامل کریں';

  @override
  String get includePhotos => 'پیش رفت کی تصاویر شامل کریں';

  @override
  String get working => 'کام جاری ہے…';

  @override
  String get restoreWarning => 'بحالی اس فون کا ڈیٹا بیک اپ کے ڈیٹا سے بدل دے گی۔ اسے واپس نہیں کیا جا سکتا۔';

  @override
  String get restoreDone => 'بیک اپ بحال ہو گیا۔';

  @override
  String get restoreWrongPassphrase => 'غلط پاس فریز، یا فائل خراب ہے۔';

  @override
  String get restoreNotBackup => 'یہ بی ایم آئی ہیلتھ کی بیک اپ فائل نہیں ہے۔';

  @override
  String get restoreNewer => 'یہ بیک اپ ایپ کے نئے ورژن کا ہے۔ پہلے ایپ اپ ڈیٹ کریں۔';

  @override
  String get csvWarning => 'اسپریڈشیٹ فائلیں خفیہ نہیں ہوتیں۔ جس کے ساتھ آپ شیئر کریں وہ انہیں پڑھ سکتا ہے۔';

  @override
  String get termsOfUse => 'شرائط استعمال';

  @override
  String get batterySaver => 'بیٹری بچت';

  @override
  String get batterySaverBody => 'کم اور کم درست مقام۔ بیٹری کم خرچ ہوتی ہے؛ مختصر چہل قدمی رہ سکتی ہے۔';

  @override
  String trackingGap(String from, String to) {
    return '$from سے $to تک ٹریکنگ رکی رہی';
  }

  @override
  String get trackingGapBody => 'غالباً آپ کے فون کے بیٹری سیور نے ایپ بند کر دی۔';

  @override
  String get keepTrackingOn => 'ٹریکنگ کیسے جاری رکھیں';

  @override
  String get keepTrackingIntro => 'اپنے فون پر بی ایم آئی ہیلتھ کو پس منظر میں چلنے دیں:';

  @override
  String get guideXiaomi => 'Xiaomi / Redmi / POCO: ترتیبات ← ایپس ← BMI Health ← بیٹری سیور ← کوئی پابندی نہیں۔ آٹو اسٹارٹ بھی آن کریں۔';

  @override
  String get guideOppo => 'Oppo / Realme / OnePlus: ترتیبات ← بیٹری ← ایپ بیٹری مینجمنٹ ← BMI Health ← پس منظر کی سرگرمی کی اجازت۔';

  @override
  String get guideVivo => 'Vivo / iQOO: ترتیبات ← بیٹری ← پس منظر بجلی کا استعمال ← BMI Health ← اجازت۔';

  @override
  String get guideSamsung => 'Samsung: ترتیبات ← ایپس ← BMI Health ← بیٹری ← بلا پابندی۔';

  @override
  String get guideHuawei => 'Huawei / Honor: ترتیبات ← بیٹری ← ایپ لانچ ← BMI Health ← دستی انتظام، سب آن۔';

  @override
  String get guideOther => 'دیگر فون: ترتیبات ← ایپس ← BMI Health ← بیٹری ← بلا پابندی۔ حالیہ ایپس سے ایپ کو سوائپ نہ کریں۔';

  @override
  String setsReps(int sets, int min, int max) {
    return '$sets سیٹ × $min–$max ریپس';
  }

  @override
  String setsSeconds(int sets, int min, int max) {
    return '$sets سیٹ × $min–$max سیکنڈ';
  }

  @override
  String restBetween(String time) {
    return 'سیٹس کے درمیان $time آرام';
  }

  @override
  String get mistakesTitle => 'عام غلطیاں';

  @override
  String get alternativesTitle => 'متبادل';

  @override
  String get muscleDayTitle => 'آج ایک پٹھے کی ورزش';

  @override
  String get dayChest => 'سینہ';

  @override
  String get dayBack => 'کمر';

  @override
  String get dayShoulders => 'کندھے';

  @override
  String get dayArms => 'بازو';

  @override
  String get dayLegs => 'ٹانگیں';

  @override
  String get dayGlutes => 'کولہے';

  @override
  String get dayCore => 'پیٹ';

  @override
  String dayWorkout(String day) {
    return '$day کی ورزش';
  }

  @override
  String planSummary(int count, int sets, int minutes) {
    return '$count ورزشیں · $sets سیٹ · تقریباً $minutes منٹ';
  }

  @override
  String get jointFriendlyNote => 'آپ کے بی ایم آئی کے مطابق جوڑوں کے لیے آسان انتخاب: کودنے والی ورزشیں شامل نہیں۔';

  @override
  String get planBasedOn => 'آپ کے سامان اور تجربے کے مطابق۔ طریقہ اور مشوروں کے لیے ورزش پر ٹیپ کریں۔';

  @override
  String get startThisWorkout => 'یہ ورزش شروع کریں';

  @override
  String get noExercisesForDay => 'اس دن کے لیے ابھی آپ کے سامان کے مطابق کوئی ورزش نہیں۔';

  @override
  String get homeChallenges => 'گھریلو چیلنجز';

  @override
  String get homeChallengesBody => 'بغیر سامان کے روزانہ کے منصوبے۔ سطح اور توجہ منتخب کریں۔';

  @override
  String get levelBeginner => 'ابتدائی';

  @override
  String get levelIntermediate => 'درمیانہ';

  @override
  String get levelAdvanced => 'ماہر';

  @override
  String levelLocked(String level) {
    return 'کھولنے کے لیے اس توجہ میں $level مکمل کریں';
  }

  @override
  String get focusFullBody => 'پورا جسم';

  @override
  String get focusUpperBody => 'سینہ اور اوپری جسم';

  @override
  String get focusCoreAbs => 'پیٹ اور ایبز';

  @override
  String get focusLegsGlutes => 'ٹانگیں اور کولہے';

  @override
  String get focusHiit => 'ہٹ اور چربی جلانا';

  @override
  String get focusStretch => 'اسٹریچ اور لچک';

  @override
  String challengeLength(int days, int minutes) {
    return '$days دن · روزانہ $minutes منٹ';
  }

  @override
  String challengeProgress(int day, int total) {
    return '$total میں سے دن $day';
  }

  @override
  String get challengeDone => 'مکمل!';

  @override
  String get restDay => 'آرام کا دن';

  @override
  String get restDayBody => 'بحالی بھی ورزش کا حصہ ہے۔ چہل قدمی کریں یا ہلکا اسٹریچ کریں۔';

  @override
  String get markRested => 'آرام مکمل کریں';

  @override
  String get todayPlan => 'آج کا منصوبہ';

  @override
  String get warmUp => 'وارم اپ';

  @override
  String get coolDown => 'کول ڈاؤن';

  @override
  String repsTarget(int count) {
    return '$count ریپس';
  }

  @override
  String secondsTarget(int count) {
    return '$count سیکنڈ';
  }

  @override
  String setOfTotal(int set, int total) {
    return 'سیٹ $set از $total';
  }

  @override
  String get doneSet => 'ہو گیا';

  @override
  String get restNow => 'آرام';

  @override
  String nextUp(String name) {
    return 'اگلا: $name';
  }

  @override
  String get addTwenty => '+20 سیکنڈ';

  @override
  String get skipRest => 'آرام چھوڑیں';

  @override
  String get skipExercise => 'ورزش چھوڑیں';

  @override
  String get pause => 'روکیں';

  @override
  String get resume => 'جاری رکھیں';

  @override
  String get howTo2 => 'کیسے کریں';

  @override
  String get quitWorkoutTitle => 'یہ ورزش چھوڑ دیں؟';

  @override
  String get quitWorkoutBody => 'آج کی پیش رفت محفوظ نہیں ہوگی۔';

  @override
  String get quit => 'چھوڑ دیں';

  @override
  String dayComplete(int day) {
    return 'دن $day مکمل!';
  }

  @override
  String dayCompleteBody(int minutes, int sets) {
    return '$minutes منٹ · $sets سیٹ۔ بہت خوب، کل ملتے ہیں۔';
  }

  @override
  String challengeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دن کا سلسلہ',
    );
    return '$_temp0';
  }

  @override
  String get finishActiveFirst => 'پہلے موجودہ ورزش مکمل یا ختم کریں۔';

  @override
  String get restartChallenge => 'چیلنج دوبارہ شروع کریں';

  @override
  String continueChallenge(String name) {
    return 'جاری رکھیں: $name';
  }

  @override
  String get voiceCoach => 'آواز کوچ';

  @override
  String sayExerciseReps(String name, int count) {
    return '$name۔ $count ریپس۔';
  }

  @override
  String sayExerciseSeconds(String name, int count) {
    return '$name۔ $count سیکنڈ۔ شروع!';
  }

  @override
  String saySetOf(int set, int total) {
    return 'سیٹ $set از $total۔';
  }

  @override
  String get sayHalfway => 'آدھا ہو گیا۔';

  @override
  String sayRest(int count, String name) {
    return '$count سیکنڈ آرام۔ اگلا: $name۔';
  }

  @override
  String get sayGetReady => 'تیار ہو جائیں۔';

  @override
  String sayDayComplete(int day) {
    return 'دن $day مکمل۔ شاباش!';
  }
}
