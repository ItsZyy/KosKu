class ProfileModel {
  final String id;
  final String name;
  final String? phone;
  final String? profilePhotoUrl;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? address;
  final String? kosAddress;
  final String role;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    this.phone,
    this.profilePhotoUrl,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.address,
    this.kosAddress,
    required this.role,
    this.createdAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      emergencyContactRelation: map['emergency_contact_relation'] as String?,
      address: map['address'] as String?,
      kosAddress: map['kos_address'] as String?,
      role: map['role'] as String? ?? 'user',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }
}
