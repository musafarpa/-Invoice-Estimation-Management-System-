import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/invoice_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/invoice_model.dart';
import 'invoice_detail_screen.dart';
import 'invoice_form_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
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
                      isRTL ? 'الفواتير' : 'Invoices',
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
                          onTap: () => invoiceProvider.fetchInvoices(),
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
                            child: invoiceProvider.isLoading
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
                                builder: (_) => const InvoiceFormScreen(),
                              ),
                            );
                            if (result == true && mounted) {
                              invoiceProvider.fetchInvoices();
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
                        invoiceProvider.invoices.length.toString(),
                        isSelected: true,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'غير مدفوع' : 'Unpaid',
                        invoiceProvider.unpaidCount.toString(),
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'مدفوع' : 'Paid',
                        invoiceProvider.paidCount.toString(),
                        color: Colors.green,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        isRTL ? 'متأخر' : 'Overdue',
                        invoiceProvider.overdueCount.toString(),
                        color: Colors.red,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // List
              Expanded(
                child: invoiceProvider.isLoading && invoiceProvider.invoices.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                        ),
                      )
                    : invoiceProvider.errorMessage != null && invoiceProvider.invoices.isEmpty
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
                                  invoiceProvider.errorMessage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => invoiceProvider.fetchInvoices(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                                    foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                  ),
                                  child: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
                                ),
                              ],
                            ),
                          )
                        : invoiceProvider.invoices.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isRTL ? 'لا توجد فواتير بعد' : 'No invoices yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => invoiceProvider.fetchInvoices(),
                                color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: invoiceProvider.invoices.length,
                                  itemBuilder: (context, index) {
                                    final invoice = invoiceProvider.invoices[index];
                                    return _buildInvoiceCard(
                                      context,
                                      invoice,
                                      currencyFormat,
                                      isRTL,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color ?? (isSelected
                  ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 11,
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

  Widget _buildInvoiceCard(
    BuildContext context,
    InvoiceModel invoice,
    NumberFormat currencyFormat,
    bool isRTL, {
    bool isDark = false,
  }) {
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
      onTap: () async {
        final provider = Provider.of<InvoiceProvider>(context, listen: false);
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(invoice: invoice),
          ),
        );
        // Refresh list if invoice was modified
        if (result == true) {
          provider.fetchInvoices();
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
                          color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            invoice.clientName.isNotEmpty
                                ? invoice.clientName[0].toUpperCase()
                                : '?',
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              invoice.invoiceNumber,
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
                      isRTL ? 'تاريخ الاستحقاق' : 'Due Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: invoice.status == 'overdue'
                            ? Colors.red
                            : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(invoice.totalAmount),
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
