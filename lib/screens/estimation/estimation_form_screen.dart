import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/estimation_model.dart';
import '../../providers/estimation_provider.dart';

class EstimationFormScreen extends StatefulWidget {
  final EstimationModel? estimation;

  const EstimationFormScreen({super.key, this.estimation});

  @override
  State<EstimationFormScreen> createState() => _EstimationFormScreenState();
}

class _EstimationFormScreenState extends State<EstimationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _clientEmailController;
  late TextEditingController _clientPhoneController;
  late TextEditingController _clientAddressController;
  late TextEditingController _notesController;
  late DateTime _validUntil;
  late String _status;
  List<EstimationItem> _items = [];

  @override
  void initState() {
    super.initState();
    final est = widget.estimation;
    _clientNameController = TextEditingController(text: est?.clientName ?? '');
    _clientEmailController = TextEditingController(text: est?.clientEmail ?? '');
    _clientPhoneController = TextEditingController(text: est?.clientPhone ?? '');
    _clientAddressController = TextEditingController(text: est?.clientAddress ?? '');
    _notesController = TextEditingController(text: est?.notes ?? '');
    _validUntil = est?.validUntil ?? DateTime.now().add(const Duration(days: 30));
    _status = est?.status ?? 'pending';
    _items = est?.items.toList() ?? [];
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemFormSheet(
        onSave: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemFormSheet(
        item: _items[index],
        onSave: (item) {
          setState(() {
            _items[index] = item;
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveEstimation() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add at least one item'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final provider = Provider.of<EstimationProvider>(context, listen: false);
      final estimation = EstimationModel(
        id: widget.estimation?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        estimationNumber: widget.estimation?.estimationNumber ?? provider.generateEstimationNumber(),
        clientName: _clientNameController.text.trim(),
        clientEmail: _clientEmailController.text.trim(),
        clientPhone: _clientPhoneController.text.trim(),
        clientAddress: _clientAddressController.text.trim(),
        items: _items,
        createdAt: widget.estimation?.createdAt ?? DateTime.now(),
        validUntil: _validUntil,
        status: _status,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.estimation != null) {
        provider.updateEstimation(estimation);
      } else {
        provider.addEstimation(estimation);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.estimation != null ? 'Estimation updated' : 'Estimation created'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Text(
                    widget.estimation != null ? 'Edit Estimation' : 'New Estimation',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _saveEstimation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F959),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8F959).withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientNameController,
                        label: 'Client Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientEmailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientPhoneController,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientAddressController,
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Valid Until & Status
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _validUntil,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _validUntil = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 20, color: Colors.grey.shade500),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Valid Until',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        Text(
                                          '${_validUntil.day}/${_validUntil.month}/${_validUntil.year}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _status,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _status = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _addItem,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F959),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Add Item',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_items.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_shopping_cart_outlined,
                                size: 40,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No items added',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_items.length, (index) {
                          final item = _items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _editItem(index),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.description,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeItem(index),
                                  child: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red.shade400,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 24),

                      // Notes
                      const Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Add notes...',
                        icon: Icons.note_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}

class _ItemFormSheet extends StatefulWidget {
  final EstimationItem? item;
  final Function(EstimationItem) onSave;

  const _ItemFormSheet({this.item, required this.onSave});

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _taxController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(
        text: widget.item?.quantity.toString() ?? '1');
    _priceController = TextEditingController(
        text: widget.item?.unitPrice.toString() ?? '');
    _taxController = TextEditingController(
        text: widget.item?.taxRate.toString() ?? '0');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.item != null ? 'Edit Item' : 'Add Item',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Unit Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _taxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tax Rate (%)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final item = EstimationItem(
                        id: widget.item?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        description: _descriptionController.text.trim(),
                        quantity: int.tryParse(_quantityController.text) ?? 1,
                        unitPrice: double.tryParse(_priceController.text) ?? 0,
                        taxRate: double.tryParse(_taxController.text) ?? 0,
                      );
                      widget.onSave(item);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.item != null ? 'Update Item' : 'Add Item',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
