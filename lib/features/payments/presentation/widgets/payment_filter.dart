import 'package:flutter/material.dart';

class PaymentFilter extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const PaymentFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Lunas'),
                  _buildFilterChip('Menunggu'),
                  _buildFilterChip('Belum Bayar'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari penghuni atau kamar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: selectedFilter == filter,
        onSelected: (_) {
          onFilterChanged(filter);
        },
      ),
    );
  }
}
