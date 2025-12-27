import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                        langProvider.privacyPolicy,
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
                          langProvider.isArabic ? 'جمع المعلومات' : 'Information Collection',
                          langProvider.isArabic
                              ? 'نقوم بجمع المعلومات التي تقدمها مباشرة لنا، مثل اسمك وعنوان بريدك الإلكتروني ومعلومات الفواتير.'
                              : 'We collect information you provide directly to us, such as your name, email address, and billing information.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? 'استخدام المعلومات' : 'Use of Information',
                          langProvider.isArabic
                              ? 'نستخدم المعلومات التي نجمعها لتوفير وصيانة وتحسين خدماتنا، ومعالجة المعاملات، وإرسال المعلومات ذات الصلة.'
                              : 'We use the information we collect to provide, maintain, and improve our services, process transactions, and send relevant information.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? 'مشاركة المعلومات' : 'Information Sharing',
                          langProvider.isArabic
                              ? 'لا نشارك معلوماتك الشخصية مع أطراف ثالثة إلا عند الضرورة لتقديم خدماتنا أو عندما يقتضي القانون ذلك.'
                              : 'We do not share your personal information with third parties except when necessary to provide our services or when required by law.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? 'أمن البيانات' : 'Data Security',
                          langProvider.isArabic
                              ? 'نتخذ تدابير معقولة للمساعدة في حماية معلوماتك الشخصية من الفقدان أو السرقة أو سوء الاستخدام.'
                              : 'We take reasonable measures to help protect your personal information from loss, theft, or misuse.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? 'ملفات تعريف الارتباط' : 'Cookies',
                          langProvider.isArabic
                              ? 'قد نستخدم ملفات تعريف الارتباط والتقنيات المماثلة لجمع المعلومات حول تفاعلاتك مع تطبيقنا.'
                              : 'We may use cookies and similar technologies to collect information about your interactions with our application.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? 'حقوقك' : 'Your Rights',
                          langProvider.isArabic
                              ? 'لديك الحق في الوصول إلى معلوماتك الشخصية وتصحيحها وحذفها. يمكنك أيضًا إلغاء الاشتراك في الاتصالات التسويقية.'
                              : 'You have the right to access, correct, and delete your personal information. You can also opt out of marketing communications.',
                        ),
                        _buildSection(
                          langProvider.isArabic ? 'اتصل بنا' : 'Contact Us',
                          langProvider.isArabic
                              ? 'إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يرجى الاتصال بنا على support@invoiceapp.com'
                              : 'If you have any questions about this Privacy Policy, please contact us at support@invoiceapp.com',
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
