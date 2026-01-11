import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/company_model.dart';
import '../../providers/company_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import 'company_form_screen.dart';

class CompanyDetailScreen extends StatelessWidget {
  final String companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        final company = provider.getCompanyById(companyId);

        if (company == null) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
            appBar: AppBar(
              title: const Text('Company Details'),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
            ),
            body: Center(
              child: Text(
                'Company not found',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1A1A1A),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompanyFormScreen(company: company),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red, size: 20),
                    ),
                    onPressed: () => _showDeleteDialog(context, provider, company),
                  ),
                  const SizedBox(width: 8),
                ],
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
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F959),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: company.logo != null && company.logo!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        company.logo!.startsWith('http')
                                            ? company.logo!
                                            : '${ApiService.baseUrl}${company.logo}',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.business,
                                            size: 40,
                                            color: Color(0xFF1A1A1A),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.business,
                                      size: 40,
                                      color: Color(0xFF1A1A1A),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              company.nameEn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              company.subtitleEn,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Info Card
                      _buildInfoCard(
                        title: 'Company Information',
                        icon: Icons.business,
                        isDark: isDark,
                        children: [
                          _buildInfoRow('CR Number', company.crNumber, Icons.numbers, isDark),
                          _buildInfoRow('VAT Number', company.vatNumber, Icons.receipt_long_outlined, isDark),
                          _buildInfoRow('VAT Rate', '${company.vat}%', Icons.percent, isDark),
                          if (company.currency != null && company.currency!.isNotEmpty)
                            _buildInfoRow('Currency', company.currency!, Icons.currency_exchange, isDark),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Address Card
                      if (company.addressEn != null || company.city != null || company.country != null)
                        _buildInfoCard(
                          title: 'Address & Location',
                          icon: Icons.location_on,
                          isDark: isDark,
                          children: [
                            if (company.addressEn != null && company.addressEn!.isNotEmpty)
                              _buildInfoRow('Address', company.addressEn!, Icons.location_on_outlined, isDark),
                            if (company.city != null && company.city!.isNotEmpty)
                              _buildInfoRow('City', company.city!, Icons.location_city_outlined, isDark),
                            if (company.postalCode != null && company.postalCode!.isNotEmpty)
                              _buildInfoRow('Postal Code', company.postalCode!, Icons.markunread_mailbox_outlined, isDark),
                            if (company.country != null && company.country!.isNotEmpty)
                              _buildInfoRow('Country', company.country!, Icons.flag_outlined, isDark),
                          ],
                        ),

                      if (company.addressEn != null || company.city != null || company.country != null)
                        const SizedBox(height: 16),

                      // Bank Details Card
                      _buildInfoCard(
                        title: 'Bank Details',
                        icon: Icons.account_balance,
                        isDark: isDark,
                        children: [
                          _buildInfoRow('Bank Name', company.bankName, Icons.account_balance, isDark),
                          _buildInfoRow('Beneficiary', company.beneficiary, Icons.person_outline, isDark),
                          _buildInfoRowWithCopy(context, 'IBAN', company.iban, Icons.credit_card, isDark),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Contact Card
                      _buildInfoCard(
                        title: 'Contact Information',
                        icon: Icons.contact_phone,
                        isDark: isDark,
                        children: [
                          _buildInfoRow('Contact Person', company.contactPerson, Icons.person, isDark),
                          _buildInfoRowWithCopy(context, 'Phone', company.contactNumber, Icons.phone, isDark),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F959).withValues(alpha: isDark ? 0.2 : 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF3A3A3A) : null),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithCopy(BuildContext context, String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          if (value.isNotEmpty)
            IconButton(
              icon: Icon(Icons.copy, size: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied to clipboard'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: isDark ? const Color(0xFF2A2A2A) : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CompanyProvider provider, CompanyModel company) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Company'),
        content: Text('Are you sure you want to delete "${company.nameEn}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(dialogContext);

              // Show loading indicator
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Deleting company...'),
                    ],
                  ),
                  duration: Duration(seconds: 10),
                  backgroundColor: Colors.orange,
                ),
              );

              final success = await provider.deleteCompany(company.id);

              // Clear the loading snackbar
              scaffoldMessenger.hideCurrentSnackBar();

              if (success) {
                // Navigate back to list first
                navigator.pop();

                // Show success message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('${company.nameEn} deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                // Show error message (stay on current screen)
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(provider.errorMessage ?? 'Failed to delete company')),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
