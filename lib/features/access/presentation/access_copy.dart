import '../../../core/localization/app_copy.dart';
import '../domain/access_flow.dart';

class AccessCopy {
  const AccessCopy(this.language);
  final AppLanguage language;
  bool get ar => language == AppLanguage.arabic;

  String get welcome =>
      ar ? 'مرحباً بك في إندكس لوجيستكس' : 'Welcome to Index Logistics';
  String get welcomeBody => ar
      ? 'شبكة أعمال للتجارة الدولية والخدمات اللوجستية.'
      : 'A business network for international trade and logistics.';
  String get continueGuest => ar ? 'المتابعة كزائر' : 'Continue as guest';
  String get guestNote => ar
      ? 'يمكنك تصفح الرئيسية والاكتشاف دون إنشاء حساب.'
      : 'Browse Home and Discover without creating an account.';
  String get accessPreview =>
      ar ? 'معاينة واجهات الحساب' : 'Account UI preview';
  String get signIn => ar ? 'تسجيل الدخول' : 'Sign in';
  String get signUp => ar ? 'إنشاء حساب' : 'Create account';
  String get forgot => ar ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  String get email => ar ? 'البريد الإلكتروني' : 'Email address';
  String get password => ar ? 'كلمة المرور' : 'Password';
  String get fullName => ar ? 'الاسم الكامل' : 'Full name';
  String get company => ar ? 'اسم الشركة (اختياري)' : 'Company name (optional)';
  String get continueLabel => ar ? 'متابعة المعاينة' : 'Continue preview';
  String get verification => ar ? 'التحقق من البريد' : 'Email verification';
  String get verificationBody => ar
      ? 'هذه معاينة فقط. لم يتم إرسال رمز تحقق ولن يتم التحقق من أي حساب.'
      : 'Preview only. No verification code is sent and no account is verified.';
  String get accountType => ar ? 'نوع الحساب' : 'Account type';
  String get importer => ar ? 'مستورد' : 'Importer';
  String get exporter => ar ? 'مصدر' : 'Exporter';
  String get serviceProvider => ar ? 'مقدم خدمات' : 'Service provider';
  String get profileSetup => ar ? 'إعداد الملف الشخصي' : 'Profile setup';
  String get profileBody => ar
      ? 'أدخل بيانات للمعاينة المحلية فقط. لن يتم حفظها أو إرسالها.'
      : 'Enter details for this local preview only. They will not be stored or sent.';
  String get profilePreview => ar
      ? 'انتهت معاينة الواجهة. لم يتم إنشاء حساب أو حفظ بيانات.'
      : 'UI preview complete. No account was created and no data was saved.';
  String get signInUnavailable => ar
      ? 'واجهة الدخول للمعاينة فقط؛ لا توجد خدمة حسابات متصلة.'
      : 'Sign-in is a UI preview; no account service is connected.';
  String get recoveryUnavailable => ar
      ? 'معاينة فقط: لم يتم إرسال رسالة استعادة.'
      : 'Preview only: no recovery message was sent.';
  String get localOnly => ar ? 'واجهة توضيحية محلية' : 'Local UI preview';
  String get languageLabel => ar ? 'English' : 'العربية';
  String get required => ar ? 'هذا الحقل مطلوب' : 'This field is required';
  String get invalidEmail =>
      ar ? 'أدخل بريداً إلكترونياً صحيحاً' : 'Enter a valid email address';
  String get shortPassword =>
      ar ? 'استخدم 8 أحرف على الأقل' : 'Use at least 8 characters';

  String notice(AccessNotice notice) => switch (notice) {
    AccessNotice.none => '',
    AccessNotice.signInUnavailable => signInUnavailable,
    AccessNotice.recoveryUnavailable => recoveryUnavailable,
    AccessNotice.verificationPreview => verificationBody,
    AccessNotice.profilePreview => profilePreview,
  };

  String accountTypeLabel(AccountType type) => switch (type) {
    AccountType.importer => importer,
    AccountType.exporter => exporter,
    AccountType.serviceProvider => serviceProvider,
  };
}
