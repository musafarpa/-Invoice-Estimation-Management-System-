import 'package:flutter/material.dart';
import '../models/estimation_model.dart';
import '../services/api_service.dart';

class EstimationProvider with ChangeNotifier {
  List<EstimationModel> _estimations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EstimationModel> get estimations => List.unmodifiable(_estimations);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalEstimatedAmount =>
      _estimations.fold(0, (sum, e) => sum + e.totalAmount);

  int get pendingCount =>
      _estimations.where((e) => e.status == 'pending').length;

  int get approvedCount =>
      _estimations.where((e) => e.status == 'approved').length;

  int get rejectedCount =>
      _estimations.where((e) => e.status == 'rejected').length;

  EstimationModel? getEstimationById(String id) {
    try {
      return _estimations.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch single estimation details from API
  Future<EstimationModel?> fetchEstimationById(String id) async {
    // First check local cache - if we have data, use it (API single GET may not exist)
    final localEstimation = getEstimationById(id);

    try {
      final response = await ApiService.get('/invoice/estimations/$id/');

      if (response.success && response.data != null) {
        // API may return {"estimation": {...}} or direct object
        final estimationData = response.data['estimation'] ?? response.data;
        debugPrint('Fetched estimation data: $estimationData');
        final estimation = EstimationModel.fromJson(estimationData);
        // Update local list with fresh data
        final index = _estimations.indexWhere((e) => e.id == id);
        if (index != -1) {
          _estimations[index] = estimation;
          notifyListeners();
        }
        return estimation;
      } else {
        // If API fails, return from local cache without setting error
        debugPrint('API fetch failed: ${response.message}, using local cache');
        if (localEstimation != null) {
          return localEstimation;
        }
        // Only set error if we have no local data
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching estimation by ID: $e');
      // Return from local cache on error without setting error message
      if (localEstimation != null) {
        return localEstimation;
      }
      // Only set error if we have no local data
      _errorMessage = 'Error: $e';
      notifyListeners();
      return null;
    }
  }

  // Fetch all estimations from API
  Future<void> fetchEstimations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Use the estimation list endpoint - requires POST method
    final response = await ApiService.post('/invoice/estimations-list/', {});

    debugPrint('Estimation list response success: ${response.success}');
    debugPrint('Estimation list response data type: ${response.data?.runtimeType}');

    if (response.success && response.data != null) {
      _estimations = [];
      // Handle different response formats: array, {data: [...]}, {results: [...]}, {quotations: [...]}, or {estimations: [...]}
      List<dynamic> estimationsData = [];
      if (response.data is List) {
        estimationsData = response.data;
        debugPrint('Estimation data is List with ${estimationsData.length} items');
      } else if (response.data is Map) {
        final mapData = response.data as Map<String, dynamic>;
        if (mapData['data'] != null && mapData['data'] is List) {
          estimationsData = mapData['data'] as List;
          debugPrint('Estimation data from "data" key with ${estimationsData.length} items');
        } else if (mapData['results'] != null && mapData['results'] is List) {
          estimationsData = mapData['results'] as List;
          debugPrint('Estimation data from "results" key with ${estimationsData.length} items');
        } else if (mapData['estimations'] != null && mapData['estimations'] is List) {
          estimationsData = mapData['estimations'] as List;
          debugPrint('Estimation data from "estimations" key with ${estimationsData.length} items');
        } else if (mapData['quotations'] != null && mapData['quotations'] is List) {
          estimationsData = mapData['quotations'] as List;
          debugPrint('Estimation data from "quotations" key with ${estimationsData.length} items');
        } else {
          debugPrint('Unknown estimation response format. Keys: ${mapData.keys}');
        }
      }

      debugPrint('Processing ${estimationsData.length} estimations');
      for (var estimationData in estimationsData) {
        try {
          // Each item might be wrapped in {"estimation": {...}} or {"quotation": {...}}
          final data = estimationData['estimation'] ?? estimationData['quotation'] ?? estimationData;
          _estimations.add(EstimationModel.fromJson(data));
        } catch (e) {
          debugPrint('Error parsing estimation: $e');
          debugPrint('Estimation data: $estimationData');
        }
      }
      debugPrint('Successfully loaded ${_estimations.length} estimations');
    } else {
      _errorMessage = response.message;
      debugPrint('Error fetching estimations: ${response.message}');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add estimation via API
  Future<bool> addEstimation(EstimationModel estimation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use POST to /invoice/estimations/ for creating new estimation
      final response = await ApiService.post('/invoice/estimations/', estimation.toJson());

      if (response.success) {
        // Add the returned estimation with server-generated ID
        if (response.data != null) {
          // API returns {"estimation": {...}} - extract nested estimation object
          final estimationData = response.data['estimation'] ?? response.data;
          final newEstimation = EstimationModel.fromJson(estimationData);
          _estimations.insert(0, newEstimation);
        } else {
          _estimations.insert(0, estimation);
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
      debugPrint('Error adding estimation: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update estimation via API
  Future<bool> updateEstimation(EstimationModel estimation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use PUT for update (same as invoice API)
      final response = await ApiService.put(
        '/invoice/estimations/${estimation.id}/',
        estimation.toJson(),
      );

      if (response.success) {
        final index = _estimations.indexWhere((e) => e.id == estimation.id);
        if (index != -1) {
          // API returns {"estimation": {...}} - extract nested estimation object
          if (response.data != null) {
            final estimationData = response.data['estimation'] ?? response.data;
            _estimations[index] = EstimationModel.fromJson(estimationData);
          } else {
            _estimations[index] = estimation;
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
      debugPrint('Error updating estimation: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete estimation via API
  Future<bool> deleteEstimation(String id) async {
    debugPrint('=== PROVIDER: deleteEstimation called ===');
    debugPrint('Estimation ID to delete: $id');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Use DELETE /invoice/estimations/{id}/ - same as Postman
    final response = await ApiService.delete('/invoice/estimations/$id/');

    debugPrint('DELETE Response - success: ${response.success}, statusCode: ${response.statusCode}');
    debugPrint('DELETE Response - message: ${response.message}');
    debugPrint('DELETE Response - data: ${response.data}');

    // Handle success (200, 204, etc.)
    if (response.success) {
      debugPrint('Delete successful, removing estimation from local list');
      _estimations.removeWhere((e) => e.id == id);
      debugPrint('Estimations count after removal: ${_estimations.length}');
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

  // Approve estimation
  Future<bool> approveEstimation(String id) async {
    final estimation = getEstimationById(id);
    if (estimation == null) return false;

    final updatedEstimation = estimation.copyWith(status: 'approved');
    return await updateEstimation(updatedEstimation);
  }

  // Reject estimation
  Future<bool> rejectEstimation(String id) async {
    final estimation = getEstimationById(id);
    if (estimation == null) return false;

    final updatedEstimation = estimation.copyWith(status: 'rejected');
    return await updateEstimation(updatedEstimation);
  }

  String generateEstimationNumber() {
    final count = _estimations.length + 1;
    return 'EST-${count.toString().padLeft(3, '0')}';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
