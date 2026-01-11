import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;
    final isRTL = langProvider.isRTL;
    final isDark = themeProvider.isDarkMode;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
        body: SafeArea(
          child: SingleChildScrollView(
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
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            isRTL ? Icons.arrow_forward : Icons.arrow_back,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        langProvider.profile,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Card - Fixed for RTL
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F959),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8F959).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar - Always on the left in LTR, right in RTL (handled by Directionality)
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            user?.name[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user?.role == 'super_admin'
                                    ? (isRTL ? 'مدير عام' : 'Super Admin')
                                    : (isRTL ? 'مستخدم' : 'User'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Section
                _buildSectionTitle(langProvider.settings, isDark: isDark),
                const SizedBox(height: 12),

                // Language Toggle
                _buildSettingsCard(
                  context,
                  isDark: isDark,
                  children: [
                    _buildLanguageToggle(context, langProvider, isDark),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildThemeToggle(context, themeProvider, langProvider, isDark),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      title: langProvider.notifications,
                      isDark: isDark,
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeThumbColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                        activeTrackColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8F959),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account Section
                _buildSectionTitle(isRTL ? 'الحساب' : 'Account', isDark: isDark),
                const SizedBox(height: 12),

                _buildSettingsCard(
                  context,
                  isDark: isDark,
                  children: [
                    _buildSettingsItem(
                      icon: Icons.person_outline,
                      title: langProvider.editProfile,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildSettingsItem(
                      icon: Icons.lock_outline,
                      title: isRTL ? 'تغيير كلمة المرور' : 'Change Password',
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        _showChangePasswordDialog(context, langProvider);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Support Section
                _buildSectionTitle(isRTL ? 'الدعم' : 'Support', isDark: isDark),
                const SizedBox(height: 12),

                _buildSettingsCard(
                  context,
                  isDark: isDark,
                  children: [
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: langProvider.helpSupport,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildSettingsItem(
                      icon: Icons.description_outlined,
                      title: langProvider.termsConditions,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsConditionsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildSettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: langProvider.privacyPolicy,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: langProvider.aboutUs,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // More Section
                _buildSectionTitle(isRTL ? 'المزيد' : 'More', isDark: isDark),
                const SizedBox(height: 12),

                _buildSettingsCard(
                  context,
                  isDark: isDark,
                  children: [
                    _buildSettingsItem(
                      icon: Icons.star_outline,
                      title: langProvider.rateApp,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isRTL
                                ? 'شكرا لتقييمك!'
                                : 'Thanks for rating!'),
                            backgroundColor: Colors.green.shade400,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 70, endIndent: 16, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE)),
                    _buildSettingsItem(
                      icon: Icons.share_outlined,
                      title: langProvider.shareApp,
                      showArrow: true,
                      isRTL: isRTL,
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isRTL
                                ? 'مشاركة التطبيق...'
                                : 'Sharing app...'),
                            backgroundColor: Colors.blue.shade400,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context, authProvider, langProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            langProvider.logout,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Version
                Text(
                  '${langProvider.version} 1.0.0',
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
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children, bool isDark = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
    bool isRTL = false,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF1A1A1A), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow)
              Icon(
                Icons.chevron_right,
                size: 24,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, LanguageProvider langProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.language, color: isDark ? Colors.white : const Color(0xFF1A1A1A), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              langProvider.language,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Language Toggle - Always LTR for consistency
          Directionality(
            textDirection: TextDirection.ltr,
            child: GestureDetector(
              onTap: () {
                langProvider.toggleLanguage();
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: langProvider.isArabic ? 50 : 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F959),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'EN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: langProvider.isArabic
                                    ? (isDark ? Colors.grey.shade500 : Colors.white)
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'AR',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: langProvider.isArabic
                                    ? const Color(0xFF1A1A1A)
                                    : (isDark ? Colors.grey.shade500 : Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider, LanguageProvider langProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              langProvider.isArabic ? 'المظهر' : 'Theme',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Theme Toggle
          Directionality(
            textDirection: TextDirection.ltr,
            child: GestureDetector(
              onTap: () {
                themeProvider.toggleTheme();
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: isDark ? 50 : 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F959),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.light_mode,
                              size: 18,
                              color: isDark ? Colors.grey.shade500 : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.dark_mode,
                              size: 18,
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, LanguageProvider langProvider) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: langProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(langProvider.logout),
          content: Text(
            langProvider.isArabic
                ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                : 'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(langProvider.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                langProvider.logout,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, LanguageProvider langProvider) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: langProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(langProvider.isArabic ? 'تغيير كلمة المرور' : 'Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: langProvider.isArabic ? 'كلمة المرور الحالية' : 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: langProvider.isArabic ? 'كلمة المرور الجديدة' : 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: langProvider.isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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
                    content: Text(langProvider.isArabic
                        ? 'تم تغيير كلمة المرور بنجاح'
                        : 'Password changed successfully'),
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
                langProvider.save,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
