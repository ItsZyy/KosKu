import 'package:flutter/material.dart';

class TenantSearch extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const TenantSearch({super.key, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Cari penghuni atau nomor kamar...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
