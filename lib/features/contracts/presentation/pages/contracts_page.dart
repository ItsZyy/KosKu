import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/contract_model.dart';
import '../../data/services/contract_service.dart';
import '../widgets/contract_card.dart';
import 'contract_detail_page.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  final ContractService _contractService = ContractService();
  final TextEditingController _searchController = TextEditingController();

  List<ContractModel> _contracts = [];

  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContracts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final contracts = await _contractService.getContracts();

      if (!mounted) {
        return;
      }

      setState(() {
        _contracts = contracts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openContractDetail(ContractModel contract) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ContractDetailPage(contract: contract)),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await _loadContracts();
    }
  }

  List<ContractModel> get _filteredContracts {
    final query = _searchController.text.trim().toLowerCase();

    return _contracts.where((contract) {
      final name = contract.displayName.toLowerCase();
      final roomNumber = contract.roomNumber?.toLowerCase() ?? '';
      final status = contract.status.toLowerCase();

      final matchesSearch = name.contains(query) || roomNumber.contains(query);

      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Aktif' && status == 'active') ||
          (_selectedFilter == 'Selesai' && status == 'inactive');

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kontrak')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummary(),
          const SizedBox(height: 16),
          _buildSearch(),
          const SizedBox(height: 12),
          _buildFilter(),
          const SizedBox(height: 16),
          ..._buildContractList(),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final total = _contracts.length;

    final active = _contracts
        .where((contract) => contract.status.toLowerCase() == 'active')
        .length;

    final inactive = _contracts
        .where((contract) => contract.status.toLowerCase() == 'inactive')
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.description_outlined,
            title: 'Total Kontrak',
            value: total.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.check_circle_outline,
            title: 'Aktif',
            value: active.toString(),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.archive_outlined,
            title: 'Selesai',
            value: inactive.toString(),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Cari nama penghuni atau kamar...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFilter() {
    const filters = ['Semua', 'Aktif', 'Selesai'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContractList() {
    final contracts = _filteredContracts;

    if (contracts.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 56,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 12),
              Text(
                _contracts.isEmpty
                    ? 'Belum ada kontrak'
                    : 'Tidak ada kontrak yang cocok',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return contracts.map((contract) {
      return ContractCard(
        contract: contract,
        onTap: () => _openContractDetail(contract),
      );
    }).toList();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat kontrak.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadContracts,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
