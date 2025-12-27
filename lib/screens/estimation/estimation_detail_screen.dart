import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/estimation_model.dart';
import '../../providers/estimation_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/pdf_service.dart';
import 'estimation_form_screen.dart';

class EstimationDetailScreen extends StatefulWidget {
  final EstimationModel estimation;

  const EstimationDetailScreen({super.key, required this.estimation});

  @override
  State<EstimationDetailScreen> createState() => _EstimationDetailScreenState();
}

class _EstimationDetailScreenState extends State<EstimationDetailScreen> {
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isRTL = langProvider.isRTL;
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    Color statusColor;
    String statusText;
    switch (widget.estimation.status) {
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
                      widget.estimation.estimationNumber,
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
                              builder: (_) => EstimationFormScreen(
                                estimation: widget.estimation,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, isRTL);
                        } else if (value == 'convert') {
                          _convertToInvoice(context, isRTL);
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
                        PopupMenuItem(
                          value: 'convert',
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 20, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text(
                                isRTL ? 'تحويل لفاتورة' : 'Convert to Invoice',
                                style: const TextStyle(color: Colors.blue),
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
                                  color: statusColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currencyFormat.format(widget.estimation.totalAmount),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${isRTL ? 'صالح حتى' : 'Valid until'} ${dateFormat.format(widget.estimation.validUntil)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
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
                            _buildInfoRow(Icons.person_outline, widget.estimation.clientName),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.email_outlined, widget.estimation.clientEmail),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.phone_outlined, widget.estimation.clientPhone),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on_outlined, widget.estimation.clientAddress),
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
                      ...widget.estimation.items.map((item) => _buildItemCard(item, currencyFormat)),
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
                              currencyFormat.format(widget.estimation.subtotal),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              isRTL ? 'الضريبة' : 'Tax',
                              currencyFormat.format(widget.estimation.totalTax),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            _buildSummaryRow(
                              isRTL ? 'المجموع' : 'Total',
                              currencyFormat.format(widget.estimation.totalAmount),
                              isBold: true,
                            ),
                          ],
                        ),
                      ),

                      if (widget.estimation.notes != null && widget.estimation.notes!.isNotEmpty) ...[
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
                            widget.estimation.notes!,
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

  Widget _buildItemCard(EstimationItem item, NumberFormat currencyFormat) {
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF1A1A1A) : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
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
          title: Text(isRTL ? 'حذف التقدير' : 'Delete Estimation'),
          content: Text(isRTL
              ? 'هل أنت متأكد من حذف هذا التقدير؟'
              : 'Are you sure you want to delete this estimation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<EstimationProvider>(context, listen: false)
                    .deleteEstimation(widget.estimation.id);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isRTL ? 'تم حذف التقدير' : 'Estimation deleted'),
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

  void _convertToInvoice(BuildContext context, bool isRTL) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final invoice = invoiceProvider.createFromEstimation(widget.estimation);
    invoiceProvider.addInvoice(invoice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRTL
            ? 'تم إنشاء الفاتورة ${invoice.invoiceNumber}'
            : 'Invoice ${invoice.invoiceNumber} created'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _generateAndSharePdf(BuildContext context, bool isRTL) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await PdfService.shareEstimationPdf(widget.estimation);

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
