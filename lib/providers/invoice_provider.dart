import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/estimation_model.dart';

class InvoiceProvider with ChangeNotifier {
  final List<InvoiceModel> _invoices = [
    InvoiceModel(
      id: '1',
      invoiceNumber: 'INV-001',
      clientName: 'Megogo',
      clientEmail: 'billing@megogo.com',
      clientPhone: '+1 234 567 8903',
      clientAddress: '100 Media St, Los Angeles, CA 90001',
      items: [
        InvoiceItem(
          id: '1',
          description: 'Streaming Service Subscription',
          quantity: 1,
          unitPrice: 24.99,
          taxRate: 0,
        ),
      ],
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: 'unpaid',
    ),
    InvoiceModel(
      id: '2',
      invoiceNumber: 'INV-002',
      clientName: 'Digital Marketing Pro',
      clientEmail: 'accounts@dmpro.com',
      clientPhone: '+1 234 567 8904',
      clientAddress: '200 Marketing Way, Miami, FL 33101',
      items: [
        InvoiceItem(
          id: '1',
          description: 'SEO Services - Monthly',
          quantity: 1,
          unitPrice: 1500,
          taxRate: 10,
        ),
        InvoiceItem(
          id: '2',
          description: 'Social Media Management',
          quantity: 1,
          unitPrice: 800,
          taxRate: 10,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: 'paid',
      paidAmount: 2530,
    ),
    InvoiceModel(
      id: '3',
      invoiceNumber: 'INV-003',
      clientName: 'StartUp Ventures',
      clientEmail: 'finance@startupv.com',
      clientPhone: '+1 234 567 8905',
      clientAddress: '300 Innovation Dr, Austin, TX 78701',
      items: [
        InvoiceItem(
          id: '1',
          description: 'MVP Development',
          quantity: 1,
          unitPrice: 25000,
          taxRate: 10,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      status: 'overdue',
    ),
  ];

  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);

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

  void addInvoice(InvoiceModel invoice) {
    _invoices.insert(0, invoice);
    notifyListeners();
  }

  void updateInvoice(InvoiceModel invoice) {
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      notifyListeners();
    }
  }

  void deleteInvoice(String id) {
    _invoices.removeWhere((i) => i.id == id);
    notifyListeners();
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
      clientEmail: estimation.clientEmail,
      clientPhone: estimation.clientPhone,
      clientAddress: estimation.clientAddress,
      items: estimation.items
          .map((item) => InvoiceItem(
                id: item.id,
                description: item.description,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                taxRate: item.taxRate,
              ))
          .toList(),
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: 'unpaid',
      notes: estimation.notes,
    );
  }
}
