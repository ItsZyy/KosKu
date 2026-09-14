import 'package:kosku/features/complaints/data/models/complaint_model.dart';
import 'package:kosku/features/payments/data/models/payment_model.dart';
import 'package:kosku/features/rooms/data/models/facility_model.dart';
import 'package:kosku/features/rooms/data/models/room_model.dart';

class RoomDetailUser {
  final String userId;
  final String name;
  final String? phone;
  final String? profilePhotoUrl;
  final DateTime? contractStart;
  final DateTime? contractEnd;
  final double rentPrice;
  final String? occupancyStatus;

  const RoomDetailUser({
    required this.userId,
    required this.name,
    this.phone,
    this.profilePhotoUrl,
    this.contractStart,
    this.contractEnd,
    required this.rentPrice,
    this.occupancyStatus,
  });
}

class RoomDetailModel {
  final RoomModel room;
  final List<FacilityModel> facilities;
  final List<RoomDetailUser> users;
  final List<Payment> payments;
  final List<ComplaintModel> complaints;

  const RoomDetailModel({
    required this.room,
    required this.facilities,
    required this.users,
    required this.payments,
    required this.complaints,
  });
}
