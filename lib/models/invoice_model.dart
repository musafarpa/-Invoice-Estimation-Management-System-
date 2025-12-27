class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double taxRate;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;

  InvoiceItem copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? taxRate,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String? estimationId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;
  final List<InvoiceItem> items;
  final DateTime createdAt;
  final DateTime dueDate;
  final String status;
  final String? notes;
  final double? paidAmount;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.estimationId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientAddress,
    required this.items,
    required this.createdAt,
    required this.dueDate,
    this.status = 'unpaid',
    this.notes,
    this.paidAmount,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalTax => items.fold(0, (sum, item) => sum + item.taxAmount);
  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  double get balance => totalAmount - (paidAmount ?? 0);

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? estimationId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    List<InvoiceItem>? items,
    DateTime? createdAt,
    DateTime? dueDate,
    String? status,
    String? notes,
    double? paidAmount,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      estimationId: estimationId ?? this.estimationId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
