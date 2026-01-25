import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:barcode/barcode.dart';
import '../models/invoice_model.dart';
import '../models/estimation_model.dart';
import 'api_service.dart';

// Conditional import for web download functionality
import 'pdf_service_stub.dart'
    if (dart.library.html) 'pdf_service_web.dart' as web_platform;

class PdfService {
  static final currencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final dateFormat = DateFormat('dd-MM-yyyy');

  // Font cache - fonts are loaded fresh on each PDF generation for proper Arabic support
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;

  // Default Company Info - Fallback values
  static const String defaultCompanyName = 'GLOBAL COOL TRADING EST.';
  static const String defaultCompanyNameAr = 'مؤسسة ضباب العالم التجارية';
  static const String defaultCompanyTagline = 'The Ultimate Cooling Solution For\nArchitectural & Automotive';
  static const String defaultCompanyTaglineAr = 'أفلام الحماية والعازل الحراري والديكور\nسيارات ومباني';
  static const String defaultCompanyCR = '4030252217';
  static const String defaultCompanyAddress = 'P.O. Box 50597 Jeddah 21533 - Kingdom of Saudi Arabia';
  static const String defaultCompanyAddressAr = 'ص.ب 50597 جدة 21533 - المملكة العربية السعودية';
  static const String defaultCompanyPhone = '0122 6922271';
  static const String defaultCompanyFax = '012 6925954';
  static const String defaultCompanyEmail = 'mistofmiami@gmail.com';
  static const String defaultCompanyWebsite = 'www.mistofmiami.com';
  static const String defaultVatNumber = '300366857400003';

  // Default Bank Details
  static const String defaultBankName = 'AL RAJHI BANK';
  static const String defaultBeneficiaryName = 'Global Cool Trading Est.';
  static const String defaultIbanNumber = 'SA 18 8000 0425 6080 1047 3665';

  // Default Contact Person
  static const String defaultContactPerson = 'Zubair M.K';
  static const String defaultContactPhone = '0507227882';

  // Helper to return non-empty string or fallback
  static String _nonEmpty(String? value, String fallback) {
    return (value != null && value.isNotEmpty) ? value : fallback;
  }

  // Load fonts - using Cairo for Arabic (excellent Arabic support)
  static Future<void> _loadFonts() async {
    // Always reload fonts to ensure proper Arabic rendering
    _regularFont = await PdfGoogleFonts.notoSansRegular();
    _boldFont = await PdfGoogleFonts.notoSansBold();
    // Use Cairo font - excellent Arabic support in PDF
    _arabicFont = await PdfGoogleFonts.cairoRegular();
    _arabicBoldFont = await PdfGoogleFonts.cairoBold();
  }

  // Get Arabic text style with proper font - Cairo font has excellent Arabic support
  static pw.TextStyle _arabicStyle({double fontSize = 8, bool bold = false, PdfColor? color}) {
    final baseFont = bold ? _arabicBoldFont : _arabicFont;
    return pw.TextStyle(
      fontSize: fontSize,
      font: baseFont,
      fontFallback: [
        if (_arabicFont != null) _arabicFont!,
        if (_arabicBoldFont != null) _arabicBoldFont!,
      ],
      color: color,
    );
  }

