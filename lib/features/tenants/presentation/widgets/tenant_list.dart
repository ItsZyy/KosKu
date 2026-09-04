import 'package:flutter/material.dart';
import 'tenant_card.dart';

class TenantList extends StatelessWidget {
  final List<TenantItem> tenants;
  final ValueChanged<TenantItem>? onDetail;
  const TenantList({super.key, required this.tenants, this.onDetail});
  @override
  Widget build(BuildContext context) {
    if (tenants.isEmpty) {
      return const _EmptyTenantState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tenants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        return TenantCard(
          name: tenant.name,
          roomNumber: tenant.roomNumber,
          joinedDate: tenant.joinedDate,
          status: tenant.status,
          photoUrl: tenant.photoUrl,
          onDetail: () => onDetail?.call(tenant),
        );
      },
    );
  }
}

class TenantItem {
  final String name;
  final String roomNumber;
  final String joinedDate;
  final String status;
  final String? photoUrl;
  const TenantItem({
    required this.name,
    required this.roomNumber,
    required this.joinedDate,
    required this.status,
    this.photoUrl,
  });
}

class _EmptyTenantState extends StatelessWidget {
  const _EmptyTenantState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text('Belum ada penghuni')),
    );
  }
}
