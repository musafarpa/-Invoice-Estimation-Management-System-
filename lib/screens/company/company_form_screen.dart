import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/company_model.dart';
import '../../providers/company_provider.dart';
import '../../providers/theme_provider.dart';

class CompanyFormScreen extends StatefulWidget {
  final CompanyModel? company;

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameArController;
  late TextEditingController _subtitleEnController;
  late TextEditingController _subtitleArController;
  late TextEditingController _crNumberController;
  late TextEditingController _vatNumberController;
  late TextEditingController _vatController;
  late TextEditingController _bankNameController;
  late TextEditingController _beneficiaryController;
  late TextEditingController _ibanController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactNumberController;
  late TextEditingController _addressEnController;
  late TextEditingController _addressArController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _currencyController;

  XFile? _selectedLogo;
  Uint8List? _selectedLogoBytes;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.company?.nameEn ?? '');
    _nameArController = TextEditingController(text: widget.company?.nameAr ?? '');
    _subtitleEnController = TextEditingController(text: widget.company?.subtitleEn ?? '');
    _subtitleArController = TextEditingController(text: widget.company?.subtitleAr ?? '');
    _crNumberController = TextEditingController(text: widget.company?.crNumber ?? '');
    _vatNumberController = TextEditingController(text: widget.company?.vatNumber ?? '');
    _vatController = TextEditingController(text: widget.company?.vat ?? '15.00');
    _bankNameController = TextEditingController(text: widget.company?.bankName ?? '');
    _beneficiaryController = TextEditingController(text: widget.company?.beneficiary ?? '');
    _ibanController = TextEditingController(text: widget.company?.iban ?? '');
    _contactPersonController = TextEditingController(text: widget.company?.contactPerson ?? '');
    _contactNumberController = TextEditingController(text: widget.company?.contactNumber ?? '');
    _addressEnController = TextEditingController(text: widget.company?.addressEn ?? '');
    _addressArController = TextEditingController(text: widget.company?.addressAr ?? '');
    _cityController = TextEditingController(text: widget.company?.city ?? '');
    _postalCodeController = TextEditingController(text: widget.company?.postalCode ?? '');
    _countryController = TextEditingController(text: widget.company?.country ?? '');
    _currencyController = TextEditingController(text: widget.company?.currency ?? 'SAR');
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _subtitleEnController.dispose();
    _subtitleArController.dispose();
    _crNumberController.dispose();
    _vatNumberController.dispose();
    _vatController.dispose();
    _bankNameController.dispose();
    _beneficiaryController.dispose();
    _ibanController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _addressEnController.dispose();
    _addressArController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Logo Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F959).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF1A1A1A)),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
                ),
                title: Text(
                  'Take a Photo',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedLogo = image;
          _selectedLogoBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to pick image: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    final company = CompanyModel(
      id: widget.company?.id ?? '',
      nameEn: _nameEnController.text.trim(),
      nameAr: _nameArController.text.trim().isEmpty ? null : _nameArController.text.trim(),
      subtitleEn: _subtitleEnController.text.trim(),
      subtitleAr: _subtitleArController.text.trim().isEmpty ? null : _subtitleArController.text.trim(),
      crNumber: _crNumberController.text.trim(),
      vatNumber: _vatNumberController.text.trim(),
      vat: _vatController.text.trim(),
      bankName: _bankNameController.text.trim(),
      beneficiary: _beneficiaryController.text.trim(),
      iban: _ibanController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      addressEn: _addressEnController.text.trim().isEmpty ? null : _addressEnController.text.trim(),
      addressAr: _addressArController.text.trim().isEmpty ? null : _addressArController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
      country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
      currency: _currencyController.text.trim().isEmpty ? null : _currencyController.text.trim(),
    );

    final provider = Provider.of<CompanyProvider>(context, listen: false);
    bool success;

    if (isEditing) {
      success = await provider.updateCompany(company, logoFile: _selectedLogo, logoBytes: _selectedLogoBytes);
    } else {
      success = await provider.addCompany(company, logoFile: _selectedLogo, logoBytes: _selectedLogoBytes);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(isEditing ? 'Company updated successfully' : 'Company created successfully'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(provider.errorMessage ?? 'Failed to save company')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1A1A1A),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                        : [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F959),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isEditing ? Icons.edit_rounded : Icons.add_business_rounded,
                                color: const Color(0xFF1A1A1A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              isEditing ? 'Edit Company' : 'New Company',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Consumer<CompanyProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Section
                        _buildSectionCard(
                          title: 'Company Logo',
                          icon: Icons.image_rounded,
                          iconColor: const Color(0xFFFF9800),
                          isDark: isDark,
                          children: [
                            _buildLogoSelector(isDark),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Company Info Section (English)
                        _buildSectionCard(
                          title: 'Company Information (English)',
                          icon: Icons.business_rounded,
                          iconColor: const Color(0xFF6C63FF),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _nameEnController,
                              label: 'Company Name (English)',
                              hint: 'Enter company name',
                              icon: Icons.business,
                              isDark: isDark,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Company name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _subtitleEnController,
                              label: 'Tagline / Subtitle (English)',
                              hint: 'e.g., The Ultimate Solution',
                              icon: Icons.subtitles_outlined,
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Company Info Section (Arabic)
                        _buildSectionCard(
                          title: 'Company Information (Arabic)',
                          icon: Icons.translate_rounded,
                          iconColor: const Color(0xFF9C27B0),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _nameArController,
                              label: 'Company Name (Arabic)',
                              hint: 'اسم الشركة',
                              icon: Icons.business,
                              isDark: isDark,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _subtitleArController,
                              label: 'Tagline / Subtitle (Arabic)',
                              hint: 'الشعار',
                              icon: Icons.subtitles_outlined,
                              isDark: isDark,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Registration Details Section
                        _buildSectionCard(
                          title: 'Registration Details',
                          icon: Icons.assignment_rounded,
                          iconColor: const Color(0xFF2196F3),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _crNumberController,
                              label: 'CR Number',
                              hint: 'Commercial Registration Number',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    controller: _vatNumberController,
                                    label: 'VAT Number',
                                    hint: 'VAT Registration',
                                    icon: Icons.receipt_long_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _vatController,
                                    label: 'VAT %',
                                    hint: '15',
                                    icon: Icons.percent,
                                    keyboardType: TextInputType.number,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Address Section (English)
                        _buildSectionCard(
                          title: 'Address (English)',
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF4CAF50),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _addressEnController,
                              label: 'Address (English)',
                              hint: 'Street address',
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _cityController,
                                    label: 'City',
                                    hint: 'e.g., Jeddah',
                                    icon: Icons.location_city_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _postalCodeController,
                                    label: 'Postal Code',
                                    hint: 'e.g., 21533',
                                    icon: Icons.markunread_mailbox_outlined,
                                    keyboardType: TextInputType.number,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _countryController,
                                    label: 'Country',
                                    hint: 'e.g., KSA',
                                    icon: Icons.flag_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _currencyController,
                                    label: 'Currency',
                                    hint: 'e.g., SAR, INR',
                                    icon: Icons.currency_exchange,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Address Section (Arabic)
                        _buildSectionCard(
                          title: 'Address (Arabic)',
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF8BC34A),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _addressArController,
                              label: 'Address (Arabic)',
                              hint: 'العنوان بالعربي',
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Bank Details Section
                        _buildSectionCard(
                          title: 'Bank Details',
                          icon: Icons.account_balance_rounded,
                          iconColor: const Color(0xFF00B4D8),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _bankNameController,
                              label: 'Bank Name',
                              hint: 'e.g., QNB, Al Rajhi',
                              icon: Icons.account_balance,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _beneficiaryController,
                              label: 'Beneficiary Name',
                              hint: 'Account holder name',
                              icon: Icons.person_outline,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _ibanController,
                              label: 'IBAN',
                              hint: 'International Bank Account Number',
                              icon: Icons.credit_card,
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Contact Section
                        _buildSectionCard(
                          title: 'Contact Information',
                          icon: Icons.contact_phone_rounded,
                          iconColor: const Color(0xFFFF6B6B),
                          isDark: isDark,
                          children: [
                            _buildTextField(
                              controller: _contactPersonController,
                              label: 'Contact Person',
                              hint: 'Primary contact name',
                              icon: Icons.person,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _contactNumberController,
                              label: 'Contact Number',
                              hint: '+966 XX XXX XXXX',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _saveCompany,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                              foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: provider.isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isEditing ? Icons.save_rounded : Icons.add_business,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        isEditing ? 'Update Company' : 'Create Company',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSelector(bool isDark) {
    final existingLogoUrl = widget.company?.logo;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _selectedLogoBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        _selectedLogoBytes!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : existingLogoUrl != null && existingLogoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            existingLogoUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) => _buildLogoPlaceholder(isDark),
                          ),
                        )
                      : _buildLogoPlaceholder(isDark),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickLogo,
            icon: Icon(
              Icons.upload_rounded,
              color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
            ),
            label: Text(
              _selectedLogo != null || (existingLogoUrl != null && existingLogoUrl.isNotEmpty)
                  ? 'Change Logo'
                  : 'Upload Logo',
              style: TextStyle(
                color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_selectedLogo != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedLogo = null;
                  _selectedLogoBytes = null;
                });
              },
              child: Text(
                'Remove',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
        ),
        const SizedBox(height: 4),
        Text(
          'Add Logo',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF3A3A3A) : null),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isDark = false,
    TextDirection? textDirection,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: textDirection,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
