import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/hostel_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/hostel.dart';
import '../../../core/constants/app_constants.dart';
import '../../reviews/widgets/review_list_widget.dart';

class HostelDetailScreen extends ConsumerStatefulWidget {
  final String hostelId;

  const HostelDetailScreen({super.key, required this.hostelId});

  @override
  ConsumerState<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends ConsumerState<HostelDetailScreen> {
  int _selectedImageIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelProvider(widget.hostelId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: hostelAsync.when(
        data: (hostel) {
          if (hostel == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Hostel not found')),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with images
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageGallery(hostel),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                    onPressed: () {
                      if (user != null) {
                        _toggleFavorite(hostel.id, user.id);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement share
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hostel.name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    if (hostel.isVerified)
                                      Icon(
                                        Icons.verified,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${hostel.city}, ${hostel.address}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      hostel.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${hostel.reviewsCount} reviews',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Price range
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'PKR ${hostel.priceRange.min.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                                Text(
                                  'Starting from',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Container(width: 1, height: 40, color: Colors.grey[300]),
                            Column(
                              children: [
                                Text(
                                  'PKR ${hostel.priceRange.max.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                                Text(
                                  'Maximum',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Amenities
                      Text(
                        'Amenities',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hostel.amenities.map((amenity) {
                          return Chip(
                            avatar: Icon(_getAmenityIcon(amenity)),
                            label: Text(_getAmenityLabel(amenity)),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      if (hostel.description != null) ...[
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hostel.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Room types
                      Text(
                        'Room Types',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...hostel.rooms.map((room) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(room.type),
                              subtitle: Text('${room.availableQuantity ?? room.quantity} available'),
                              trailing: Text(
                                'PKR ${room.price.toStringAsFixed(0)}/mo',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                          )),

                      const SizedBox(height: 24),

                      // Contact Info
                      if (hostel.phoneNumber != null || hostel.email != null) ...[
                        Text(
                          'Contact',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (hostel.phoneNumber != null)
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('Phone'),
                            subtitle: Text(hostel.phoneNumber!),
                            onTap: () {
                              // TODO: Make phone call
                            },
                          ),
                        if (hostel.email != null)
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Email'),
                            subtitle: Text(hostel.email!),
                            onTap: () {
                              // TODO: Send email
                            },
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Reviews
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ReviewListWidget(hostelId: hostel.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error: $error')),
        ),
      ),
      bottomNavigationBar: hostelAsync.when(
        data: (hostel) {
          if (hostel == null) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Message owner
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Messaging feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (user == null) {
                        context.go('/sign-in');
                      } else {
                        context.push('/booking/${hostel.id}');
                      }
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildImageGallery(Hostel hostel) {
    final images = hostel.gallery.isNotEmpty ? hostel.gallery : [hostel.thumbnailUrl];
    
    if (images.isEmpty || images.first == null) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_outlined, size: 64),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      onPageChanged: (index) {
        setState(() {
          _selectedImageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return Image.network(
          images[index] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_outlined, size: 64),
          ),
        );
      },
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity) {
      case AppConstants.amenityWifi:
        return Icons.wifi;
      case AppConstants.amenityFood:
        return Icons.restaurant;
      case AppConstants.amenitySecurity:
        return Icons.security;
      case AppConstants.amenityAC:
        return Icons.ac_unit;
      case AppConstants.amenityElectricityBackup:
        return Icons.battery_charging_full;
      default:
        return Icons.check_circle;
    }
  }

  String _getAmenityLabel(String amenity) {
    switch (amenity) {
      case AppConstants.amenityWifi:
        return 'Wi-Fi';
      case AppConstants.amenityElectricityBackup:
        return 'Electricity Backup';
      case AppConstants.amenityFood:
        return 'Food Provided';
      case AppConstants.amenitySecurity:
        return '24/7 Security';
      case AppConstants.amenityAC:
        return 'Air Conditioning';
      default:
        return amenity;
    }
  }

  Future<void> _toggleFavorite(String hostelId, String userId) async {
    final service = ref.read(backendServiceProvider);
    await service.toggleFavorite(hostelId, userId);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }
}

