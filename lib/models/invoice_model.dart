class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double taxRate;
  final double? itemTotal; // Total from API

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    this.unit = 'unit',
    required this.unitPrice,
    this.taxRate = 0,
    this.itemTotal,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => itemTotal ?? (subtotal + taxAmount);

  InvoiceItem copyWith({
    String? id,
    String? description,
    int? quantity,
    String? unit,
    double? unitPrice,
    double? taxRate,
    double? itemTotal,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      itemTotal: itemTotal ?? this.itemTotal,
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    // Parse quantity - handle both int and string from API
    int qty = 1;
    if (json['quantity'] != null) {
      final qtyStr = json['quantity'].toString();
      // Handle decimal strings like "1.00"
      qty = double.tryParse(qtyStr)?.toInt() ?? 1;
    }

    // Parse unit price
    double price = 0;
    if (json['unit_price'] != null) {
      price = double.tryParse(json['unit_price'].toString()) ?? 0;
    } else if (json['price'] != null) {
      price = double.tryParse(json['price'].toString()) ?? 0;
    }

    // Parse item total from API
    double? itemTotal;
    if (json['total'] != null) {
      itemTotal = double.tryParse(json['total'].toString());
    }

    return InvoiceItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      description: json['description'] ?? json['name'] ?? '',
      quantity: qty,
      unit: json['unit']?.toString() ?? 'unit',
      unitPrice: price,
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0,
      itemTotal: itemTotal,
    );
  }

  Map<String, dynamic> toJson() {
    // Use numbers for PUT/PATCH API calls
    return {
      'description': description,
      'quantity': quantity.toDouble(),
      'unit': unit,
      'unit_price': unitPrice,
    };
  }
}

// Company model for invoice details
class CompanyInfo {
  final String id;
  final String nameEn;
  final String nameAr;
  final String subtitleEn;
  final String subtitleAr;
  final String crNumber;
  final String vatNumber;
  final String vat;
  final String bankName;
  final String beneficiary;
  final String iban;
  final String contactPerson;
  final String contactNumber;
  final String? logo;

  CompanyInfo({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.crNumber,
    required this.vatNumber,
    required this.vat,
    required this.bankName,
    required this.beneficiary,
    required this.iban,
    required this.contactPerson,
    required this.contactNumber,
    this.logo,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      subtitleEn: json['subtitle_en']?.toString() ?? '',
      subtitleAr: json['subtitle_ar']?.toString() ?? '',
      crNumber: json['cr_number']?.toString() ?? '',
      vatNumber: json['vat_number']?.toString() ?? '',
      vat: json['vat']?.toString() ?? '0',
      bankName: json['bank_name']?.toString() ?? '',
      beneficiary: json['beneficiary']?.toString() ?? '',
      iban: json['iban']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String? estimationId;
  final String clientName;
  final String clientNameAr;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;
  final String clientAddressAr;
  final String? clientVatNumber;
  final String? clientPostalCode;
  final String? clientCity;
  final String? clientCountry;
  final String? paymentMethod;
  final String? deliveryNote;
  final String? poNumber;
  final String? attention;
  final List<InvoiceItem> items;
  final DateTime createdAt;
  final DateTime dueDate;
  final String status;
  final String? notes;
  final String? notesAr;
  final double? paidAmount;

  // New fields from API
  final CompanyInfo? company;
  final double? apiSubtotal;
  final double? vatRate;
  final double? vatAmount;
  final double? apiTotal;
  final double? discount;
  final double? roundOff;
  final String? amountInWordsAr;
  final String? amountInWordsEn;

  // QR Code and Payment fields
  final String? qrCode;
  final DateTime? qrExpiration;
  final String? paymentStatus;
  final DateTime? paymentDate;
  final String? transactionId;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.estimationId,
    required this.clientName,
    this.clientNameAr = '',
    required this.clientEmail,
    required this.clientPhone,
    required this.clientAddress,
    this.clientAddressAr = '',
    this.clientVatNumber,
    this.clientPostalCode,
    this.clientCity,
    this.clientCountry,
    this.paymentMethod,
    this.deliveryNote,
    this.poNumber,
    this.attention,
    required this.items,
    required this.createdAt,
    required this.dueDate,
    this.status = 'unpaid',
    this.notes,
    this.notesAr,
    this.paidAmount,
    this.company,
    this.apiSubtotal,
    this.vatRate,
    this.vatAmount,
    this.apiTotal,
    this.discount,
    this.roundOff,
    this.amountInWordsAr,
    this.amountInWordsEn,
    this.qrCode,
    this.qrExpiration,
    this.paymentStatus,
    this.paymentDate,
    this.transactionId,
  });

