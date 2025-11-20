import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../constants/app_constants.dart';

part 'user_model.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;
  final Map<String, dynamic>? ownerInfo; // For owner role
  final bool? isOwnerVerified; // For owner role
  final List<String>? favoriteHostelIds;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.ownerInfo,
    this.isOwnerVerified,
    this.favoriteHostelIds,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phoneNumber,
        photoUrl,
        role,
        createdAt,
        ownerInfo,
        isOwnerVerified,
        favoriteHostelIds,
      ];

  bool get isStudent => role == AppConstants.roleStudent;
  bool get isOwner => role == AppConstants.roleOwner;
  bool get isAdmin => role == AppConstants.roleAdmin;

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    Map<String, dynamic>? ownerInfo,
    bool? isOwnerVerified,
    List<String>? favoriteHostelIds,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      ownerInfo: ownerInfo ?? this.ownerInfo,
      isOwnerVerified: isOwnerVerified ?? this.isOwnerVerified,
      favoriteHostelIds: favoriteHostelIds ?? this.favoriteHostelIds,
    );
  }
}
