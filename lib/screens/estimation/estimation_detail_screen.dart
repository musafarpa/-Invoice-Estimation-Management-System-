import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/estimation_model.dart';
import '../../providers/estimation_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
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
  bool _isLoading = true;
  bool _isDeleting = false;
  late EstimationModel _estimation;

  @override
  void initState() {
    super.initState();
    _estimation = widget.estimation;
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    // Don't initialize if deletion is in progress or widget is disposed
    if (_isDeleting || !mounted) return;

    final provider = Provider.of<EstimationProvider>(context, listen: false);
    // Clear any previous errors (done after frame to avoid build issues)
    provider.clearError();

    // Try to get from local cache first (the list already has complete data)
    // This avoids calling the single-item GET endpoint which may return 500
    final localEstimation = provider.getEstimationById(_estimation.id);

    if (mounted && !_isDeleting) {
      setState(() {
        if (localEstimation != null) {
          _estimation = localEstimation;
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
    switch (_estimation.status) {
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
                            _estimation.estimationNumber,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                    PopupMenuButton<String>(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEdit(context);
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
                              currencyFormat.format(_estimation.totalAmount),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${isRTL ? 'صالح حتى' : 'Valid until'} ${dateFormat.format(_estimation.validUntil)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            // Amount in words - English
                            if (_estimation.amountInWordsEn != null &&
                                _estimation.amountInWordsEn!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _estimation.amountInWordsEn!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            // Amount in words - Arabic
                            if (_estimation.amountInWordsAr != null &&
                                _estimation.amountInWordsAr!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  _estimation.amountInWordsAr!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Company Information (if available)
                      if (_estimation.company != null) ...[
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
                              // Company Name (English)
                              if (_estimation.company!.nameEn.isNotEmpty) ...[
                                Text(
                                  _estimation.company!.nameEn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              // Company Name (Arabic)
                              if (_estimation.company!.nameAr.isNotEmpty) ...[
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    _estimation.company!.nameAr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                              if (_estimation.company!.subtitleEn.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _estimation.company!.subtitleEn,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (_estimation.company!.crNumber.isNotEmpty)
                                _buildCompanyRow(
                                    'CR Number', _estimation.company!.crNumber),
                              if (_estimation.company!.vatNumber.isNotEmpty)
                                _buildCompanyRow(
                                    'VAT Number', _estimation.company!.vatNumber),
                              if (_estimation.company!.contactPerson.isNotEmpty)
                                _buildCompanyRow(
                                    'Contact', _estimation.company!.contactPerson),
                              if (_estimation.company!.contactNumber.isNotEmpty)
                                _buildCompanyRow(
                                    'Phone', _estimation.company!.contactNumber),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Bank Details
                        if (_estimation.company!.bankName.isNotEmpty ||
                            _estimation.company!.iban.isNotEmpty) ...[
                          Text(
                            isRTL ? 'تفاصيل البنك' : 'Bank Details',
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
                                if (_estimation.company!.bankName.isNotEmpty)
                                  _buildCompanyRow(
                                      'Bank', _estimation.company!.bankName),
                                if (_estimation.company!.beneficiary.isNotEmpty)
                                  _buildCompanyRow('Beneficiary',
                                      _estimation.company!.beneficiary),
                                if (_estimation.company!.iban.isNotEmpty)
                                  _buildCompanyRow(
                                      'IBAN', _estimation.company!.iban),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

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
                            // Client Name (only show Arabic if different)
                            if (_estimation.clientName.isNotEmpty)
                              _buildInfoRow(Icons.person_outline, _estimation.clientName, isDark: isDark),
                            if (_estimation.clientNameAr.isNotEmpty &&
                                _estimation.clientNameAr != _estimation.clientName) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    _estimation.clientNameAr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (_estimation.clientEmail.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.email_outlined, _estimation.clientEmail, isDark: isDark),
                            ],
                            if (_estimation.clientPhone.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.phone_outlined, _estimation.clientPhone, isDark: isDark),
                            ],
                            if (_estimation.clientAddress.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.location_on_outlined, _estimation.clientAddress, isDark: isDark),
                            ],
                            if (_estimation.clientVatNumber != null && _estimation.clientVatNumber!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.receipt_outlined, '${isRTL ? 'الرقم الضريبي' : 'VAT'}: ${_estimation.clientVatNumber}', isDark: isDark),
                            ],
                            if (_estimation.clientCity != null && _estimation.clientCity!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_city_outlined,
                                [
                                  _estimation.clientCity,
                                  if (_estimation.clientPostalCode != null && _estimation.clientPostalCode!.isNotEmpty) _estimation.clientPostalCode,
                                  if (_estimation.clientCountry != null && _estimation.clientCountry!.isNotEmpty) _estimation.clientCountry,
                                ].where((e) => e != null && e.isNotEmpty).join(', '),
                                isDark: isDark,
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
                      ..._estimation.items.map((item) => _buildItemCard(item, currencyFormat, isDark)),
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
                              currencyFormat.format(_estimation.subtotal),
                              isDark: isDark,
                            ),
                            // Discount
                            if (_estimation.discount != null && _estimation.discount! > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'الخصم' : 'Discount',
                                '- ${currencyFormat.format(_estimation.discount)}',
                                valueColor: Colors.red,
                                isDark: isDark,
                              ),
                            ],
                            const SizedBox(height: 8),
                            // VAT with percentage
                            _buildSummaryRow(
                              _estimation.vatRate != null
                                  ? '${isRTL ? 'ضريبة القيمة المضافة' : 'VAT'} (${_estimation.vatRate!.toStringAsFixed(0)}%)'
                                  : (isRTL ? 'ضريبة القيمة المضافة' : 'VAT'),
                              currencyFormat.format(_estimation.totalTax),
                              isDark: isDark,
                            ),
                            // Round off
                            if (_estimation.roundOff != null && _estimation.roundOff != 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                isRTL ? 'التقريب' : 'Round Off',
                                currencyFormat.format(_estimation.roundOff),
                                isDark: isDark,
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: isDark ? const Color(0xFF3A3A3A) : null),
                            ),
                            _buildSummaryRow(
                              isRTL ? 'المجموع' : 'Total',
                              currencyFormat.format(_estimation.totalAmount),
                              isBold: true,
                              isDark: isDark,
                            ),
                            // Amount in words section
                            if (_estimation.amountInWordsAr != null && _estimation.amountInWordsAr!.isNotEmpty) ...[
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
                                      _estimation.amountInWordsAr!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    // English amount in words (if available)
                                    if (_estimation.amountInWordsEn != null && _estimation.amountInWordsEn!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _estimation.amountInWordsEn!,
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
                          ],
                        ),
                      ),

                      // Notes/Subject
                      if ((_estimation.notes != null && _estimation.notes!.isNotEmpty) ||
                          (_estimation.notesAr != null && _estimation.notesAr!.isNotEmpty)) ...[
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
                              // English notes
                              if (_estimation.notes != null &&
                                  _estimation.notes!.isNotEmpty) ...[
                                Text(
                                  _estimation.notes!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                              // Arabic notes (only show if different from English)
                              if (_estimation.notesAr != null &&
                                  _estimation.notesAr!.isNotEmpty &&
                                  _estimation.notesAr != _estimation.notes) ...[
                                if (_estimation.notes != null &&
                                    _estimation.notes!.isNotEmpty)
                                  const SizedBox(height: 12),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    _estimation.notesAr!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
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

  Widget _buildCompanyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isDark = false}) {
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

  Widget _buildItemCard(EstimationItem item, NumberFormat currencyFormat, bool isDark) {
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor, bool isDark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold
                ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final provider = Provider.of<EstimationProvider>(context, listen: false);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EstimationFormScreen(estimation: _estimation),
      ),
    );

    // Refresh estimation data after edit
    if (result == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      // Refresh the full list to get updated data
      await provider.fetchEstimations();

      // Get updated estimation from local cache
      final updatedEstimation = provider.getEstimationById(_estimation.id);
      if (mounted) {
        setState(() {
          if (updatedEstimation != null) {
            _estimation = updatedEstimation;
          }
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteDialog(BuildContext context, bool isRTL) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isRTL ? 'حذف التقدير' : 'Delete Estimation'),
          content: Text(isRTL
              ? 'هل أنت متأكد من حذف هذا التقدير؟'
              : 'Are you sure you want to delete this estimation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final provider = Provider.of<EstimationProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                debugPrint('=== DELETE ESTIMATION CLICKED ===');
                debugPrint('Estimation ID: ${_estimation.id}');
                debugPrint('Estimation Number: ${_estimation.estimationNumber}');

                // Set deleting flag to prevent any fetch calls
                setState(() {
                  _isDeleting = true;
                });

                Navigator.pop(dialogContext); // Close dialog first

                debugPrint('Calling provider.deleteEstimation...');
                final success = await provider.deleteEstimation(_estimation.id);
                debugPrint('Delete result: success=$success');
                debugPrint('Provider error message: ${provider.errorMessage}');

                if (mounted) {
                  if (success) {
                    debugPrint('Delete successful, showing success snackbar and navigating back');
                    // Show success message first, then navigate back
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(isRTL ? 'تم حذف التقدير' : 'Estimation deleted'),
                        backgroundColor: Colors.green.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    navigator.pop(true); // Pass true to indicate deletion
                  } else {
                    debugPrint('Delete failed, showing error snackbar');
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

  Future<void> _convertToInvoice(BuildContext context, bool isRTL) async {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final invoice = invoiceProvider.createFromEstimation(_estimation);
    final success = await invoiceProvider.addInvoice(invoice);

    if (!mounted) return;

    if (success) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage ?? (isRTL ? 'فشل الإنشاء' : 'Failed to create invoice')),
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
      await PdfService.shareEstimationPdf(_estimation);

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
