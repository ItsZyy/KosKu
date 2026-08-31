import 'package:flutter/material.dart';

class ComplaintFilter extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  final int total;
  final int menunggu;
  final int diproses;
  final int selesai;

  const ComplaintFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.total,
    required this.menunggu,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('Semua', total),
      ('Menunggu', menunggu),
      ('Diproses', diproses),
      ('Selesai', selesai),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final name = filter.$1;
          final count = filter.$2;
          final isSelected = selectedFilter == name;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$name ($count)'),
              selected: isSelected,
              onSelected: (_) {
                onFilterChanged(name);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
