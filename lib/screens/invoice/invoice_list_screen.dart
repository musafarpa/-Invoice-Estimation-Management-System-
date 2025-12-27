import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/invoice_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/invoice_model.dart';
import 'invoice_detail_screen.dart';
import 'invoice_form_screen.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
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
                      isRTL ? 'الفواتير' : 'Invoices',
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
                            builder: (_) => const InvoiceFormScreen(),
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
                        invoiceProvider.invoices.length.toString(),
                        isSelected: true,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'غير مدفوع' : 'Unpaid',
                        invoiceProvider.unpaidCount.toString(),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'مدفوع' : 'Paid',
                        invoiceProvider.paidCount.toString(),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'متأخر' : 'Overdue',
                        invoiceProvider.overdueCount.toString(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // List
              Expanded(
                child: invoiceProvider.invoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isRTL ? 'لا توجد فواتير بعد' : 'No invoices yet',
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
                        itemCount: invoiceProvider.invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoiceProvider.invoices[index];
                          return _buildInvoiceCard(
                            context,
                            invoice,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color ?? (isSelected ? Colors.white : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color != null ? Colors.white : (isSelected ? const Color(0xFF1A1A1A) : Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    InvoiceModel invoice,
    NumberFormat currencyFormat,
    bool isRTL,
  ) {
    Color statusColor;
    String statusText;
    switch (invoice.status) {
      case 'paid':
        statusColor = Colors.green;
        statusText = isRTL ? 'مدفوع' : 'PAID';
        break;
      case 'overdue':
        statusColor = Colors.red;
        statusText = isRTL ? 'متأخر' : 'OVERDUE';
        break;
      default:
        statusColor = Colors.orange;
        statusText = isRTL ? 'غير مدفوع' : 'UNPAID';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(invoice: invoice),
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
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            invoice.clientName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
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
                              invoice.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              invoice.invoiceNumber,
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
                      isRTL ? 'تاريخ الاستحقاق' : 'Due Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: invoice.status == 'overdue' ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(invoice.totalAmount),
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
