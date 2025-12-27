class EstimationItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double taxRate;

  EstimationItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;

  EstimationItem copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? taxRate,
  }) {
    return EstimationItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

class EstimationModel {
  final String id;
  final String estimationNumber;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;
  final List<EstimationItem> items;
  final DateTime createdAt;
  final DateTime validUntil;
  final String status;
  final String? notes;

  EstimationModel({
    required this.id,
    required this.estimationNumber,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientAddress,
    required this.items,
    required this.createdAt,
    required this.validUntil,
    this.status = 'pending',
    this.notes,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalTax => items.fold(0, (sum, item) => sum + item.taxAmount);
  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  EstimationModel copyWith({
    String? id,
    String? estimationNumber,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    List<EstimationItem>? items,
    DateTime? createdAt,
    DateTime? validUntil,
    String? status,
    String? notes,
  }) {
    return EstimationModel(
      id: id ?? this.id,
      estimationNumber: estimationNumber ?? this.estimationNumber,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
