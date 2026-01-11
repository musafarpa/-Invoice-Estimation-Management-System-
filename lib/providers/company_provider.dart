import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/company_model.dart';
import '../services/api_service.dart';

class CompanyProvider with ChangeNotifier {
  List<CompanyModel> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CompanyModel> get companies => List.unmodifiable(_companies);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get companyCount => _companies.length;

  CompanyModel? getCompanyById(String id) {
    try {
      return _companies.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch all companies from API
  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.post('/invoice/company-list/', {});

    debugPrint('Company list response success: ${response.success}');
    debugPrint('Company list response data type: ${response.data?.runtimeType}');

    if (response.success && response.data != null) {
      _companies = [];
      List<dynamic> companiesData = [];

      if (response.data is List) {
        companiesData = response.data;
        debugPrint('Company data is List with ${companiesData.length} items');
      } else if (response.data is Map) {
        final mapData = response.data as Map<String, dynamic>;
        if (mapData['data'] != null && mapData['data'] is List) {
          companiesData = mapData['data'] as List;
          debugPrint('Company data from "data" key with ${companiesData.length} items');
        } else if (mapData['results'] != null && mapData['results'] is List) {
          companiesData = mapData['results'] as List;
          debugPrint('Company data from "results" key with ${companiesData.length} items');
        } else if (mapData['companies'] != null && mapData['companies'] is List) {
          companiesData = mapData['companies'] as List;
          debugPrint('Company data from "companies" key with ${companiesData.length} items');
        } else {
          debugPrint('Unknown company response format. Keys: ${mapData.keys}');
        }
      }

      debugPrint('Processing ${companiesData.length} companies');
      for (var companyData in companiesData) {
        try {
          final data = companyData['company'] ?? companyData;
          _companies.add(CompanyModel.fromJson(data));
        } catch (e) {
          debugPrint('Error parsing company: $e');
          debugPrint('Company data: $companyData');
        }
      }
      debugPrint('Successfully loaded ${_companies.length} companies');
    } else {
      _errorMessage = response.message;
      debugPrint('Error fetching companies: ${response.message}');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Convert CompanyModel to Map<String, String> for multipart request
  Map<String, String> _companyToFields(CompanyModel company) {
    final fields = <String, String>{
      'name_en': company.nameEn,
      'subtitle_en': company.subtitleEn,
      'cr_number': company.crNumber,
      'vat_number': company.vatNumber,
      'vat': company.vat,
      'bank_name': company.bankName,
      'beneficiary': company.beneficiary,
      'iban': company.iban,
      'contact_person': company.contactPerson,
      'contact_number': company.contactNumber,
    };

    // Add optional fields
    if (company.nameAr != null && company.nameAr!.isNotEmpty) {
      fields['name_ar'] = company.nameAr!;
    }
    if (company.subtitleAr != null && company.subtitleAr!.isNotEmpty) {
      fields['subtitle_ar'] = company.subtitleAr!;
    }
    if (company.currency != null && company.currency!.isNotEmpty) {
      fields['currency'] = company.currency!;
    }
    if (company.addressEn != null && company.addressEn!.isNotEmpty) {
      fields['address_en'] = company.addressEn!;
    }
    if (company.addressAr != null && company.addressAr!.isNotEmpty) {
      fields['address_ar'] = company.addressAr!;
    }
    if (company.postalCode != null && company.postalCode!.isNotEmpty) {
      fields['postal_code'] = company.postalCode!;
    }
    if (company.city != null && company.city!.isNotEmpty) {
      fields['city'] = company.city!;
    }
    if (company.country != null && company.country!.isNotEmpty) {
      fields['country'] = company.country!;
    }

    return fields;
  }

  // Add company via API
  Future<bool> addCompany(CompanyModel company, {XFile? logoFile, Uint8List? logoBytes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ApiResponse response;

      if (logoFile != null) {
        // Read bytes from file for web compatibility
        final bytes = logoBytes ?? await logoFile.readAsBytes();
        // Use multipart request for file upload
        response = await ApiService.postMultipart(
          '/invoice/company/',
          _companyToFields(company),
          fileFieldName: 'logo',
          fileBytes: bytes,
          fileName: logoFile.name,
        );
      } else {
        // Use regular JSON request
        response = await ApiService.post('/invoice/company/', company.toJson());
      }

      if (response.success) {
        if (response.data != null) {
          final companyData = response.data['data'] ?? response.data['company'] ?? response.data;
          final newCompany = CompanyModel.fromJson(companyData);
          _companies.insert(0, newCompany);
        } else {
          _companies.insert(0, company);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error adding company: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update company via API
  Future<bool> updateCompany(CompanyModel company, {XFile? logoFile, Uint8List? logoBytes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ApiResponse response;

      if (logoFile != null) {
        // Read bytes from file for web compatibility
        final bytes = logoBytes ?? await logoFile.readAsBytes();
        // Use multipart request for file upload
        response = await ApiService.putMultipart(
          '/invoice/company/${company.id}/',
          _companyToFields(company),
          fileFieldName: 'logo',
          fileBytes: bytes,
          fileName: logoFile.name,
        );
      } else {
        // Use regular JSON request
        response = await ApiService.put(
          '/invoice/company/${company.id}/',
          company.toJson(),
        );
      }

      if (response.success) {
        final index = _companies.indexWhere((c) => c.id == company.id);
        if (index != -1) {
          if (response.data != null) {
            final companyData = response.data['data'] ?? response.data['company'] ?? response.data;
            _companies[index] = CompanyModel.fromJson(companyData);
          } else {
            _companies[index] = company;
          }
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error updating company: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete company via API
  Future<bool> deleteCompany(String id) async {
    debugPrint('=== PROVIDER: deleteCompany called ===');
    debugPrint('Company ID to delete: $id');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.delete('/invoice/company/$id/');

    debugPrint('DELETE Response - success: ${response.success}, statusCode: ${response.statusCode}');
    debugPrint('DELETE Response - message: ${response.message}');

    if (response.success) {
      debugPrint('Delete successful, removing company from local list');
      _companies.removeWhere((c) => c.id == id);
      debugPrint('Companies count after removal: ${_companies.length}');
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      debugPrint('Delete failed: ${response.message}');
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
