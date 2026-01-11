class CompanyModel {
  final String id;
  final String nameEn;
  final String? nameAr;
  final String subtitleEn;
  final String? subtitleAr;
  final String crNumber;
  final String vatNumber;
  final String vat;
  final String bankName;
  final String beneficiary;
  final String iban;
  final String contactPerson;
  final String contactNumber;
  final String? currency;
  final String? addressEn;
  final String? addressAr;
  final String? logo;
  final String? postalCode;
  final String? city;
  final String? country;

  CompanyModel({
    required this.id,
    required this.nameEn,
    this.nameAr,
    required this.subtitleEn,
    this.subtitleAr,
    required this.crNumber,
    required this.vatNumber,
    required this.vat,
    required this.bankName,
    required this.beneficiary,
    required this.iban,
    required this.contactPerson,
    required this.contactNumber,
    this.currency,
    this.addressEn,
    this.addressAr,
    this.logo,
    this.postalCode,
    this.city,
    this.country,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      subtitleEn: json['subtitle_en']?.toString() ?? '',
      subtitleAr: json['subtitle_ar']?.toString(),
      crNumber: json['cr_number']?.toString() ?? '',
      vatNumber: json['vat_number']?.toString() ?? '',
      vat: json['vat']?.toString() ?? '15.00',
      bankName: json['bank_name']?.toString() ?? '',
      beneficiary: json['beneficiary']?.toString() ?? '',
      iban: json['iban']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      currency: json['currency']?.toString(),
      addressEn: json['address_en']?.toString(),
      addressAr: json['address_ar']?.toString(),
      logo: json['logo']?.toString(),
      postalCode: json['postal_code']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name_en': nameEn,
      'subtitle_en': subtitleEn,
      'cr_number': crNumber,
      'vat_number': vatNumber,
      'vat': vat,
      'bank_name': bankName,
      'beneficiary': beneficiary,
      'iban': iban,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
    };

    // Add optional fields if provided
    if (nameAr != null && nameAr!.isNotEmpty) {
      json['name_ar'] = nameAr;
    }
    if (subtitleAr != null && subtitleAr!.isNotEmpty) {
      json['subtitle_ar'] = subtitleAr;
    }
    if (currency != null && currency!.isNotEmpty) {
      json['currency'] = currency;
    }
    if (addressEn != null && addressEn!.isNotEmpty) {
      json['address_en'] = addressEn;
    }
    if (addressAr != null && addressAr!.isNotEmpty) {
      json['address_ar'] = addressAr;
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      json['postal_code'] = postalCode;
    }
    if (city != null && city!.isNotEmpty) {
      json['city'] = city;
    }
    if (country != null && country!.isNotEmpty) {
      json['country'] = country;
    }

    return json;
  }

  CompanyModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? subtitleEn,
    String? subtitleAr,
    String? crNumber,
    String? vatNumber,
    String? vat,
    String? bankName,
    String? beneficiary,
    String? iban,
    String? contactPerson,
    String? contactNumber,
    String? currency,
    String? addressEn,
    String? addressAr,
    String? logo,
    String? postalCode,
    String? city,
    String? country,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleAr: subtitleAr ?? this.subtitleAr,
      crNumber: crNumber ?? this.crNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      vat: vat ?? this.vat,
      bankName: bankName ?? this.bankName,
      beneficiary: beneficiary ?? this.beneficiary,
      iban: iban ?? this.iban,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      currency: currency ?? this.currency,
      addressEn: addressEn ?? this.addressEn,
      addressAr: addressAr ?? this.addressAr,
      logo: logo ?? this.logo,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}
