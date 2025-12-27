import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isArabic = false;

  Locale get locale => _locale;
  bool get isArabic => _isArabic;
  bool get isRTL => _isArabic;

  void toggleLanguage() {
    if (_isArabic) {
      _locale = const Locale('en');
      _isArabic = false;
    } else {
      _locale = const Locale('ar');
      _isArabic = true;
    }
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    _isArabic = languageCode == 'ar';
    notifyListeners();
  }

  // Localized strings
  String get appName => _isArabic ? 'الفواتير والتقديرات' : 'Invoice & Estimation';
  String get profile => _isArabic ? 'الملف الشخصي' : 'Profile';
  String get editProfile => _isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile';
  String get language => _isArabic ? 'اللغة' : 'Language';
  String get english => _isArabic ? 'الإنجليزية' : 'English';
  String get arabic => _isArabic ? 'العربية' : 'Arabic';
  String get termsConditions => _isArabic ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get privacyPolicy => _isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get aboutUs => _isArabic ? 'معلومات عنا' : 'About Us';
  String get helpSupport => _isArabic ? 'المساعدة والدعم' : 'Help & Support';
  String get rateApp => _isArabic ? 'قيم التطبيق' : 'Rate App';
  String get shareApp => _isArabic ? 'شارك التطبيق' : 'Share App';
  String get logout => _isArabic ? 'تسجيل الخروج' : 'Logout';
  String get settings => _isArabic ? 'الإعدادات' : 'Settings';
  String get notifications => _isArabic ? 'الإشعارات' : 'Notifications';
  String get darkMode => _isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get version => _isArabic ? 'الإصدار' : 'Version';
  String get name => _isArabic ? 'الاسم' : 'Name';
  String get email => _isArabic ? 'البريد الإلكتروني' : 'Email';
  String get phone => _isArabic ? 'الهاتف' : 'Phone';
  String get save => _isArabic ? 'حفظ' : 'Save';
  String get cancel => _isArabic ? 'إلغاء' : 'Cancel';
  String get home => _isArabic ? 'الرئيسية' : 'Home';
  String get estimations => _isArabic ? 'التقديرات' : 'Estimations';
  String get invoices => _isArabic ? 'الفواتير' : 'Invoices';
}
