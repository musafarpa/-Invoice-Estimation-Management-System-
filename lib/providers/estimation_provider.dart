import 'package:flutter/material.dart';
import '../models/estimation_model.dart';

class EstimationProvider with ChangeNotifier {
  final List<EstimationModel> _estimations = [
    EstimationModel(
      id: '1',
      estimationNumber: 'EST-001',
      clientName: 'Acme Corporation',
      clientEmail: 'contact@acme.com',
      clientPhone: '+1 234 567 8900',
      clientAddress: '123 Business Ave, New York, NY 10001',
      items: [
        EstimationItem(
          id: '1',
          description: 'Web Development Service',
          quantity: 1,
          unitPrice: 5000,
          taxRate: 10,
        ),
        EstimationItem(
          id: '2',
          description: 'UI/UX Design',
          quantity: 1,
          unitPrice: 2500,
          taxRate: 10,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 25)),
      status: 'pending',
      notes: 'Thank you for your business!',
    ),
    EstimationModel(
      id: '2',
      estimationNumber: 'EST-002',
      clientName: 'Tech Solutions Ltd',
      clientEmail: 'info@techsolutions.com',
      clientPhone: '+1 234 567 8901',
      clientAddress: '456 Tech Park, San Francisco, CA 94102',
      items: [
        EstimationItem(
          id: '1',
          description: 'Mobile App Development',
          quantity: 1,
          unitPrice: 15000,
          taxRate: 10,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      validUntil: DateTime.now().add(const Duration(days: 28)),
      status: 'approved',
    ),
    EstimationModel(
      id: '3',
      estimationNumber: 'EST-003',
      clientName: 'Global Industries',
      clientEmail: 'procurement@global.com',
      clientPhone: '+1 234 567 8902',
      clientAddress: '789 Industry Blvd, Chicago, IL 60601',
      items: [
        EstimationItem(
          id: '1',
          description: 'Consulting Services',
          quantity: 40,
          unitPrice: 150,
          taxRate: 5,
        ),
        EstimationItem(
          id: '2',
          description: 'Training Program',
          quantity: 2,
          unitPrice: 3000,
          taxRate: 5,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      validUntil: DateTime.now().add(const Duration(days: 20)),
      status: 'rejected',
    ),
  ];

  List<EstimationModel> get estimations => List.unmodifiable(_estimations);

  double get totalEstimatedAmount =>
      _estimations.fold(0, (sum, e) => sum + e.totalAmount);

  int get pendingCount =>
      _estimations.where((e) => e.status == 'pending').length;

  int get approvedCount =>
      _estimations.where((e) => e.status == 'approved').length;

  EstimationModel? getEstimationById(String id) {
    try {
      return _estimations.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  void addEstimation(EstimationModel estimation) {
    _estimations.insert(0, estimation);
    notifyListeners();
  }

  void updateEstimation(EstimationModel estimation) {
    final index = _estimations.indexWhere((e) => e.id == estimation.id);
    if (index != -1) {
      _estimations[index] = estimation;
      notifyListeners();
    }
  }

  void deleteEstimation(String id) {
    _estimations.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  String generateEstimationNumber() {
    final count = _estimations.length + 1;
    return 'EST-${count.toString().padLeft(3, '0')}';
  }
}
