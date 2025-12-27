import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                      langProvider.aboutUs,
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
                    children: [
                      const SizedBox(height: 20),
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F959),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8F959).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 60,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        langProvider.isArabic
                            ? 'الفواتير والتقديرات'
                            : 'Invoice & Estimation',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        langProvider.isArabic ? 'الإصدار 1.0.0' : 'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // About Content
                      Container(
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
                            Text(
                              langProvider.isArabic
                                  ? 'نظام إدارة الفواتير والتقديرات هو حل شامل لإدارة فواتيرك وتقديراتك بكفاءة. يوفر التطبيق واجهة سهلة الاستخدام مع ميزات قوية لتبسيط عملياتك المالية.'
                                  : 'Invoice & Estimation Management System is a comprehensive solution for efficiently managing your invoices and estimations. The app provides an easy-to-use interface with powerful features to streamline your financial operations.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              langProvider.isArabic ? 'الميزات الرئيسية:' : 'Key Features:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              langProvider.isArabic
                                  ? 'إنشاء وإدارة الفواتير'
                                  : 'Create and manage invoices',
                            ),
                            _buildFeatureItem(
                              langProvider.isArabic
                                  ? 'إنشاء وإدارة التقديرات'
                                  : 'Create and manage estimations',
                            ),
                            _buildFeatureItem(
                              langProvider.isArabic
                                  ? 'تحويل التقديرات إلى فواتير'
                                  : 'Convert estimations to invoices',
                            ),
                            _buildFeatureItem(
                              langProvider.isArabic
                                  ? 'إدارة المستخدمين'
                                  : 'User management',
                            ),
                            _buildFeatureItem(
                              langProvider.isArabic
                                  ? 'دعم متعدد اللغات'
                                  : 'Multi-language support',
                            ),
                            _buildFeatureItem(
                              langProvider.isArabic
                                  ? 'واجهة مستخدم حديثة'
                                  : 'Modern user interface',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Info
                      Container(
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
                            Text(
                              langProvider.isArabic ? 'اتصل بنا' : 'Contact Us',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContactItem(
                              Icons.email_outlined,
                              'support@invoiceapp.com',
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              Icons.language_outlined,
                              'www.invoiceapp.com',
                            ),
                            const SizedBox(height: 12),
                            _buildContactItem(
                              Icons.phone_outlined,
                              '+1 234 567 8900',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        langProvider.isArabic
                            ? '© 2024 جميع الحقوق محفوظة'
                            : '© 2024 All Rights Reserved',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F959),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
