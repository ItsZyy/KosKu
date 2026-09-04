import 'package:flutter/material.dart';

import '../../data/models/tenant_model.dart';
import 'tenant_card.dart';

class TenantList extends StatelessWidget {
  final List<TenantModel> tenants;
  final ValueChanged<TenantModel>? onDetail;

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
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tenant = tenants[index];

        return TenantCard(
          name: tenant.name,
          roomNumber: tenant.roomNumber,
          joinedDate: tenant.contractStart.toString(),
          status: tenant.status,
          photoUrl: tenant.profilePhotoUrl,
          onDetail: () => onDetail?.call(tenant),
        );
      },
    );
  }
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
