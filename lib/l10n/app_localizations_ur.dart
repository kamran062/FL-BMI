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
  String get continueLabel => 'آگے بڑھیں';

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
  String get tipsTitle => 'روزانہ مشورے';

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
}
