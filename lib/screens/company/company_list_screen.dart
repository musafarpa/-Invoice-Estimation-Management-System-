import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/company_model.dart';
import '../../providers/company_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import 'company_form_screen.dart';
import 'company_detail_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<CompanyProvider>(context, listen: false).fetchCompanies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F5),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 180,
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
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F959),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 20),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompanyFormScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    Provider.of<CompanyProvider>(context, listen: false).fetchCompanies();
                  }
                },
              ),
              const SizedBox(width: 12),
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Consumer<CompanyProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F959),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.business_rounded,
                                    color: Color(0xFF1A1A1A),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Companies',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${provider.companyCount} registered',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Consumer<CompanyProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.companies.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                    ),
                  ),
                );
              }

              if (provider.errorMessage != null && provider.companies.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.grey.shade800,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchCompanies(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                            foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.companies.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F959).withValues(alpha: isDark ? 0.2 : 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.business_outlined,
                            size: 60,
                            color: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Companies Yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first company to get started',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CompanyFormScreen(),
                              ),
                            );
                            if (result == true && mounted) {
                              provider.fetchCompanies();
                            }
                          },
                          icon: const Icon(Icons.add_business),
                          label: const Text('Add Company'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFE8F959) : const Color(0xFF1A1A1A),
                            foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final company = provider.companies[index];
                      return _buildCompanyCard(company, index, isDark);
                    },
                    childCount: provider.companies.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(CompanyModel company, int index, bool isDark) {
    // Alternate card colors for visual interest
    final colors = [
      const Color(0xFFE8F959),
      const Color(0xFF6C63FF).withValues(alpha: 0.15),
      const Color(0xFF00D9FF).withValues(alpha: 0.15),
      const Color(0xFFFF6B6B).withValues(alpha: 0.15),
    ];
    final iconColors = [
      const Color(0xFF1A1A1A),
      const Color(0xFF6C63FF),
      const Color(0xFF00B4D8),
      const Color(0xFFFF6B6B),
    ];

    final colorIndex = index % colors.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyDetailScreen(companyId: company.id),
              ),
            );
            if (result == true && mounted) {
              Provider.of<CompanyProvider>(context, listen: false).fetchCompanies();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Company Logo/Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors[colorIndex],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: company.logo != null && company.logo!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            company.logo!.startsWith('http')
                                ? company.logo!
                                : '${ApiService.baseUrl}${company.logo}',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business_rounded,
                                color: iconColors[colorIndex],
                                size: 32,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business_rounded,
                          color: iconColors[colorIndex],
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                // Company Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.nameEn,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company.subtitleEn,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.phone_outlined,
                            company.contactNumber.isNotEmpty
                                ? company.contactNumber
                                : 'No phone',
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.percent,
                            'VAT ${company.vat}%',
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
