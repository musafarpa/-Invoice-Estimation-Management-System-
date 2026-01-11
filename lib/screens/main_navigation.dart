import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/company_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/estimation_provider.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
import 'estimation/estimation_list_screen.dart';
import 'invoice/invoice_list_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const EstimationListScreen(),
    const HomeScreen(),
    const InvoiceListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    // Fetch data from API
    final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final estimationProvider = Provider.of<EstimationProvider>(context, listen: false);

    await Future.wait([
      companyProvider.fetchCompanies(),
      invoiceProvider.fetchInvoices(),
      estimationProvider.fetchEstimations(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F959),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 32,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading data...',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.description_outlined, 'Estimation', isDark),
                _buildCenterNavItem(isDark),
                _buildNavItem(2, Icons.receipt_long_outlined, 'Invoices', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFFE8F959).withValues(alpha: 0.2) : const Color(0xFF1A1A1A).withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A))
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A))
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(bool isDark) {
    final isSelected = _currentIndex == 1;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A))
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200),
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFFE8F959).withValues(alpha: 0.3)
                        : const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.home_rounded,
          color: isSelected
              ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
              : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
          size: 28,
        ),
      ),
    );
  }
}
