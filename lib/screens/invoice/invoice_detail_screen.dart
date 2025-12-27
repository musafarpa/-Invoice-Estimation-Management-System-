import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/pdf_service.dart';
import 'invoice_form_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isRTL = langProvider.isRTL;
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    Color statusColor;
    String statusText;
    switch (widget.invoice.status) {
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

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: Icon(
                          isRTL ? Icons.arrow_forward : Icons.arrow_back,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Text(
                      widget.invoice.invoiceNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceFormScreen(invoice: widget.invoice),
                            ),
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, isRTL);
                        } else if (value == 'mark_paid') {
                          _markAsPaid(context, isRTL);
                        } else if (value == 'pdf') {
                          _generateAndSharePdf(context, isRTL);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(isRTL ? 'تعديل' : 'Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'pdf',
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              Text(isRTL ? 'تصدير PDF' : 'Export PDF'),
                            ],
                          ),
                        ),
                        if (widget.invoice.status != 'paid')
                          PopupMenuItem(
                            value: 'mark_paid',
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                const SizedBox(width: 12),
                                Text(
                                  isRTL ? 'وضع علامة مدفوع' : 'Mark as Paid',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              Text(
                                isRTL ? 'حذف' : 'Delete',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          Icons.more_vert,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and Total Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currencyFormat.format(widget.invoice.totalAmount),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${isRTL ? 'تاريخ الاستحقاق' : 'Due'} ${dateFormat.format(widget.invoice.dueDate)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            if (widget.invoice.status == 'paid' && widget.invoice.paidAmount != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${isRTL ? 'مدفوع' : 'Paid'}: ${currencyFormat.format(widget.invoice.paidAmount)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // PDF Export Button
                      GestureDetector(
                        onTap: _isGeneratingPdf ? null : () => _generateAndSharePdf(context, isRTL),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isGeneratingPdf)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              else
                                Icon(Icons.picture_as_pdf, color: Colors.red.shade600),
                              const SizedBox(width: 12),
                              Text(
                                _isGeneratingPdf
                                    ? (isRTL ? 'جاري الإنشاء...' : 'Generating...')
                                    : (isRTL ? 'تصدير كـ PDF' : 'Export as PDF'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Client Info
                      Text(
                        isRTL ? 'معلومات العميل' : 'Client Information',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
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
                            _buildInfoRow(Icons.person_outline, widget.invoice.clientName),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.email_outlined, widget.invoice.clientEmail),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.phone_outlined, widget.invoice.clientPhone),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on_outlined, widget.invoice.clientAddress),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Items
                      Text(
                        isRTL ? 'العناصر' : 'Items',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.invoice.items.map((item) => _buildItemCard(item, currencyFormat)),
                      const SizedBox(height: 24),

                      // Summary
                      Container(
                        width: double.infinity,
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
                          children: [
                            _buildSummaryRow(
                              isRTL ? 'المجموع الفرعي' : 'Subtotal',
                              currencyFormat.format(widget.invoice.subtotal),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              isRTL ? 'الضريبة' : 'Tax',
                              currencyFormat.format(widget.invoice.totalTax),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            _buildSummaryRow(
                              isRTL ? 'المجموع' : 'Total',
                              currencyFormat.format(widget.invoice.totalAmount),
                              isBold: true,
                            ),
                            if (widget.invoice.paidAmount != null && widget.invoice.paidAmount! > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'المدفوع' : 'Paid',
                                currencyFormat.format(widget.invoice.paidAmount),
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'الرصيد' : 'Balance',
                                currencyFormat.format(widget.invoice.balance),
                                isBold: true,
                                color: widget.invoice.balance > 0 ? Colors.red : Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (widget.invoice.notes != null && widget.invoice.notes!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          isRTL ? 'ملاحظات' : 'Notes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
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
                          child: Text(
                            widget.invoice.notes!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(InvoiceItem item, NumberFormat currencyFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            item.description,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                currencyFormat.format(item.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (item.taxRate > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Tax: ${item.taxRate}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isBold ? const Color(0xFF1A1A1A) : Colors.grey.shade600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, bool isRTL) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isRTL ? 'حذف الفاتورة' : 'Delete Invoice'),
          content: Text(isRTL
              ? 'هل أنت متأكد من حذف هذه الفاتورة؟'
              : 'Are you sure you want to delete this invoice?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<InvoiceProvider>(context, listen: false)
                    .deleteInvoice(widget.invoice.id);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isRTL ? 'تم حذف الفاتورة' : 'Invoice deleted'),
                    backgroundColor: Colors.green.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Text(
                isRTL ? 'حذف' : 'Delete',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsPaid(BuildContext context, bool isRTL) {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    final updatedInvoice = widget.invoice.copyWith(
      status: 'paid',
      paidAmount: widget.invoice.totalAmount,
    );
    provider.updateInvoice(updatedInvoice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRTL ? 'تم وضع علامة مدفوع' : 'Invoice marked as paid'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _generateAndSharePdf(BuildContext context, bool isRTL) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await PdfService.shareInvoicePdf(widget.invoice);

      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    } catch (e) {
      debugPrint('PDF Generation Error: $e');
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRTL ? 'خطأ في إنشاء PDF: $e' : 'Error generating PDF: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
