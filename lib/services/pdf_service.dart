import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../models/estimation_model.dart';

// Conditional import for web download functionality
import 'pdf_service_stub.dart'
    if (dart.library.html) 'pdf_service_web.dart' as web_platform;

class PdfService {
  static final currencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final dateFormat = DateFormat('dd-MM-yyyy');

  // Font cache
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _arabicFont;

  // Company Info - Can be customized
  static const String companyName = 'GLOBAL COOL TRADING EST.';
  static const String companyNameAr = 'مؤسسة ضباب العالم التجارية';
  static const String companyTagline = 'The Ultimate Cooling Solution For\nArchitectural & Automotive';
  static const String companyTaglineAr = 'أفلام الحماية والعازل الحراري والديكور\nسيارات ومباني';
  static const String companyCR = 'C.R. 4030252217';
  static const String companyAddress = 'P.O. Box 50597 Jeddah 21533 - Kingdom of Saudi Arabia';
  static const String companyPhone = '0122 6922271';
  static const String companyFax = '012 6925954';
  static const String companyEmail = 'mistofmiami@gmail.com';
  static const String companyWebsite = 'www.mistofmiami.com';
  static const String vatNumber = '300366857400003';

  // Bank Details
  static const String bankName = 'AL RAJHI BANK';
  static const String beneficiaryName = 'Global Cool Trading Est.';
  static const String ibanNumber = 'SA 18 8000 0425 6080 1047 3665';

  // Contact Person
  static const String contactPerson = 'Zubair M.K';
  static const String contactPhone = '0507227882';

  // Load fonts
  static Future<void> _loadFonts() async {
    if (_regularFont == null || _boldFont == null || _arabicFont == null) {
      // Load Google Fonts that support Arabic
      _regularFont = await PdfGoogleFonts.notoSansRegular();
      _boldFont = await PdfGoogleFonts.notoSansBold();
      _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    }
  }

