// Company model for estimation details (reuse from invoice)
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

class EstimationItem {
  final String id;
  final String description;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double taxRate;
  final double? itemTotal; // Total from API
  final double? apiVatAmount; // VAT amount from API

  EstimationItem({
    required this.id,
    required this.description,
    required this.quantity,
    this.unit = 'unit',
    required this.unitPrice,
    this.taxRate = 0,
    this.itemTotal,
    this.apiVatAmount,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => apiVatAmount ?? (subtotal * (taxRate / 100));
  double get total => itemTotal ?? (subtotal + taxAmount);

  EstimationItem copyWith({
    String? id,
    String? description,
    int? quantity,
    String? unit,
    double? unitPrice,
    double? taxRate,
    double? itemTotal,
    double? apiVatAmount,
  }) {
    return EstimationItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      itemTotal: itemTotal ?? this.itemTotal,
      apiVatAmount: apiVatAmount ?? this.apiVatAmount,
    );
  }

  factory EstimationItem.fromJson(Map<String, dynamic> json) {
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

    // Parse VAT amount from API
    double? apiVatAmount;
    if (json['vat_amount'] != null) {
      apiVatAmount = double.tryParse(json['vat_amount'].toString());
    }

    return EstimationItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      description: json['description'] ?? json['name'] ?? '',
      quantity: qty,
      unit: json['unit']?.toString() ?? 'unit',
      unitPrice: price,
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0,
      itemTotal: itemTotal,
      apiVatAmount: apiVatAmount,
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

class EstimationModel {
  final String id;
  final String estimationNumber;
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
  final String? phoneNumber;
  final String? paymentMethod;
  final String? poNumber;
  final String? attention;
  final List<EstimationItem> items;
  final DateTime createdAt;
  final DateTime validUntil;
  final String status;
  final String? notes;
  final String? notesAr;

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

  EstimationModel({
    required this.id,
    required this.estimationNumber,
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
    this.phoneNumber,
    this.paymentMethod,
    this.poNumber,
    this.attention,
    required this.items,
    required this.createdAt,
    required this.validUntil,
    this.status = 'pending',
    this.notes,
    this.notesAr,
    this.company,
    this.apiSubtotal,
    this.vatRate,
    this.vatAmount,
    this.apiTotal,
    this.discount,
    this.roundOff,
    this.amountInWordsAr,
    this.amountInWordsEn,
  });

  // Use API values if available, otherwise calculate
  double get subtotal => apiSubtotal ?? items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalTax => vatAmount ?? items.fold(0, (sum, item) => sum + item.taxAmount);
  double get totalAmount => apiTotal ?? items.fold(0, (sum, item) => sum + item.total);

  EstimationModel copyWith({
    String? id,
    String? estimationNumber,
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
    String? phoneNumber,
    String? paymentMethod,
    String? poNumber,
    String? attention,
    List<EstimationItem>? items,
    DateTime? createdAt,
    DateTime? validUntil,
    String? status,
    String? notes,
    String? notesAr,
    CompanyInfo? company,
    double? apiSubtotal,
    double? vatRate,
    double? vatAmount,
    double? apiTotal,
    double? discount,
    double? roundOff,
    String? amountInWordsAr,
    String? amountInWordsEn,
  }) {
    return EstimationModel(
      id: id ?? this.id,
      estimationNumber: estimationNumber ?? this.estimationNumber,
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      poNumber: poNumber ?? this.poNumber,
      attention: attention ?? this.attention,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      notesAr: notesAr ?? this.notesAr,
      company: company ?? this.company,
      apiSubtotal: apiSubtotal ?? this.apiSubtotal,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      apiTotal: apiTotal ?? this.apiTotal,
      discount: discount ?? this.discount,
      roundOff: roundOff ?? this.roundOff,
      amountInWordsAr: amountInWordsAr ?? this.amountInWordsAr,
      amountInWordsEn: amountInWordsEn ?? this.amountInWordsEn,
    );
  }

  factory EstimationModel.fromJson(Map<String, dynamic> json) {
    List<EstimationItem> itemsList = [];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => EstimationItem.fromJson(item))
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
    } else if (json['estimate_date'] != null) {
      createdAt = DateTime.parse(json['estimate_date']);
    } else if (json['quotation_date'] != null) {
      createdAt = DateTime.parse(json['quotation_date']);
    }

    DateTime validUntil = DateTime.now().add(const Duration(days: 15));
    if (json['valid_until'] != null) {
      validUntil = DateTime.parse(json['valid_until']);
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

    return EstimationModel(
      id: json['id']?.toString() ?? '',
      estimationNumber: json['estimate_number']?.toString() ??
                        json['quotation_number']?.toString() ??
                        json['ref_number']?.toString() ?? '',
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
      phoneNumber: json['phone_number']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      poNumber: json['po_number']?.toString(),
      attention: json['attention']?.toString(),
      items: itemsList,
      createdAt: createdAt,
      validUntil: validUntil,
      status: json['status']?.toString() ?? 'pending',
      notes: notes,
      notesAr: notesAr,
      company: company,
      apiSubtotal: double.tryParse(json['subtotal']?.toString() ?? ''),
      vatRate: double.tryParse(json['vat_rate']?.toString() ?? ''),
      vatAmount: double.tryParse(json['vat_amount']?.toString() ?? ''),
      apiTotal: double.tryParse(json['total']?.toString() ?? ''),
      discount: double.tryParse(json['discount']?.toString() ?? ''),
      roundOff: double.tryParse(json['round_off']?.toString() ?? ''),
      amountInWordsAr: json['amount_in_words_ar']?.toString(),
      amountInWordsEn: json['amount_in_words_en']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // Send fields matching API POST format
    final json = <String, dynamic>{
      'client_name_en': clientName,
      'subject_en': notes ?? 'Quotation for services',
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
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      json['phone_number'] = phoneNumber;
    }

    return json;
  }
}