  // Use API values if available, otherwise calculate
  double get subtotal => apiSubtotal ?? items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalTax => vatAmount ?? items.fold(0, (sum, item) => sum + item.taxAmount);
  double get totalAmount => apiTotal ?? items.fold(0, (sum, item) => sum + item.total);
  double get balance => totalAmount - (paidAmount ?? 0);

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? estimationId,
    String? clientName,
    String? clientNameAr,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? clientAddressAr,
    String? clientVatNumber,
    String? clientPostalCode,
    String? clientCity,
    String? clientCountry,
    String? paymentMethod,
    String? deliveryNote,
    String? poNumber,
    String? attention,
    List<InvoiceItem>? items,
    DateTime? createdAt,
    DateTime? dueDate,
    String? status,
    String? notes,
    String? notesAr,
    double? paidAmount,
    CompanyInfo? company,
    double? apiSubtotal,
    double? vatRate,
    double? vatAmount,
    double? apiTotal,
    double? discount,
    double? roundOff,
    String? amountInWordsAr,
    String? amountInWordsEn,
    String? qrCode,
    DateTime? qrExpiration,
    String? paymentStatus,
    DateTime? paymentDate,
    String? transactionId,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      estimationId: estimationId ?? this.estimationId,
      clientName: clientName ?? this.clientName,
      clientNameAr: clientNameAr ?? this.clientNameAr,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      clientAddressAr: clientAddressAr ?? this.clientAddressAr,
      clientVatNumber: clientVatNumber ?? this.clientVatNumber,
      clientPostalCode: clientPostalCode ?? this.clientPostalCode,
      clientCity: clientCity ?? this.clientCity,
      clientCountry: clientCountry ?? this.clientCountry,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      poNumber: poNumber ?? this.poNumber,
      attention: attention ?? this.attention,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      notesAr: notesAr ?? this.notesAr,
      paidAmount: paidAmount ?? this.paidAmount,
      company: company ?? this.company,
      apiSubtotal: apiSubtotal ?? this.apiSubtotal,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      apiTotal: apiTotal ?? this.apiTotal,
      discount: discount ?? this.discount,
      roundOff: roundOff ?? this.roundOff,
      amountInWordsAr: amountInWordsAr ?? this.amountInWordsAr,
      amountInWordsEn: amountInWordsEn ?? this.amountInWordsEn,
      qrCode: qrCode ?? this.qrCode,
      qrExpiration: qrExpiration ?? this.qrExpiration,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    List<InvoiceItem> itemsList = [];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList();
    }

    // Parse company info
    CompanyInfo? company;
    if (json['company'] != null && json['company'] is Map) {
      company = CompanyInfo.fromJson(json['company']);
    }

    // Parse client info - API may have client as nested object or direct fields
    String clientName = '';
    String clientNameAr = '';
    String clientEmail = '';
    String clientPhone = '';
    String clientAddress = '';
    String clientAddressAr = '';
    String? clientVatNumber;
    String? clientPostalCode;
    String? clientCity;
    String? clientCountry;

    if (json['client'] != null && json['client'] is Map) {
      // Client is nested object
      final client = json['client'] as Map<String, dynamic>;
      // Handle multilingual name format {en: "...", ar: "..."}
      final clientNameField = client['name_en'] ?? client['name'];
      if (clientNameField is Map) {
        clientName = clientNameField['en']?.toString() ?? clientNameField['ar']?.toString() ?? '';
      } else {
        clientName = clientNameField?.toString() ?? '';
      }
      clientNameAr = client['name_ar']?.toString() ?? '';
      clientEmail = client['email']?.toString() ?? '';
      clientPhone = client['phone']?.toString() ?? '';
      clientAddress = client['address_en']?.toString() ?? client['address']?.toString() ?? '';
      clientAddressAr = client['address_ar']?.toString() ?? '';
      clientVatNumber = client['vat_number']?.toString();
      clientPostalCode = client['postal_code']?.toString();
      clientCity = client['city']?.toString();
      clientCountry = client['country']?.toString();
    } else {
      // Client info is in direct fields - handle multilingual format
      final nameField = json['client_name_en'] ?? json['client_name'];
      if (nameField is String) {
        clientName = nameField;
      } else if (nameField is Map) {
        // Handle {en: "...", ar: "..."} format
        clientName = nameField['en']?.toString() ?? nameField['ar']?.toString() ?? '';
      } else if (nameField != null) {
        clientName = nameField.toString();
      }
      clientNameAr = json['client_name_ar']?.toString() ?? '';
      clientEmail = json['client_email']?.toString() ?? '';
      clientPhone = json['client_phone']?.toString() ?? '';
      clientAddress = json['client_address_en']?.toString() ?? json['client_address']?.toString() ?? '';
      clientAddressAr = json['client_address_ar']?.toString() ?? '';
      clientVatNumber = json['client_vat_number']?.toString();
      clientPostalCode = json['client_postal_code']?.toString();
      clientCity = json['client_city']?.toString();
      clientCountry = json['client_country']?.toString();
    }

    // Parse dates - handle multiple formats
    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at']);
    } else if (json['invoice_date'] != null) {
      createdAt = DateTime.parse(json['invoice_date']);
    }

    DateTime dueDate = DateTime.now().add(const Duration(days: 30));
    if (json['due_date'] != null) {
      dueDate = DateTime.parse(json['due_date']);
    } else if (json['invoice_date'] != null) {
      // If no due_date, set it to 30 days after invoice_date
      dueDate = DateTime.parse(json['invoice_date']).add(const Duration(days: 30));
    }

    // Safely extract notes/subject - ensure it's a string
    String? notes;
    final notesField = json['notes'] ?? json['subject_en'] ?? json['terms_en'];
    if (notesField is String) {
      notes = notesField;
    } else if (notesField != null && notesField is! Map) {
      notes = notesField.toString();
    }

    String? notesAr;
    final notesArField = json['subject_ar'] ?? json['terms_ar'];
    if (notesArField is String) {
      notesAr = notesArField;
    } else if (notesArField != null && notesArField is! Map) {
      notesAr = notesArField.toString();
    }

    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? json['ref_number']?.toString() ?? '',
      estimationId: json['estimation_id']?.toString(),
      clientName: clientName,
      clientNameAr: clientNameAr,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      clientAddress: clientAddress,
      clientAddressAr: clientAddressAr,
      clientVatNumber: clientVatNumber,
      clientPostalCode: clientPostalCode,
      clientCity: clientCity,
      clientCountry: clientCountry,
      paymentMethod: json['payment_method']?.toString(),
      deliveryNote: json['delivery_note']?.toString(),
      poNumber: json['po_number']?.toString(),
      attention: json['attention']?.toString(),
      items: itemsList,
      createdAt: createdAt,
      dueDate: dueDate,
      status: json['status']?.toString() ?? 'unpaid',
      notes: notes,
      notesAr: notesAr,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0'),
      company: company,
      apiSubtotal: double.tryParse(json['subtotal']?.toString() ?? ''),
      vatRate: double.tryParse(json['vat_rate']?.toString() ?? ''),
      vatAmount: double.tryParse(json['vat_amount']?.toString() ?? ''),
      apiTotal: double.tryParse(json['total']?.toString() ?? ''),
      discount: double.tryParse(json['discount']?.toString() ?? ''),
      roundOff: double.tryParse(json['round_off']?.toString() ?? ''),
      amountInWordsAr: json['amount_in_words_ar']?.toString(),
      amountInWordsEn: json['amount_in_words_en']?.toString(),
      // Check both qr_code and qr_code_url fields
      qrCode: json['qr_code']?.toString() ?? json['qr_code_url']?.toString(),
      qrExpiration: json['qr_expiration'] != null ? DateTime.tryParse(json['qr_expiration'].toString()) : null,
      paymentStatus: json['payment_status']?.toString(),
      paymentDate: json['payment_date'] != null ? DateTime.tryParse(json['payment_date'].toString()) : null,
      transactionId: json['transaction_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // Send fields matching API POST format
    final json = <String, dynamic>{
      'client_name_en': clientName,
      'subject_en': notes ?? 'Invoice for services',
      'items': items.map((item) => item.toJson()).toList(),
    };

    // Add optional client fields if provided
    if (clientAddress.isNotEmpty) {
      json['client_address_en'] = clientAddress;
    }
    if (clientVatNumber != null && clientVatNumber!.isNotEmpty) {
      json['client_vat_number'] = clientVatNumber;
    }
    if (clientPostalCode != null && clientPostalCode!.isNotEmpty) {
      json['client_postal_code'] = clientPostalCode;
    }
    if (clientCity != null && clientCity!.isNotEmpty) {
      json['client_city'] = clientCity;
    }
    if (clientCountry != null && clientCountry!.isNotEmpty) {
      json['client_country'] = clientCountry;
    }
    if (discount != null && discount! > 0) {
      json['discount'] = discount!.toStringAsFixed(2);
    }

    return json;
  }
}