  // Generate and show Invoice PDF
  static Future<void> shareInvoicePdf(InvoiceModel invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    final filename = 'Invoice_${invoice.invoiceNumber}.pdf';

    if (kIsWeb) {
      // Web: use dart:html to download
      web_platform.downloadPdf(bytes, filename);
    } else {
      // Native platforms: use printing package
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: filename,
      );
    }
  }

  // Generate and show Estimation PDF
  static Future<void> shareEstimationPdf(EstimationModel estimation) async {
    final bytes = await generateEstimationPdfBytes(estimation);
    final filename = 'Quotation_${estimation.estimationNumber}.pdf';

    if (kIsWeb) {
      // Web: use dart:html to download
      web_platform.downloadPdf(bytes, filename);
    } else {
      // Native platforms: use printing package
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: filename,
      );
    }
  }

  // Generate Invoice PDF bytes
  static Future<Uint8List> generateInvoicePdfBytes(InvoiceModel invoice) async {
    await _loadFonts();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 15),
            _buildDocumentTitle('Invoice', invoice.invoiceNumber, invoice.createdAt),
            pw.SizedBox(height: 15),
            _buildClientSection(invoice.clientName),
            pw.SizedBox(height: 10),
            _buildSubject('INVOICE FOR SERVICES'),
            pw.SizedBox(height: 15),
            _buildInvoiceItemsTable(invoice.items),
            pw.SizedBox(height: 10),
            _buildTotalsSection(invoice.subtotal, invoice.totalTax, invoice.totalAmount),
            pw.SizedBox(height: 15),
            _buildTermsSection(invoice.dueDate),
            pw.SizedBox(height: 15),
            _buildBankAndSignature(),
            pw.Spacer(),
            _buildFooter(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // Generate Estimation PDF bytes
  static Future<Uint8List> generateEstimationPdfBytes(EstimationModel estimation) async {
    await _loadFonts();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 15),
            _buildDocumentTitle('Quotation', estimation.estimationNumber, estimation.createdAt),
            pw.SizedBox(height: 15),
            _buildClientSection(estimation.clientName),
            pw.SizedBox(height: 10),
            _buildSubject('QUOTATION FOR SERVICES'),
            pw.SizedBox(height: 15),
            _buildEstimationItemsTable(estimation.items),
            pw.SizedBox(height: 10),
            _buildTotalsSection(estimation.subtotal, estimation.totalTax, estimation.totalAmount),
            pw.SizedBox(height: 15),
            _buildQuotationTermsSection(estimation.validUntil),
            pw.SizedBox(height: 15),
            _buildBankAndSignature(),
            pw.Spacer(),
            _buildFooter(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - English
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                    font: _boldFont,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  companyTagline,
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.black, font: _regularFont),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  companyCR,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                    font: _boldFont,
                  ),
                ),
              ],
            ),
          ),
          // Center - Logo placeholder
          pw.Container(
            width: 80,
            height: 50,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                'LOGO',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  font: _boldFont,
                ),
              ),
            ),
          ),
          // Right side - Arabic
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Text(
                    companyNameAr,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                      font: _arabicFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Text(
                    companyTaglineAr,
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.black, font: _arabicFont),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDocumentTitle(String type, String refNo, DateTime date) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Text(
            type,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
              font: _boldFont,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Ref No: $refNo',
            style: pw.TextStyle(fontSize: 11, font: _regularFont),
          ),
          pw.Text(
            'Date: ${dateFormat.format(date)}',
            style: pw.TextStyle(fontSize: 11, font: _regularFont),
          ),
          pw.Text(
            'VAT No: $vatNumber',
            style: pw.TextStyle(fontSize: 11, font: _regularFont),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClientSection(String clientName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'To,',
          style: pw.TextStyle(fontSize: 11, font: _regularFont),
        ),
        pw.Text(
          clientName,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            font: _boldFont,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSubject(String subject) {
    return pw.Text(
      'SUBJECT: $subject',
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: _boldFont,
      ),
    );
  }

  static pw.Widget _buildInvoiceItemsTable(List<InvoiceItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.6),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeaderCell('SN.'),
            _tableHeaderCell('Description'),
            _tableHeaderCell('Qty'),
            _tableHeaderCell('Unit Price\n(SAR)'),
            _tableHeaderCell('Total Price\n(SAR)'),
          ],
        ),
        // Items
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _tableDataCell('${index + 1}', center: true),
              _tableDataCell(item.description),
              _tableDataCell('${item.quantity}', center: true),
              _tableDataCell(currencyFormat.format(item.unitPrice), center: true),
              _tableDataCell(currencyFormat.format(item.subtotal), center: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildEstimationItemsTable(List<EstimationItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.6),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeaderCell('SN.'),
            _tableHeaderCell('Description'),
            _tableHeaderCell('Qty'),
            _tableHeaderCell('Unit Price\n(SAR)'),
            _tableHeaderCell('Total Price\n(SAR)'),
          ],
        ),
        // Items
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _tableDataCell('${index + 1}', center: true),
              _tableDataCell(item.description),
              _tableDataCell('${item.quantity}', center: true),
              _tableDataCell(currencyFormat.format(item.unitPrice), center: true),
              _tableDataCell(currencyFormat.format(item.subtotal), center: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          font: _boldFont,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableDataCell(String text, {bool center = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, font: _regularFont),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildTotalsSection(double subtotal, double tax, double total) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Total Amount in SAR', subtotal),
          _buildTotalRow('VAT @15%', tax),
          _buildTotalRow('Total Amount with VAT in SAR', total, isBold: true),
          pw.SizedBox(height: 5),
          pw.Text(
            '(Saudi Riyals ${_numberToWords(total.round())} Only)',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
              font: _boldFont,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return pw.Container(
      width: 300,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            width: 180,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                font: isBold ? _boldFont : _regularFont,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Container(
            width: 100,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Text(
              currencyFormat.format(amount),
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                font: isBold ? _boldFont : _regularFont,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTermsSection(DateTime dueDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Terms & Conditions:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
            font: _boldFont,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Payment is due by ${dateFormat.format(dueDate)}.',
          style: pw.TextStyle(fontSize: 9, font: _regularFont),
        ),
        pw.Text(
          '2. Late payments may incur additional charges.',
          style: pw.TextStyle(fontSize: 9, font: _regularFont),
        ),
        pw.Text(
          '3. All prices are in Saudi Riyals (SAR).',
          style: pw.TextStyle(fontSize: 9, font: _regularFont),
        ),
      ],
    );
  }

  static pw.Widget _buildQuotationTermsSection(DateTime validUntil) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Terms & Conditions:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
            font: _boldFont,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Work Completion in 10 Working days after the advance payment.',
          style: pw.TextStyle(fontSize: 9, font: _regularFont),
        ),
        pw.Text(
          '2. Validity of the quotation will be 15 days from the above date.',
          style: pw.TextStyle(fontSize: 9, font: _regularFont),
        ),
        pw.Text(
          '3. 50% Advance payment with the PO, 35% on Work Progress, & 15% on Work completion.',
          style: pw.TextStyle(fontSize: 9, font: _regularFont),
        ),
      ],
    );
  }

  static pw.Widget _buildBankAndSignature() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bank Details
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Bank Details:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                  font: _boldFont,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(bankName, style: pw.TextStyle(fontSize: 9, font: _regularFont)),
              pw.Text('Beneficiary Name: $beneficiaryName', style: pw.TextStyle(fontSize: 9, font: _regularFont)),
              pw.Text('IBAN No: $ibanNumber', style: pw.TextStyle(fontSize: 9, font: _regularFont)),
              pw.SizedBox(height: 10),
              pw.Text('Best Regards,', style: pw.TextStyle(fontSize: 9, font: _regularFont)),
              pw.Text(
                contactPerson,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(contactPhone, style: pw.TextStyle(fontSize: 9, font: _regularFont)),
            ],
          ),
        ),
        // Signature area
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(40),
              ),
              child: pw.Center(
                child: pw.Text(
                  'STAMP',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                    font: _boldFont,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Container(
              width: 80,
              height: 30,
              child: pw.Center(
                child: pw.Text(
                  'Signature',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, font: _regularFont),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'E-mail: $companyEmail  |  Tel: $companyPhone  |  Fax: $companyFax',
                style: pw.TextStyle(fontSize: 7, font: _regularFont),
              ),
            ],
          ),
          pw.Text(
            companyAddress,
            style: pw.TextStyle(fontSize: 7, font: _regularFont),
          ),
          pw.Text(
            companyWebsite,
            style: pw.TextStyle(fontSize: 7, color: PdfColors.blue800, font: _regularFont),
          ),
        ],
      ),
    );
  }

  static String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String words = '';

    if (number >= 1000000) {
      words += '${_numberToWords(number ~/ 1000000)} Million ';
      number %= 1000000;
    }

    if (number >= 1000) {
      words += '${_numberToWords(number ~/ 1000)} Thousand ';
      number %= 1000;
    }

    if (number >= 100) {
      words += '${units[number ~/ 100]} Hundred ';
      number %= 100;
    }

    if (number >= 20) {
      words += '${tens[number ~/ 10]} ';
      number %= 10;
    }

    if (number > 0) {
      words += '${units[number]} ';
    }

    return words.trim();
  }
}