  // Generate and show Invoice PDF
  static Future<void> shareInvoicePdf(InvoiceModel invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    final filename = 'Invoice_${invoice.invoiceNumber}.pdf';

    if (kIsWeb) {
      web_platform.downloadPdf(bytes, filename);
    } else {
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
      web_platform.downloadPdf(bytes, filename);
    } else {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: filename,
      );
    }
  }

  // Helper to fetch image from backend URL (for QR code and Logo)
  static Future<Uint8List?> _fetchImageFromUrl(String? imagePath, String baseUrl) async {
    if (imagePath == null || imagePath.isEmpty) {
      debugPrint('Image path is null or empty');
      return null;
    }

    try {
      // Build full URL from path
      final fullUrl = imagePath.startsWith('http')
          ? imagePath
          : '$baseUrl$imagePath';

      debugPrint('Fetching image from: $fullUrl');

      // Try fetching without auth headers first - media files are usually public
      var response = await http.get(
        Uri.parse(fullUrl),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('Image fetch timeout');
          throw Exception('Timeout');
        },
      );

      debugPrint('Image fetch status: ${response.statusCode}');

      // If unauthorized, try with auth headers
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('Access denied, retrying with auth headers...');
        final headers = <String, String>{};
        if (ApiService.accessToken != null) {
          headers['Authorization'] = 'Bearer ${ApiService.accessToken}';
        }
        if (ApiService.sessionKey != null) {
          headers['X-Session-Key'] = ApiService.sessionKey!;
        }

        response = await http.get(
          Uri.parse(fullUrl),
          headers: headers,
        ).timeout(const Duration(seconds: 20));
      }

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final bytes = response.bodyBytes;

        debugPrint('Image content-type: $contentType, size: ${bytes.length} bytes');

        // Check image signature
        if (bytes.length >= 8) {
          final isPng = bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71;
          final isJpeg = bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255;

          if (isPng || isJpeg || contentType.contains('image')) {
            debugPrint('Valid image detected! Returning ${bytes.length} bytes');
            return bytes;
          }
        }

        // If size is reasonable and not HTML, try using it anyway
        if (bytes.length > 100 && !contentType.contains('html') && !contentType.contains('text')) {
          debugPrint('Non-text content of ${bytes.length} bytes, attempting to use as image');
          return bytes;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch image: $e');
    }
    return null;
  }

  // Helper to fetch QR code image from backend URL
  static Future<Uint8List?> _fetchQrCodeImage(String? qrCodePath, String baseUrl) async {
    if (qrCodePath == null || qrCodePath.isEmpty) {
      debugPrint('QR code path is null or empty');
      return null;
    }

    try {
      // Build full URL from path
      final fullUrl = qrCodePath.startsWith('http')
          ? qrCodePath
          : '$baseUrl$qrCodePath';

      debugPrint('Fetching QR code from: $fullUrl');

      // Try fetching without auth headers first - media files are usually public
      debugPrint('Fetching QR without auth headers (media files are usually public)...');

      var response = await http.get(
        Uri.parse(fullUrl),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('QR code fetch timeout');
          throw Exception('Timeout');
        },
      );

      debugPrint('QR code fetch status: ${response.statusCode}');
      debugPrint('QR code content-type: ${response.headers['content-type']}');
      debugPrint('QR code response length: ${response.bodyBytes.length} bytes');

      // If unauthorized, try with auth headers
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('Access denied, retrying with auth headers...');
        final headers = <String, String>{};
        if (ApiService.accessToken != null) {
          headers['Authorization'] = 'Bearer ${ApiService.accessToken}';
        }
        if (ApiService.sessionKey != null) {
          headers['X-Session-Key'] = ApiService.sessionKey!;
        }

        response = await http.get(
          Uri.parse(fullUrl),
          headers: headers,
        ).timeout(const Duration(seconds: 20));

        debugPrint('Retry with auth - status: ${response.statusCode}, length: ${response.bodyBytes.length} bytes');
      }

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final bytes = response.bodyBytes;

        debugPrint('Content-Type: $contentType');
        debugPrint('Response size: ${bytes.length} bytes');

        // Log first 8 bytes to check image signature
        if (bytes.length >= 8) {
          debugPrint('First 8 bytes: ${bytes.sublist(0, 8)}');

          // Check PNG signature: 137 80 78 71 13 10 26 10 (0x89 PNG \r\n \x1a \n)
          final isPng = bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71;
          // Check JPEG signature: 255 216 255 (0xFF 0xD8 0xFF)
          final isJpeg = bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255;

          debugPrint('Is PNG: $isPng, Is JPEG: $isJpeg');

          if (isPng || isJpeg) {
            debugPrint('Valid image detected! Returning ${bytes.length} bytes');
            return bytes;
          }
        }

        // Check if response is actually an image based on content type
        if (contentType.contains('image')) {
          debugPrint('Image content-type detected, returning ${bytes.length} bytes');
          return bytes;
        }

        // If size is reasonable and not HTML, try using it anyway
        if (bytes.length > 100 && !contentType.contains('html') && !contentType.contains('text')) {
          debugPrint('Non-text content of ${bytes.length} bytes, attempting to use as image');
          return bytes;
        }

        debugPrint('QR code response is not a valid image: $contentType');
        if (bytes.isNotEmpty && bytes.length < 200) {
          debugPrint('Response text: ${String.fromCharCodes(bytes)}');
        }
      } else {
        debugPrint('QR code fetch failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // If fetch fails, return null and fallback to generated QR
      debugPrint('Failed to fetch QR code image: $e');
    }
    return null;
  }

  // Generate Invoice PDF bytes
  static Future<Uint8List> generateInvoicePdfBytes(InvoiceModel invoice) async {
    await _loadFonts();

    final pdf = pw.Document();

    // Get company info from invoice or use defaults (handle empty strings)
    final company = invoice.company;

    // Fetch company logo image from backend if available
    Uint8List? logoImageBytes;
    debugPrint('Company logo path: ${company?.logo}');
    debugPrint('Base URL: ${ApiService.baseUrl}');
    if (company?.logo != null && company!.logo!.isNotEmpty) {
      logoImageBytes = await _fetchImageFromUrl(company.logo, ApiService.baseUrl);
      debugPrint('Logo image bytes: ${logoImageBytes?.length ?? 0}');
    } else {
      debugPrint('No logo path in company');
    }

    // Fetch payment QR code image from backend if available
    Uint8List? paymentQrImageBytes;
    debugPrint('Invoice QR code path: ${invoice.qrCode}');
    if (invoice.qrCode != null && invoice.qrCode!.isNotEmpty) {
      paymentQrImageBytes = await _fetchQrCodeImage(invoice.qrCode, ApiService.baseUrl);
      debugPrint('Payment QR image bytes: ${paymentQrImageBytes?.length ?? 0}');
    } else {
      debugPrint('No QR code path in invoice');
    }
    final companyNameEn = _nonEmpty(company?.nameEn, defaultCompanyName);
    final companyNameAr = _nonEmpty(company?.nameAr, defaultCompanyNameAr);
    final companyTaglineEn = _nonEmpty(company?.subtitleEn, defaultCompanyTagline);
    final companyTaglineAr = _nonEmpty(company?.subtitleAr, defaultCompanyTaglineAr);
    final companyVat = _nonEmpty(company?.vatNumber, defaultVatNumber);
    final companyCR = _nonEmpty(company?.crNumber, defaultCompanyCR);
    final bankName = _nonEmpty(company?.bankName, defaultBankName);
    final beneficiary = _nonEmpty(company?.beneficiary, defaultBeneficiaryName);
    final iban = _nonEmpty(company?.iban, defaultIbanNumber);

    // Calculate totals
    final subtotal = invoice.subtotal;
    final discount = invoice.discount ?? 0;
    final totalAfterDiscount = subtotal - discount;
    final vatRate = invoice.vatRate ?? 15.0;
    final vatAmount = invoice.totalTax;
    final netAmount = invoice.totalAmount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => _buildHeader(
          companyNameEn: companyNameEn,
          companyNameAr: companyNameAr,
          companyTaglineEn: companyTaglineEn,
          companyTaglineAr: companyTaglineAr,
          companyCR: companyCR,
          logoImageBytes: logoImageBytes,
        ),
        footer: (context) => _buildPageFooter(context),
        build: (context) => [
          _buildTaxInvoiceTitle(companyVat),
          pw.SizedBox(height: 10),
          _buildCustomerInfoSection(
            clientName: invoice.clientName,
            clientNameAr: invoice.clientNameAr,
            clientVatNumber: invoice.clientVatNumber,
            clientAddress: invoice.clientAddress,
            paymentMethod: invoice.paymentMethod ?? 'CASH',
            invoiceNumber: invoice.invoiceNumber,
            invoiceDate: invoice.createdAt,
            deliveryNote: invoice.deliveryNote,
            poNumber: invoice.poNumber,
            attention: invoice.attention,
            phoneNumber: invoice.phoneNumber,
            isInvoice: true,
          ),
          pw.SizedBox(height: 10),
          _buildItemsTable(
            items: invoice.items.map((item) => _ItemData(
              description: item.description,
              unit: item.unit,
              quantity: item.quantity.toDouble(),
              price: item.unitPrice,
              vatAmount: item.taxAmount,
              total: item.total,
            )).toList(),
          ),
          pw.SizedBox(height: 10),
          _buildTotalsSection(
            subtotal: subtotal,
            discount: discount,
            totalAfterDiscount: totalAfterDiscount,
            vatRate: vatRate,
            vatAmount: vatAmount,
            netAmount: netAmount,
            amountInWords: invoice.amountInWordsEn ?? _numberToWords(netAmount.round()),
            amountInWordsAr: invoice.amountInWordsAr,
          ),
          pw.SizedBox(height: 15),
          _buildBankAndQrSection(
            bankName: bankName,
            beneficiary: beneficiary,
            iban: iban,
            companyNameEn: companyNameEn,
            companyVat: companyVat,
            invoiceDate: invoice.createdAt,
            netAmount: netAmount,
            vatAmount: vatAmount,
            paymentQrCodeUrl: invoice.qrCode,
            paymentQrImageBytes: paymentQrImageBytes,
          ),
          pw.SizedBox(height: 10),
          _buildSignatureSection(),
          pw.SizedBox(height: 10),
          _buildArabicNotes(),
        ],
      ),
    );

    return pdf.save();
  }

  // Generate Estimation PDF bytes
  static Future<Uint8List> generateEstimationPdfBytes(EstimationModel estimation) async {
    await _loadFonts();

    final pdf = pw.Document();

    // Get company info from estimation or use defaults (handle empty strings)
    final company = estimation.company;

    // Fetch company logo image from backend if available
    Uint8List? logoImageBytes;
    debugPrint('Company logo path (estimation): ${company?.logo}');
    debugPrint('Base URL: ${ApiService.baseUrl}');
    if (company?.logo != null && company!.logo!.isNotEmpty) {
      logoImageBytes = await _fetchImageFromUrl(company.logo, ApiService.baseUrl);
      debugPrint('Logo image bytes (estimation): ${logoImageBytes?.length ?? 0}');
    } else {
      debugPrint('No logo path in company (estimation)');
    }

    final companyNameEn = _nonEmpty(company?.nameEn, defaultCompanyName);
    final companyNameAr = _nonEmpty(company?.nameAr, defaultCompanyNameAr);
    final companyTaglineEn = _nonEmpty(company?.subtitleEn, defaultCompanyTagline);
    final companyTaglineAr = _nonEmpty(company?.subtitleAr, defaultCompanyTaglineAr);
    final companyVat = _nonEmpty(company?.vatNumber, defaultVatNumber);
    final companyCR = _nonEmpty(company?.crNumber, defaultCompanyCR);
    final bankName = _nonEmpty(company?.bankName, defaultBankName);
    final beneficiary = _nonEmpty(company?.beneficiary, defaultBeneficiaryName);
    final iban = _nonEmpty(company?.iban, defaultIbanNumber);

    // Calculate totals
    final subtotal = estimation.subtotal;
    final discount = estimation.discount ?? 0;
    final totalAfterDiscount = subtotal - discount;
    final vatRate = estimation.vatRate ?? 15.0;
    final vatAmount = estimation.totalTax;
    final netAmount = estimation.totalAmount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => _buildHeader(
          companyNameEn: companyNameEn,
          companyNameAr: companyNameAr,
          companyTaglineEn: companyTaglineEn,
          companyTaglineAr: companyTaglineAr,
          companyCR: companyCR,
          logoImageBytes: logoImageBytes,
        ),
        footer: (context) => _buildPageFooter(context),
        build: (context) => [
          _buildQuotationTitle(companyVat),
          pw.SizedBox(height: 10),
          _buildCustomerInfoSection(
            clientName: estimation.clientName,
            clientNameAr: estimation.clientNameAr,
            clientVatNumber: estimation.clientVatNumber,
            clientAddress: estimation.clientAddress,
            paymentMethod: estimation.paymentMethod ?? 'CASH',
            invoiceNumber: estimation.estimationNumber,
            invoiceDate: estimation.createdAt,
            deliveryNote: null,
            poNumber: estimation.poNumber,
            attention: estimation.attention,
            phoneNumber: estimation.phoneNumber,
            isInvoice: false,
            validUntil: estimation.validUntil,
          ),
          pw.SizedBox(height: 10),
          _buildItemsTable(
            items: estimation.items.map((item) => _ItemData(
              description: item.description,
              unit: item.unit,
              quantity: item.quantity.toDouble(),
              price: item.unitPrice,
              vatAmount: item.taxAmount,
              total: item.total,
            )).toList(),
          ),
          pw.SizedBox(height: 10),
          _buildTotalsSection(
            subtotal: subtotal,
            discount: discount,
            totalAfterDiscount: totalAfterDiscount,
            vatRate: vatRate,
            vatAmount: vatAmount,
            netAmount: netAmount,
            amountInWords: estimation.amountInWordsEn ?? _numberToWords(netAmount.round()),
            amountInWordsAr: estimation.amountInWordsAr,
          ),
          pw.SizedBox(height: 15),
          _buildBankAndQrSection(
            bankName: bankName,
            beneficiary: beneficiary,
            iban: iban,
            companyNameEn: companyNameEn,
            companyVat: companyVat,
            invoiceDate: estimation.createdAt,
            netAmount: netAmount,
            vatAmount: vatAmount,
            showQrCode: false,
          ),
          pw.SizedBox(height: 10),
          _buildSignatureSection(),
          pw.SizedBox(height: 10),
          _buildArabicNotes(),
        ],
      ),
    );

    return pdf.save();
  }

  // Build Header Section
  static pw.Widget _buildHeader({
    required String companyNameEn,
    required String companyNameAr,
    required String companyTaglineEn,
    required String companyTaglineAr,
    required String companyCR,
    Uint8List? logoImageBytes,
  }) {
    // Build logo widget
    pw.Widget logoWidget;
    if (logoImageBytes != null && logoImageBytes.isNotEmpty) {
      try {
        final logoImage = pw.MemoryImage(logoImageBytes);
        logoWidget = pw.Image(
          logoImage,
          width: 65,
          height: 40,
          fit: pw.BoxFit.contain,
        );
        debugPrint('Logo image widget created successfully');
      } catch (e) {
        debugPrint('Error creating logo image widget: $e');
        logoWidget = pw.Text(
          'LOGO',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            font: _boldFont,
          ),
        );
      }
    } else {
      logoWidget = pw.Text(
        'LOGO',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
          font: _boldFont,
        ),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - English
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  companyNameEn,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                    font: _boldFont,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  companyTaglineEn,
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.black, font: _regularFont),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'C.R. $companyCR',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                    font: _boldFont,
                  ),
                ),
              ],
            ),
          ),
          // Center - Logo
          pw.Container(
            width: 70,
            height: 45,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(child: logoWidget),
          ),
          // Right side - Arabic
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  companyNameAr,
                  style: _arabicStyle(fontSize: 12, bold: true, color: PdfColors.black),
                  textDirection: pw.TextDirection.rtl,
                  textAlign: pw.TextAlign.right,
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  companyTaglineAr,
                  style: _arabicStyle(fontSize: 7),
                  textDirection: pw.TextDirection.rtl,
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Tax Invoice Title
  static pw.Widget _buildTaxInvoiceTitle(String vatNumber) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'TAX INVOICE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: _boldFont,
                ),
              ),
              pw.Text(
                ' / ',
                style: pw.TextStyle(fontSize: 16, font: _regularFont),
              ),
              pw.Text(
                'فاتورة ضريبية',
                style: _arabicStyle(fontSize: 14, bold: true),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'VAT NO / ',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                'رقم الضريبة',
                style: _arabicStyle(fontSize: 9),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                ': $vatNumber',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Quotation Title
  static pw.Widget _buildQuotationTitle(String vatNumber) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'QUOTATION',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: _boldFont,
                ),
              ),
              pw.Text(
                ' / ',
                style: pw.TextStyle(fontSize: 16, font: _regularFont),
              ),
              pw.Text(
                'عرض سعر',
                style: _arabicStyle(fontSize: 14, bold: true),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'VAT NO / ',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                'رقم الضريبة',
                style: _arabicStyle(fontSize: 9),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                ': $vatNumber',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Customer Info Section
  static pw.Widget _buildCustomerInfoSection({
    required String clientName,
    required String clientNameAr,
    String? clientVatNumber,
    required String clientAddress,
    required String paymentMethod,
    required String invoiceNumber,
    required DateTime invoiceDate,
    String? deliveryNote,
    String? poNumber,
    String? attention,
    String? phoneNumber,
    required bool isInvoice,
    DateTime? validUntil,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - Customer Info
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRowWithArabicValue('Customer Name', 'اسم الزبون', clientName, clientNameAr.isNotEmpty ? clientNameAr : null),
                  pw.SizedBox(height: 3),
                  _buildInfoRow('Customer VAT No.', 'رقم ضريبة الزبون', clientVatNumber ?? 'N/A'),
                  pw.SizedBox(height: 3),
                  _buildInfoRow('Address', 'عنوان', clientAddress.isEmpty ? '-' : clientAddress),
                  pw.SizedBox(height: 3),
                  _buildInfoRow('Payment', 'الدفع', paymentMethod),
                  if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    _buildInfoRow('Phone', 'رقم الهاتف', phoneNumber),
                  ],
                  if (poNumber != null && poNumber.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    _buildInfoRow('P.O No', 'رقم طلب الشراء', poNumber),
                  ],
                  if (attention != null && attention.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    _buildInfoRow('Attn.', 'عناية', attention),
                  ],
                ],
              ),
            ),
          ),
          // Vertical divider
          pw.Container(
            width: 0.5,
            color: PdfColors.black,
          ),
          // Right side - Invoice Info
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRowRight(
                    isInvoice ? 'Invoice No.' : 'Quotation No.',
                    isInvoice ? 'رقم الفاتورة' : 'رقم العرض',
                    invoiceNumber,
                  ),
                  pw.SizedBox(height: 3),
                  _buildInfoRowRight(
                    'Date',
                    'تاريخ',
                    dateFormat.format(invoiceDate),
                  ),
                  if (isInvoice && deliveryNote != null && deliveryNote.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    _buildInfoRowRight('Delivery Note', 'رقم مذكرة التسليم', deliveryNote),
                  ],
                  if (!isInvoice && validUntil != null) ...[
                    pw.SizedBox(height: 3),
                    _buildInfoRowRight('Valid Until', 'صالح حتى', dateFormat.format(validUntil)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRowWithArabicValue(String labelEn, String labelAr, String value, String? valueAr) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                labelEn,
                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                labelAr,
                style: _arabicStyle(fontSize: 7),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        pw.Text(': ', style: pw.TextStyle(fontSize: 8, font: _regularFont)),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              if (valueAr != null && valueAr.isNotEmpty)
                pw.Text(
                  valueAr,
                  style: _arabicStyle(fontSize: 7),
                  textDirection: pw.TextDirection.rtl,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String labelEn, String labelAr, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                labelEn,
                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                labelAr,
                style: _arabicStyle(fontSize: 7),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        pw.Text(': ', style: pw.TextStyle(fontSize: 8, font: _regularFont)),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: _boldFont),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRowRight(String labelEn, String labelAr, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                labelEn,
                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                labelAr,
                style: _arabicStyle(fontSize: 7),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        pw.Text(': ', style: pw.TextStyle(fontSize: 8, font: _regularFont)),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: _boldFont),
          ),
        ),
      ],
    );
  }

  // Build Items Table
  static pw.Widget _buildItemsTable({required List<_ItemData> items}) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),  // No.
        1: const pw.FlexColumnWidth(3.5),  // Description
        2: const pw.FlexColumnWidth(0.7),  // Unit
        3: const pw.FlexColumnWidth(0.7),  // Qty
        4: const pw.FlexColumnWidth(1),    // Price
        5: const pw.FlexColumnWidth(0.9),  // VAT Amt
        6: const pw.FlexColumnWidth(1.2),  // Total
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableHeaderCell('No.', 'الرقم'),
            _buildTableHeaderCell('Description', 'البيان'),
            _buildTableHeaderCell('Unit', 'وحدة'),
            _buildTableHeaderCell('Qty', 'الكمية'),
            _buildTableHeaderCell('Price', 'السعر'),
            _buildTableHeaderCell('VAT Amt', 'المبلغ ضريبة'),
            _buildTableHeaderCell('Total Amount', 'الإجمالى'),
          ],
        ),
        // Data rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableDataCell('${index + 1}', center: true),
              _buildTableDataCell(item.description),
              _buildTableDataCell(item.unit, center: true),
              _buildTableDataCell(item.quantity.toStringAsFixed(2), center: true),
              _buildTableDataCell(currencyFormat.format(item.price), center: true),
              _buildTableDataCell(currencyFormat.format(item.vatAmount), center: true),
              _buildTableDataCell(currencyFormat.format(item.total), center: true),
            ],
          );
        }),
        // Empty rows for minimum display
        if (items.length < 3)
          ...List.generate(3 - items.length, (index) => pw.TableRow(
            children: [
              _buildTableDataCell(''),
              _buildTableDataCell(''),
              _buildTableDataCell(''),
              _buildTableDataCell(''),
              _buildTableDataCell(''),
              _buildTableDataCell(''),
              _buildTableDataCell(''),
            ],
          )),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String textEn, String textAr) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: pw.Column(
        children: [
          pw.Text(
            textEn,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, font: _boldFont),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            textAr,
            style: _arabicStyle(fontSize: 7),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableDataCell(String text, {bool center = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, font: _regularFont),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  // Build Totals Section
  static pw.Widget _buildTotalsSection({
    required double subtotal,
    required double discount,
    required double totalAfterDiscount,
    required double vatRate,
    required double vatAmount,
    required double netAmount,
    required String amountInWords,
    String? amountInWordsAr,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Amount in words - left side
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Amount in Words:',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: _boldFont),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '$amountInWords Only.',
                  style: pw.TextStyle(fontSize: 8, font: _regularFont),
                ),
                if (amountInWordsAr != null && amountInWordsAr.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    amountInWordsAr,
                    style: _arabicStyle(fontSize: 8),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        // Totals - right side
        pw.Container(
          width: 200,
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
            },
            children: [
              _buildTotalRow('Total:', 'المجموع/', subtotal),
              _buildTotalRow('Discount:', 'الخصم/', discount),
              _buildTotalRow('Total Amt:', 'الإجمالى/', totalAfterDiscount),
              _buildTotalRow('VAT ${vatRate.toStringAsFixed(0)}%:', 'الضريبة/', vatAmount),
              _buildTotalRowBold('Net Amount:', 'المبلغ الإجمالي/', netAmount),
            ],
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildTotalRow(String labelEn, String labelAr, double amount) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labelEn,
                style: pw.TextStyle(fontSize: 8, font: _regularFont),
              ),
              pw.Text(
                labelAr,
                style: _arabicStyle(fontSize: 8),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: pw.Text(
            currencyFormat.format(amount),
            style: pw.TextStyle(fontSize: 8, font: _regularFont),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildTotalRowBold(String labelEn, String labelAr, double amount) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labelEn,
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                labelAr,
                style: _arabicStyle(fontSize: 8, bold: true),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: pw.Text(
            currencyFormat.format(amount),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Build Bank Details and QR Code Section
  static pw.Widget _buildBankAndQrSection({
    required String bankName,
    required String beneficiary,
    required String iban,
    required String companyNameEn,
    required String companyVat,
    required DateTime invoiceDate,
    required double netAmount,
    required double vatAmount,
    String? paymentQrCodeUrl,
    Uint8List? paymentQrImageBytes,
    bool showQrCode = true,
  }) {
    // Generate fallback QR code with IBAN info if backend image not available
    pw.Widget qrWidget;
    if (paymentQrImageBytes != null && paymentQrImageBytes.isNotEmpty) {
      // Use backend QR image - ensure it displays properly
      debugPrint('Using backend QR image: ${paymentQrImageBytes.length} bytes');

      // Check image signature
      final isPng = paymentQrImageBytes.length > 8 &&
          paymentQrImageBytes[0] == 137 &&
          paymentQrImageBytes[1] == 80 &&
          paymentQrImageBytes[2] == 78 &&
          paymentQrImageBytes[3] == 71;
      final isJpeg = paymentQrImageBytes.length > 3 &&
          paymentQrImageBytes[0] == 255 &&
          paymentQrImageBytes[1] == 216 &&
          paymentQrImageBytes[2] == 255;

      debugPrint('Image format - PNG: $isPng, JPEG: $isJpeg');
      if (paymentQrImageBytes.length >= 8) {
        debugPrint('First 8 bytes: ${paymentQrImageBytes.sublist(0, 8)}');
      }

      if (isPng || isJpeg) {
        try {
          // Create image from bytes using MemoryImage
          final qrImage = pw.MemoryImage(paymentQrImageBytes);

          // Use Image widget with explicit fit to ensure proper rendering
          qrWidget = pw.Image(
            qrImage,
            width: 75,
            height: 75,
            fit: pw.BoxFit.contain,
          );
          debugPrint('QR image widget created successfully from ${isPng ? "PNG" : "JPEG"} data');
        } catch (e) {
          debugPrint('Error creating QR image widget: $e');
          // Fallback to generated QR
          final qrData = 'IBAN: $iban\nBeneficiary: $beneficiary\nBank: $bankName\nAmount: ${currencyFormat.format(netAmount)} SAR';
          qrWidget = pw.BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: qrData,
            width: 75,
            height: 75,
          );
        }
      } else {
        // Try to use it anyway - might be valid image with different signature
        debugPrint('Unknown image format, attempting to use anyway...');
        try {
          final qrImage = pw.MemoryImage(paymentQrImageBytes);
          qrWidget = pw.Image(
            qrImage,
            width: 75,
            height: 75,
            fit: pw.BoxFit.contain,
          );
          debugPrint('QR image widget created from unknown format');
        } catch (e) {
          debugPrint('Failed to create image from unknown format: $e');
          final qrData = 'IBAN: $iban\nBeneficiary: $beneficiary\nBank: $bankName\nAmount: ${currencyFormat.format(netAmount)} SAR';
          qrWidget = pw.BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: qrData,
            width: 75,
            height: 75,
          );
        }
      }
    } else {
      // Generate QR code with payment info as fallback
      final qrData = 'IBAN: $iban\nBeneficiary: $beneficiary\nBank: $bankName\nAmount: ${currencyFormat.format(netAmount)} SAR';
      debugPrint('Generating fallback QR with IBAN data (no backend QR available)');
      qrWidget = pw.BarcodeWidget(
        barcode: Barcode.qrCode(),
        data: qrData,
        width: 75,
        height: 75,
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bank Details
        pw.Expanded(
          flex: showQrCode ? 2 : 1,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bank Details:-',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: _boldFont),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Bank: $bankName',
                  style: pw.TextStyle(fontSize: 8, font: _regularFont),
                ),
                pw.Text(
                  'Beneficiary: $beneficiary',
                  style: pw.TextStyle(fontSize: 8, font: _regularFont),
                ),
                pw.Text(
                  'IBAN: $iban',
                  style: pw.TextStyle(fontSize: 8, font: _regularFont),
                ),
              ],
            ),
          ),
        ),
        // Payment QR Code - only show for invoices
        if (showQrCode) ...[
          pw.SizedBox(width: 10),
          pw.Container(
            width: 90,
            child: pw.Column(
              children: [
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  ),
                  child: pw.Center(child: qrWidget),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Payment QR',
                  style: pw.TextStyle(fontSize: 6, font: _regularFont),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Build Signature Section
  static pw.Widget _buildSignatureSection() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Row(
        children: [
          // Receiver Signature
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Receiver sign.',
                        style: pw.TextStyle(fontSize: 8, font: _regularFont),
                      ),
                      pw.Text(
                        ' / ',
                        style: pw.TextStyle(fontSize: 8, font: _regularFont),
                      ),
                      pw.Text(
                        'التوقيع المستلم',
                        style: _arabicStyle(fontSize: 8),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 25),
                  pw.Container(
                    width: 100,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Vertical divider
          pw.Container(width: 0.5, height: 60, color: PdfColors.black),
          // Seller Signature
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Seller sign.',
                        style: pw.TextStyle(fontSize: 8, font: _regularFont),
                      ),
                      pw.Text(
                        ' / ',
                        style: pw.TextStyle(fontSize: 8, font: _regularFont),
                      ),
                      pw.Text(
                        'توقيع البائع',
                        style: _arabicStyle(fontSize: 8),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 25),
                  pw.Container(
                    width: 100,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Arabic Notes
  static pw.Widget _buildArabicNotes() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Note:',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: _boldFont),
              ),
              pw.Text(
                ' / ',
                style: pw.TextStyle(fontSize: 8, font: _regularFont),
              ),
              pw.Text(
                'الملاحظة',
                style: _arabicStyle(fontSize: 8, bold: true),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'المحل غير مسئول عن البضاعة بعد استلامها',
            style: _arabicStyle(fontSize: 8),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Shop is not responsible for goods after delivery.',
            style: pw.TextStyle(fontSize: 7, font: _regularFont, color: PdfColors.black),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'المحل غير مسئول عن البضاعة التي لا يتم استلامها خلال شهرين',
            style: _arabicStyle(fontSize: 8),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Shop is not responsible for goods not collected within two months.',
            style: pw.TextStyle(fontSize: 7, font: _regularFont, color: PdfColors.black),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build Page Footer
  static pw.Widget _buildPageFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'E-mail: $defaultCompanyEmail  |  Tel: $defaultCompanyPhone',
            style: pw.TextStyle(fontSize: 7, font: _regularFont, color: PdfColors.black),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 7, font: _regularFont, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  // Number to words conversion
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

// Helper class for item data
class _ItemData {
  final String description;
  final String unit;
  final double quantity;
  final double price;
  final double vatAmount;
  final double total;

  _ItemData({
    required this.description,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.vatAmount,
    required this.total,
  });
}
