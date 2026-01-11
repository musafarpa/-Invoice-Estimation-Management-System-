import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/estimation_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/estimation_model.dart';
import 'estimation_detail_screen.dart';
import 'estimation_form_screen.dart';

class EstimationListScreen extends StatefulWidget {
  const EstimationListScreen({super.key});

  @override
  State<EstimationListScreen> createState() => _EstimationListScreenState();
}

class _EstimationListScreenState extends State<EstimationListScreen> {
  @override
  Widget build(BuildContext context) {
    final estimationProvider = Provider.of<EstimationProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
    final isRTL = langProvider.isRTL;
    final isDark = themeProvider.isDarkMode;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRTL ? 'التقديرات' : 'Estimations',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        // Reload Button
                        GestureDetector(
                          onTap: () => estimationProvider.fetchEstimations(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: estimationProvider.isLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Add Button
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EstimationFormScreen(),
                              ),
                            );
                            if (result == true && mounted) {
                              estimationProvider.fetchEstimations();
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F959),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE8F959).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatChip(
                        isRTL ? 'الكل' : 'All',
                        estimationProvider.estimations.length.toString(),
                        isSelected: true,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'قيد الانتظار' : 'Pending',
                        estimationProvider.pendingCount.toString(),
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'موافق عليه' : 'Approved',
                        estimationProvider.approvedCount.toString(),
                        color: Colors.green,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // List
              Expanded(
                child: estimationProvider.isLoading && estimationProvider.estimations.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                        ),
                      )
                    : estimationProvider.errorMessage != null && estimationProvider.estimations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  estimationProvider.errorMessage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => estimationProvider.fetchEstimations(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                                    foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                  ),
                                  child: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
                                ),
                              ],
                            ),
                          )
                        : estimationProvider.estimations.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 64,
                                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isRTL ? 'لا توجد تقديرات بعد' : 'No estimations yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => estimationProvider.fetchEstimations(),
                                color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: estimationProvider.estimations.length,
                                  itemBuilder: (context, index) {
                                    final estimation = estimationProvider.estimations[index];
                                    return _buildEstimationCard(
                                      context,
                                      estimation,
                                      currencyFormat,
                                      isRTL,
                                      estimationProvider,
                                      isDark: isDark,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String count, {bool isSelected = false, Color? color, bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A))
            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color ?? (isSelected
                  ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color != null
                    ? Colors.white
                    : (isSelected
                        ? (isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A))
                        : (isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimationCard(
    BuildContext context,
    EstimationModel estimation,
    NumberFormat currencyFormat,
    bool isRTL,
    EstimationProvider provider, {
    bool isDark = false,
  }) {
    Color statusColor;
    String statusText;
    switch (estimation.status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = isRTL ? 'موافق عليه' : 'APPROVED';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = isRTL ? 'مرفوض' : 'REJECTED';
        break;
      default:
        statusColor = Colors.orange;
        statusText = isRTL ? 'قيد الانتظار' : 'PENDING';
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EstimationDetailScreen(estimation: estimation),
          ),
        );
        // Refresh list if estimation was modified
        if (result == true && mounted) {
          provider.fetchEstimations();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F959).withValues(alpha: isDark ? 0.2 : 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            estimation.clientName.isNotEmpty
                                ? estimation.clientName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estimation.clientName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              estimation.estimationNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? 'صالح حتى' : 'Valid Until',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(estimation.validUntil),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(estimation.totalAmount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
