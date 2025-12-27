import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
                    Text(
                      langProvider.helpSupport,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FAQ Section
                      Text(
                        langProvider.isArabic
                            ? 'الأسئلة الشائعة'
                            : 'Frequently Asked Questions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFAQItem(
                        context,
                        langProvider.isArabic
                            ? 'كيف أقوم بإنشاء فاتورة جديدة؟'
                            : 'How do I create a new invoice?',
                        langProvider.isArabic
                            ? 'انتقل إلى علامة التبويب "الفواتير" واضغط على زر "+" في الزاوية العلوية. املأ تفاصيل العميل وأضف العناصر وحدد تاريخ الاستحقاق.'
                            : 'Go to the "Invoices" tab and tap the "+" button in the top corner. Fill in the client details, add items, and set the due date.',
                      ),
                      _buildFAQItem(
                        context,
                        langProvider.isArabic
                            ? 'كيف أحول تقدير إلى فاتورة؟'
                            : 'How do I convert an estimation to an invoice?',
                        langProvider.isArabic
                            ? 'افتح التقدير واضغط على قائمة الخيارات (⋮) ثم اختر "تحويل إلى فاتورة". سيتم إنشاء فاتورة جديدة بنفس التفاصيل.'
                            : 'Open the estimation and tap the options menu (⋮), then select "Convert to Invoice". A new invoice will be created with the same details.',
                      ),
                      _buildFAQItem(
                        context,
                        langProvider.isArabic
                            ? 'كيف أغير اللغة؟'
                            : 'How do I change the language?',
                        langProvider.isArabic
                            ? 'انتقل إلى الملف الشخصي > الإعدادات > اللغة واختر اللغة المفضلة لديك (الإنجليزية أو العربية).'
                            : 'Go to Profile > Settings > Language and select your preferred language (English or Arabic).',
                      ),
                      _buildFAQItem(
                        context,
                        langProvider.isArabic
                            ? 'كيف أضيف مستخدمين جدد؟'
                            : 'How do I add new users?',
                        langProvider.isArabic
                            ? 'يمكن للمسؤولين فقط إضافة مستخدمين جدد. انتقل إلى الصفحة الرئيسية > إدارة المستخدمين واضغط على زر "+".'
                            : 'Only administrators can add new users. Go to Home > User Management and tap the "+" button.',
                      ),
                      const SizedBox(height: 32),

                      // Contact Support
                      Text(
                        langProvider.isArabic
                            ? 'تواصل معنا'
                            : 'Contact Support',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        context,
                        Icons.email_outlined,
                        langProvider.isArabic ? 'البريد الإلكتروني' : 'Email',
                        'support@invoiceapp.com',
                        langProvider.isArabic
                            ? 'أرسل لنا بريدًا إلكترونيًا وسنرد خلال 24 ساعة'
                            : 'Send us an email and we\'ll respond within 24 hours',
                      ),
                      const SizedBox(height: 12),
                      _buildContactCard(
                        context,
                        Icons.chat_outlined,
                        langProvider.isArabic ? 'الدردشة المباشرة' : 'Live Chat',
                        langProvider.isArabic ? 'ابدأ محادثة' : 'Start a conversation',
                        langProvider.isArabic
                            ? 'متاح من 9 صباحًا إلى 6 مساءً'
                            : 'Available 9 AM - 6 PM',
                      ),
                      const SizedBox(height: 12),
                      _buildContactCard(
                        context,
                        Icons.phone_outlined,
                        langProvider.isArabic ? 'الهاتف' : 'Phone',
                        '+1 234 567 8900',
                        langProvider.isArabic
                            ? 'متاح من 9 صباحًا إلى 6 مساءً'
                            : 'Available 9 AM - 6 PM',
                      ),
                      const SizedBox(height: 32),

                      // Send Feedback
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F959),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.feedback_outlined,
                              size: 40,
                              color: const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              langProvider.isArabic
                                  ? 'هل لديك اقتراحات؟'
                                  : 'Have suggestions?',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              langProvider.isArabic
                                  ? 'نحن نحب أن نسمع ملاحظاتك لتحسين التطبيق'
                                  : 'We\'d love to hear your feedback to improve the app',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showFeedbackDialog(context, langProvider);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  langProvider.isArabic
                                      ? 'إرسال ملاحظات'
                                      : 'Send Feedback',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, LanguageProvider langProvider) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          langProvider.isArabic ? 'إرسال ملاحظات' : 'Send Feedback',
        ),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: langProvider.isArabic
                ? 'اكتب ملاحظاتك هنا...'
                : 'Write your feedback here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(langProvider.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    langProvider.isArabic
                        ? 'شكرًا على ملاحظاتك!'
                        : 'Thank you for your feedback!',
                  ),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              langProvider.isArabic ? 'إرسال' : 'Send',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
