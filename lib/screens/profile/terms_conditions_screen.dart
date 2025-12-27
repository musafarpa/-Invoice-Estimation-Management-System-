import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Directionality(
      textDirection: langProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        langProvider.termsConditions,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          langProvider.isArabic ? '1. القبول' : '1. Acceptance',
                          langProvider.isArabic
                              ? 'باستخدام هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام التطبيق.'
                              : 'By using this application, you agree to be bound by these terms and conditions. If you do not agree to these terms, please do not use the application.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? '2. استخدام الخدمة' : '2. Use of Service',
                          langProvider.isArabic
                              ? 'يُسمح لك باستخدام هذا التطبيق لإدارة الفواتير والتقديرات الخاصة بك. يجب عدم استخدام التطبيق لأي غرض غير قانوني.'
                              : 'You are permitted to use this application to manage your invoices and estimations. You must not use the application for any unlawful purpose.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? '3. حساب المستخدم' : '3. User Account',
                          langProvider.isArabic
                              ? 'أنت مسؤول عن الحفاظ على سرية معلومات حسابك وكلمة المرور. أنت مسؤول عن جميع الأنشطة التي تحدث تحت حسابك.'
                              : 'You are responsible for maintaining the confidentiality of your account information and password. You are responsible for all activities that occur under your account.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? '4. الملكية الفكرية' : '4. Intellectual Property',
                          langProvider.isArabic
                              ? 'جميع المحتويات والمواد المتاحة في هذا التطبيق محمية بموجب قوانين حقوق الطبع والنشر والعلامات التجارية.'
                              : 'All content and materials available in this application are protected by copyright and trademark laws.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? '5. تحديد المسؤولية' : '5. Limitation of Liability',
                          langProvider.isArabic
                              ? 'لن نكون مسؤولين عن أي أضرار مباشرة أو غير مباشرة أو عرضية أو خاصة أو تبعية ناتجة عن استخدامك للتطبيق.'
                              : 'We shall not be liable for any direct, indirect, incidental, special, or consequential damages resulting from your use of the application.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? '6. التعديلات' : '6. Modifications',
                          langProvider.isArabic
                              ? 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم نشر التعديلات على هذه الصفحة.'
                              : 'We reserve the right to modify these terms at any time. Modifications will be posted on this page.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? '7. القانون الحاكم' : '7. Governing Law',
                          langProvider.isArabic
                              ? 'تخضع هذه الشروط وتُفسر وفقًا للقوانين المعمول بها.'
                              : 'These terms shall be governed by and construed in accordance with applicable laws.',
                        ),
                        const SizedBox(height: 20),
                        Text(
                          langProvider.isArabic
                              ? 'آخر تحديث: ديسمبر 2024'
                              : 'Last updated: December 2024',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
