import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/theme_provider.dart';

class InvoiceFormScreen extends StatefulWidget {
  final InvoiceModel? invoice;

  const InvoiceFormScreen({super.key, this.invoice});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _clientAddressController;
  late TextEditingController _clientVatController;
  late TextEditingController _clientPostalCodeController;
  late TextEditingController _clientCityController;
  late TextEditingController _clientCountryController;
  late TextEditingController _notesController;
  late TextEditingController _discountController;
  List<InvoiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    final inv = widget.invoice;
    _clientNameController = TextEditingController(text: inv?.clientName ?? '');
    _clientAddressController = TextEditingController(text: inv?.clientAddress ?? '');
    _clientVatController = TextEditingController(text: inv?.clientVatNumber ?? '');
    _clientPostalCodeController = TextEditingController(text: inv?.clientPostalCode ?? '');
    _clientCityController = TextEditingController(text: inv?.clientCity ?? '');
    _clientCountryController = TextEditingController(text: inv?.clientCountry ?? '');
    _notesController = TextEditingController(text: inv?.notes ?? '');
    _discountController = TextEditingController(text: inv?.discount?.toStringAsFixed(2) ?? '');
    _items = inv?.items.toList() ?? [];
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _clientVatController.dispose();
    _clientPostalCodeController.dispose();
    _clientCityController.dispose();
    _clientCountryController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addItem() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemFormSheet(
        isDark: isDark,
        onSave: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemFormSheet(
        item: _items[index],
        isDark: isDark,
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

  bool _isSaving = false;

  Future<void> _saveInvoice() async {
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

      setState(() {
        _isSaving = true;
      });

      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      final discountValue = double.tryParse(_discountController.text.trim());
      final invoice = InvoiceModel(
        id: widget.invoice?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        invoiceNumber: widget.invoice?.invoiceNumber ?? provider.generateInvoiceNumber(),
        estimationId: widget.invoice?.estimationId,
        clientName: _clientNameController.text.trim(),
        clientEmail: '',
        clientPhone: '',
        clientAddress: _clientAddressController.text.trim(),
        clientVatNumber: _clientVatController.text.trim().isEmpty ? null : _clientVatController.text.trim(),
        clientPostalCode: _clientPostalCodeController.text.trim().isEmpty ? null : _clientPostalCodeController.text.trim(),
        clientCity: _clientCityController.text.trim().isEmpty ? null : _clientCityController.text.trim(),
        clientCountry: _clientCountryController.text.trim().isEmpty ? null : _clientCountryController.text.trim(),
        items: _items,
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: 'unpaid',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        paidAmount: widget.invoice?.paidAmount,
        discount: discountValue,
      );

      bool success;
      if (widget.invoice != null) {
        success = await provider.updateInvoice(invoice);
      } else {
        success = await provider.addInvoice(invoice);
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.invoice != null ? 'Invoice updated' : 'Invoice created'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to save invoice'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
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
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Text(
                    widget.invoice != null ? 'Edit Invoice' : 'New Invoice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : _saveInvoice,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isSaving
                            ? (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300)
                            : const Color(0xFFE8F959),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8F959).withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1A1A1A),
                                ),
                              )
                            : const Icon(
                                Icons.check,
                                color: Color(0xFF1A1A1A),
                              ),
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
                      Text(
                        'Client Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientNameController,
                        label: 'Client Name',
                        icon: Icons.person_outline,
                        isDark: isDark,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientAddressController,
                        label: 'Client Address',
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientVatController,
                        label: 'Client VAT Number',
                        icon: Icons.receipt_outlined,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _clientCityController,
                              label: 'City',
                              icon: Icons.location_city_outlined,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _clientPostalCodeController,
                              label: 'Postal Code',
                              icon: Icons.markunread_mailbox_outlined,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientCountryController,
                        label: 'Country',
                        icon: Icons.flag_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
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
                                  Icon(Icons.add, size: 18, color: Color(0xFF1A1A1A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Add Item',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFF1A1A1A),
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
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_shopping_cart_outlined,
                                size: 40,
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No items added',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
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
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.quantity} ${item.unit} x ${item.unitPrice.toStringAsFixed(2)} SAR',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item.total.toStringAsFixed(2)} SAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
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

                      // Subject/Notes
                      Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Subject (e.g., Website Hosting Renewal)',
                        icon: Icons.subject_outlined,
                        maxLines: 2,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Discount
                      Text(
                        'Discount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _discountController,
                        label: 'Discount Amount',
                        icon: Icons.discount_outlined,
                        keyboardType: TextInputType.number,
                        isDark: isDark,
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
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
          prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}

class _ItemFormSheet extends StatefulWidget {
  final InvoiceItem? item;
  final Function(InvoiceItem) onSave;
  final bool isDark;

  const _ItemFormSheet({this.item, required this.onSave, this.isDark = false});

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String _selectedUnit = 'unit';

  // Available units
  final List<String> _units = ['unit', 'pcs', 'kg', 'g', 'liter', 'ml', 'hour', 'day', 'month', 'year', 'box', 'set'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(
        text: widget.item?.quantity.toString() ?? '1');
    _priceController = TextEditingController(
        text: widget.item?.unitPrice.toString() ?? '');
    _selectedUnit = widget.item?.unit ?? 'unit';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value ?? 'unit';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  labelText: 'Unit Price',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final item = InvoiceItem(
                        id: widget.item?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        description: _descriptionController.text.trim(),
                        quantity: int.tryParse(_quantityController.text) ?? 1,
                        unit: _selectedUnit,
                        unitPrice: double.tryParse(_priceController.text) ?? 0,
                      );
                      widget.onSave(item);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.item != null ? 'Update Item' : 'Add Item',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    ),
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
