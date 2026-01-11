import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
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
  bool _isLoading = true;
  bool _isDeleting = false;
  late InvoiceModel _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    // Don't fetch if deletion is in progress
    if (_isDeleting) return;

    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    final fetchedInvoice = await provider.fetchInvoiceById(_invoice.id);

    if (mounted && !_isDeleting) {
      setState(() {
        if (fetchedInvoice != null) {
          _invoice = fetchedInvoice;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isRTL = langProvider.isRTL;
    final isDark = themeProvider.isDarkMode;
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    Color statusColor;
    String statusText;
    switch (_invoice.status) {
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
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
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
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
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
                    _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                            ),
                          )
                        : Text(
                            _invoice.invoiceNumber,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                    PopupMenuButton<String>(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEdit(context);
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
                              Icon(Icons.edit_outlined, size: 20, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                              const SizedBox(width: 12),
                              Text(isRTL ? 'تعديل' : 'Edit', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'pdf',
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              Text(isRTL ? 'تصدير PDF' : 'Export PDF', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                            ],
                          ),
                        ),
                        if (_invoice.status != 'paid')
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
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
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
                          color: statusColor.withValues(alpha: isDark ? 0.2 : 0.15),
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
                              currencyFormat.format(_invoice.totalAmount),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            // Amount in words - English
                            if (_invoice.amountInWordsEn != null && _invoice.amountInWordsEn!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _invoice.amountInWordsEn!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            // Amount in words - Arabic
                            if (_invoice.amountInWordsAr != null && _invoice.amountInWordsAr!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _invoice.amountInWordsAr!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '${isRTL ? 'التاريخ' : 'Date'}: ${dateFormat.format(_invoice.createdAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            if (_invoice.status == 'paid' && _invoice.paidAmount != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${isRTL ? 'مدفوع' : 'Paid'}: ${currencyFormat.format(_invoice.paidAmount)}',
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
                            color: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.red.shade700 : Colors.red.shade200),
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
                                Icon(Icons.picture_as_pdf, color: isDark ? Colors.red.shade400 : Colors.red.shade600),
                              const SizedBox(width: 12),
                              Text(
                                _isGeneratingPdf
                                    ? (isRTL ? 'جاري الإنشاء...' : 'Generating...')
                                    : (isRTL ? 'تصدير كـ PDF' : 'Export as PDF'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.red.shade400 : Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Company Info (if available)
                      if (_invoice.company != null) ...[
                        Text(
                          isRTL ? 'معلومات الشركة' : 'Company Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.blue.shade700 : Colors.blue.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company Name - English
                              Text(
                                _invoice.company!.nameEn,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              // Company Name - Arabic (if different and not empty)
                              if (_invoice.company!.nameAr.isNotEmpty &&
                                  _invoice.company!.nameAr != _invoice.company!.nameEn) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _invoice.company!.nameAr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                              // Subtitle - English
                              if (_invoice.company!.subtitleEn.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _invoice.company!.subtitleEn,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              // Subtitle - Arabic (if different and not empty)
                              if (_invoice.company!.subtitleAr.isNotEmpty &&
                                  _invoice.company!.subtitleAr != _invoice.company!.subtitleEn) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _invoice.company!.subtitleAr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (_invoice.company!.crNumber.isNotEmpty)
                                _buildCompanyInfoRow(
                                  isRTL ? 'رقم السجل التجاري' : 'CR Number',
                                  _invoice.company!.crNumber,
                                  isDark,
                                ),
                              if (_invoice.company!.vatNumber.isNotEmpty)
                                _buildCompanyInfoRow(
                                  isRTL ? 'الرقم الضريبي' : 'VAT Number',
                                  _invoice.company!.vatNumber,
                                  isDark,
                                ),
                              if (_invoice.company!.contactPerson.isNotEmpty)
                                _buildCompanyInfoRow(
                                  isRTL ? 'جهة الاتصال' : 'Contact',
                                  _invoice.company!.contactPerson,
                                  isDark,
                                ),
                              if (_invoice.company!.contactNumber.isNotEmpty)
                                _buildCompanyInfoRow(
                                  isRTL ? 'رقم الهاتف' : 'Phone',
                                  _invoice.company!.contactNumber,
                                  isDark,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Client Info
                      Text(
                        isRTL ? 'معلومات العميل' : 'Client Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
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
                            // Show client name (only show Arabic if different from English)
                            if (_invoice.clientName.isNotEmpty) ...[
                              _buildInfoRow(Icons.person_outline, _invoice.clientName, isDark),
                              if (_invoice.clientNameAr.isNotEmpty &&
                                  _invoice.clientNameAr != _invoice.clientName) ...[
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(
                                    _invoice.clientNameAr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ],
                            ],
                            if (_invoice.clientEmail.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.email_outlined, _invoice.clientEmail, isDark),
                            ],
                            if (_invoice.clientPhone.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.phone_outlined, _invoice.clientPhone, isDark),
                            ],
                            if (_invoice.clientAddress.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.location_on_outlined, _invoice.clientAddress, isDark),
                            ],
                            if (_invoice.clientVatNumber != null && _invoice.clientVatNumber!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.receipt_outlined, '${isRTL ? 'الرقم الضريبي' : 'VAT'}: ${_invoice.clientVatNumber}', isDark),
                            ],
                            if (_invoice.clientCity != null && _invoice.clientCity!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_city_outlined,
                                [
                                  _invoice.clientCity,
                                  if (_invoice.clientPostalCode != null && _invoice.clientPostalCode!.isNotEmpty) _invoice.clientPostalCode,
                                  if (_invoice.clientCountry != null && _invoice.clientCountry!.isNotEmpty) _invoice.clientCountry,
                                ].where((e) => e != null && e.isNotEmpty).join(', '),
                                isDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Items
                      Text(
                        isRTL ? 'العناصر' : 'Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._invoice.items.map((item) => _buildItemCard(item, currencyFormat, isRTL, isDark)),
                      const SizedBox(height: 24),

                      // Summary
                      Container(
                        width: double.infinity,
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
                          children: [
                            _buildSummaryRow(
                              isRTL ? 'المجموع الفرعي' : 'Subtotal',
                              currencyFormat.format(_invoice.subtotal),
                              isDark: isDark,
                            ),
                            // Discount
                            if (_invoice.discount != null && _invoice.discount! > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'الخصم' : 'Discount',
                                '- ${currencyFormat.format(_invoice.discount)}',
                                color: Colors.green,
                                isDark: isDark,
                              ),
                            ],
                            // VAT
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              _invoice.vatRate != null
                                  ? '${isRTL ? 'ضريبة القيمة المضافة' : 'VAT'} (${_invoice.vatRate}%)'
                                  : (isRTL ? 'ضريبة القيمة المضافة' : 'VAT'),
                              currencyFormat.format(_invoice.totalTax),
                              isDark: isDark,
                            ),
                            // Round Off
                            if (_invoice.roundOff != null && _invoice.roundOff! != 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'التقريب' : 'Round Off',
                                currencyFormat.format(_invoice.roundOff),
                                isDark: isDark,
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                            ),
                            _buildSummaryRow(
                              isRTL ? 'المجموع الكلي' : 'Total',
                              currencyFormat.format(_invoice.totalAmount),
                              isBold: true,
                              isDark: isDark,
                            ),
                            // Amount in words section
                            if (_invoice.amountInWordsAr != null && _invoice.amountInWordsAr!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isRTL ? 'المبلغ بالكلمات:' : 'Amount in Words:',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Arabic amount in words
                                    Text(
                                      _invoice.amountInWordsAr!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    // English amount in words (if available)
                                    if (_invoice.amountInWordsEn != null && _invoice.amountInWordsEn!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _invoice.amountInWordsEn!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                            if (_invoice.paidAmount != null && _invoice.paidAmount! > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'المدفوع' : 'Paid',
                                currencyFormat.format(_invoice.paidAmount),
                                color: Colors.green,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'الرصيد' : 'Balance',
                                currencyFormat.format(_invoice.balance),
                                isBold: true,
                                color: _invoice.balance > 0 ? Colors.red : Colors.green,
                                isDark: isDark,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Bank Details (if company has them)
                      if (_invoice.company != null && _invoice.company!.iban.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          isRTL ? 'معلومات البنك' : 'Bank Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.green.shade700 : Colors.green.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_invoice.company!.bankName.isNotEmpty)
                                _buildCompanyInfoRow(
                                  isRTL ? 'اسم البنك' : 'Bank Name',
                                  _invoice.company!.bankName,
                                  isDark,
                                ),
                              if (_invoice.company!.beneficiary.isNotEmpty)
                                _buildCompanyInfoRow(
                                  isRTL ? 'المستفيد' : 'Beneficiary',
                                  _invoice.company!.beneficiary,
                                  isDark,
                                ),
                              _buildCompanyInfoRow(
                                isRTL ? 'رقم الحساب' : 'IBAN',
                                _invoice.company!.iban,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Payment Status Section (if QR code or payment info available)
                      if (_invoice.qrCode != null || _invoice.paymentStatus != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          isRTL ? 'حالة الدفع' : 'Payment Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.purple.shade900.withValues(alpha: 0.3) : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.purple.shade700 : Colors.purple.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Payment Status
                              if (_invoice.paymentStatus != null)
                                Row(
                                  children: [
                                    Icon(
                                      _invoice.paymentStatus == 'paid' ? Icons.check_circle : Icons.pending,
                                      color: _invoice.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _invoice.paymentStatus == 'paid'
                                          ? (isRTL ? 'تم الدفع' : 'Paid')
                                          : (isRTL ? 'في انتظار الدفع' : 'Pending Payment'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _invoice.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              // Transaction ID
                              if (_invoice.transactionId != null && _invoice.transactionId!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _buildCompanyInfoRow(
                                  isRTL ? 'رقم المعاملة' : 'Transaction ID',
                                  _invoice.transactionId!,
                                  isDark,
                                ),
                              ],
                              // Payment Date
                              if (_invoice.paymentDate != null) ...[
                                const SizedBox(height: 8),
                                _buildCompanyInfoRow(
                                  isRTL ? 'تاريخ الدفع' : 'Payment Date',
                                  DateFormat('dd-MM-yyyy').format(_invoice.paymentDate!),
                                  isDark,
                                ),
                              ],
                              // QR Code indicator
                              if (_invoice.qrCode != null && _invoice.qrCode!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isRTL ? 'رمز QR للدفع متاح في PDF' : 'Payment QR Code available in PDF',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Notes/Subject
                      if (_invoice.notes != null && _invoice.notes!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          isRTL ? 'الموضوع / ملاحظات' : 'Subject / Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
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
                              // Subject
                              Text(
                                _invoice.notes!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              // Only show Arabic if different from English
                              if (_invoice.notesAr != null &&
                                  _invoice.notesAr!.isNotEmpty &&
                                  _invoice.notesAr != _invoice.notes) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _invoice.notesAr!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ],
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

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(InvoiceItem item, NumberFormat currencyFormat, bool isRTL, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            item.description,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.quantity} ${item.unit} x ${currencyFormat.format(item.unitPrice)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Text(
                currencyFormat.format(item.total),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          if (item.taxRate > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${isRTL ? 'الضريبة' : 'Tax'}: ${item.taxRate}%',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, bool isDark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isBold
                ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? (isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceFormScreen(invoice: _invoice),
      ),
    );

    // Refresh invoice data from API after edit
    if (result == true && mounted) {
      setState(() {
        _isLoading = true;
      });
      await _fetchInvoiceDetails();
    }
  }

  void _showDeleteDialog(BuildContext context, bool isRTL) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isRTL ? 'حذف الفاتورة' : 'Delete Invoice'),
          content: Text(isRTL
              ? 'هل أنت متأكد من حذف هذه الفاتورة؟'
              : 'Are you sure you want to delete this invoice?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final provider = Provider.of<InvoiceProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // Set deleting flag to prevent any fetch calls
                setState(() {
                  _isDeleting = true;
                });

                Navigator.pop(dialogContext); // Close dialog first

                final success = await provider.deleteInvoice(_invoice.id);
                if (mounted) {
                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(isRTL ? 'تم حذف الفاتورة' : 'Invoice deleted'),
                        backgroundColor: Colors.green.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    navigator.pop(true); // Pass true to indicate deletion
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? (isRTL ? 'فشل الحذف' : 'Delete failed')),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
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

  Future<void> _markAsPaid(BuildContext context, bool isRTL) async {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    final updatedInvoice = _invoice.copyWith(
      status: 'paid',
      paidAmount: _invoice.totalAmount,
    );
    final success = await provider.updateInvoice(updatedInvoice);

    if (!mounted) return;

    if (success) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? (isRTL ? 'فشل التحديث' : 'Update failed')),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _generateAndSharePdf(BuildContext context, bool isRTL) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await PdfService.shareInvoicePdf(_invoice);

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
