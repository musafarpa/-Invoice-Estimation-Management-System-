import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/estimation_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/estimation_model.dart';
import 'estimation_detail_screen.dart';
import 'estimation_form_screen.dart';

class EstimationListScreen extends StatelessWidget {
  const EstimationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estimationProvider = Provider.of<EstimationProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
    final isRTL = langProvider.isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
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
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EstimationFormScreen(),
                          ),
                        );
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
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'قيد الانتظار' : 'Pending',
                        estimationProvider.pendingCount.toString(),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'موافق عليه' : 'Approved',
                        estimationProvider.approvedCount.toString(),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // List
              Expanded(
                child: estimationProvider.estimations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isRTL ? 'لا توجد تقديرات بعد' : 'No estimations yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: estimationProvider.estimations.length,
                        itemBuilder: (context, index) {
                          final estimation = estimationProvider.estimations[index];
                          return _buildEstimationCard(
                            context,
                            estimation,
                            currencyFormat,
                            isRTL,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String count, {bool isSelected = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color ?? (isSelected ? Colors.white : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color != null ? Colors.white : (isSelected ? const Color(0xFF1A1A1A) : Colors.grey.shade700),
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
  ) {
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EstimationDetailScreen(estimation: estimation),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                          color: const Color(0xFFE8F959).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            estimation.clientName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              estimation.estimationNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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
                    color: statusColor.withValues(alpha: 0.1),
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
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(estimation.validUntil),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(estimation.totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
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
