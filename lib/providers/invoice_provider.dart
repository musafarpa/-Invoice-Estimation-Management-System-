import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/estimation_model.dart';
import '../services/api_service.dart';

class InvoiceProvider with ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalInvoicedAmount =>
      _invoices.fold(0, (sum, i) => sum + i.totalAmount);

  double get totalPaidAmount =>
      _invoices.fold(0, (sum, i) => sum + (i.paidAmount ?? 0));

  double get totalOutstanding => totalInvoicedAmount - totalPaidAmount;

  int get unpaidCount => _invoices.where((i) => i.status == 'unpaid').length;

  int get paidCount => _invoices.where((i) => i.status == 'paid').length;

  int get overdueCount => _invoices.where((i) => i.status == 'overdue').length;

  InvoiceModel? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch single invoice details from API
  Future<InvoiceModel?> fetchInvoiceById(String id) async {
    try {
      final response = await ApiService.get('/invoice/invoices/$id/');

      if (response.success && response.data != null) {
        // API may return {"invoice": {...}} or direct object
        final invoiceData = response.data['invoice'] ?? response.data;
        debugPrint('Fetched invoice data: $invoiceData');
        final invoice = InvoiceModel.fromJson(invoiceData);
        // Update local list with fresh data
        final index = _invoices.indexWhere((i) => i.id == id);
        if (index != -1) {
          _invoices[index] = invoice;
          notifyListeners();
        }
        return invoice;
      } else {
        _errorMessage = response.message;
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching invoice by ID: $e');
      _errorMessage = 'Error: $e';
      return null;
    }
  }

  // Fetch all invoices from API
  Future<void> fetchInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Use the correct list endpoint - requires POST method
    final response = await ApiService.post('/invoice/invoice_list/', {});

    debugPrint('Invoice list response success: ${response.success}');
    debugPrint('Invoice list response data type: ${response.data?.runtimeType}');
    debugPrint('Invoice list response data: ${response.data}');

    if (response.success && response.data != null) {
      _invoices = [];
      // Handle response format: {"message": "...", "data": [...]}
      List<dynamic> invoicesData = [];
      if (response.data is List) {
        invoicesData = response.data;
        debugPrint('Data is List with ${invoicesData.length} items');
      } else if (response.data is Map) {
        final mapData = response.data as Map<String, dynamic>;
        if (mapData['data'] != null && mapData['data'] is List) {
          invoicesData = mapData['data'] as List;
          debugPrint('Data from "data" key with ${invoicesData.length} items');
        } else if (mapData['results'] != null && mapData['results'] is List) {
          invoicesData = mapData['results'] as List;
          debugPrint('Data from "results" key with ${invoicesData.length} items');
        } else if (mapData['invoices'] != null && mapData['invoices'] is List) {
          invoicesData = mapData['invoices'] as List;
          debugPrint('Data from "invoices" key with ${invoicesData.length} items');
        } else {
          debugPrint('Unknown response format. Keys: ${mapData.keys}');
        }
      }

      debugPrint('Processing ${invoicesData.length} invoices');
      for (var invoiceData in invoicesData) {
        try {
          _invoices.add(InvoiceModel.fromJson(invoiceData));
        } catch (e) {
          debugPrint('Error parsing invoice: $e');
          debugPrint('Invoice data: $invoiceData');
        }
      }
      debugPrint('Successfully loaded ${_invoices.length} invoices');
    } else {
      _errorMessage = response.message;
      debugPrint('Error fetching invoices: ${response.message}');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add invoice via API
  Future<bool> addInvoice(InvoiceModel invoice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/invoice/invoices/', invoice.toJson());

      if (response.success) {
        // Add the returned invoice with server-generated ID
        if (response.data != null) {
          // API returns {"invoice": {...}} - extract nested invoice object
          final invoiceData = response.data['invoice'] ?? response.data;
          final newInvoice = InvoiceModel.fromJson(invoiceData);
          _invoices.insert(0, newInvoice);
        } else {
          _invoices.insert(0, invoice);
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
      debugPrint('Error adding invoice: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update invoice via API
  Future<bool> updateInvoice(InvoiceModel invoice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use PUT for update (as shown in Postman)
      final response = await ApiService.put(
        '/invoice/invoices/${invoice.id}/',
        invoice.toJson(),
      );

      if (response.success) {
        final index = _invoices.indexWhere((i) => i.id == invoice.id);
        if (index != -1) {
          // API returns {"invoice": {...}} - extract nested invoice object
          if (response.data != null) {
            final invoiceData = response.data['invoice'] ?? response.data;
            _invoices[index] = InvoiceModel.fromJson(invoiceData);
          } else {
            _invoices[index] = invoice;
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
      debugPrint('Error updating invoice: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete invoice via API
  Future<bool> deleteInvoice(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.delete('/invoice/invoices/$id/');

    if (response.success) {
      _invoices.removeWhere((i) => i.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark invoice as paid
  Future<bool> markAsPaid(String id, double amount) async {
    final invoice = getInvoiceById(id);
    if (invoice == null) return false;

    final updatedInvoice = invoice.copyWith(
      status: 'paid',
      paidAmount: amount,
    );

    return await updateInvoice(updatedInvoice);
  }

  String generateInvoiceNumber() {
    final count = _invoices.length + 1;
    return 'INV-${count.toString().padLeft(3, '0')}';
  }

  InvoiceModel createFromEstimation(EstimationModel estimation) {
    return InvoiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: generateInvoiceNumber(),
      estimationId: estimation.id,
      clientName: estimation.clientName,
      clientNameAr: estimation.clientNameAr,
      clientEmail: estimation.clientEmail,
      clientPhone: estimation.clientPhone,
      clientAddress: estimation.clientAddress,
      clientVatNumber: estimation.clientVatNumber,
      items: estimation.items
          .map((item) => InvoiceItem(
                id: item.id,
                description: item.description,
                quantity: item.quantity,
                unit: item.unit,
                unitPrice: item.unitPrice,
                taxRate: item.taxRate,
              ))
          .toList(),
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: 'unpaid',
      notes: estimation.notes,
      notesAr: estimation.notesAr,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
