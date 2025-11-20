import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../constants/app_constants.dart';
import 'hostel.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking extends Equatable {
  final String id;
  final String hostelId;
  final String userId;
  final String roomType;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentMethod;
  final String? transactionId;
  final Hostel? hostel; // Populated when fetching user bookings

  const Booking({
    required this.id,
    required this.hostelId,
    required this.userId,
    required this.roomType,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentMethod,
    this.transactionId,
    this.hostel,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);

  @override
  List<Object?> get props => [
        id,
        hostelId,
        userId,
        roomType,
        startDate,
        endDate,
        amount,
        status,
        createdAt,
        updatedAt,
        paymentMethod,
        transactionId,
        hostel,
      ];

  Booking copyWith({
    String? id,
    String? hostelId,
    String? userId,
    String? roomType,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentMethod,
    String? transactionId,
    Hostel? hostel,
  }) {
    return Booking(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      userId: userId ?? this.userId,
      roomType: roomType ?? this.roomType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      hostel: hostel ?? this.hostel,
    );
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  bool get isActive {
    return status == AppConstants.bookingStatusConfirmed &&
        DateTime.now().isBefore(endDate);
  }

  bool get canCancel {
    return status != AppConstants.bookingStatusCancelled &&
        DateTime.now().isBefore(startDate);
  }
}
