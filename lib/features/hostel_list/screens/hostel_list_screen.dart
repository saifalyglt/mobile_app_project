import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/hostel_provider.dart';
import '../../../core/models/hostel.dart';
import '../../../core/constants/app_constants.dart';

class HostelListScreen extends ConsumerStatefulWidget {
  final String? city;

  const HostelListScreen({super.key, this.city});

  @override
  ConsumerState<HostelListScreen> createState() => _HostelListScreenState();
}

class _HostelListScreenState extends ConsumerState<HostelListScreen> {
  String? _selectedCity;
  String? _sortBy;
  List<String> _selectedAmenities = [];
  double? _minPrice;
  double? _maxPrice;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.city;
  }

  @override
  Widget build(BuildContext context) {
    final filters = HostelFilters(
      city: _selectedCity,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities,
      sortBy: _sortBy,
      page: _currentPage,
      limit: _pageSize,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCity ?? 'All Hostels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Sort by: '),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy ?? AppConstants.sortNewest,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: AppConstants.sortNewest,
                        child: Text('Newest'),
                      ),
                      const DropdownMenuItem(
                        value: AppConstants.sortRating,
                        child: Text('Rating'),
                      ),
                      const DropdownMenuItem(
                        value: AppConstants.sortPriceLowHigh,
                        child: Text('Price: Low to High'),
                      ),
                      const DropdownMenuItem(
                        value: AppConstants.sortPriceHighLow,
                        child: Text('Price: High to Low'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Hostel list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final hostelsAsync = ref.watch(hostelListProvider(filters));

                return hostelsAsync.when(
                  data: (hostels) {
                    if (hostels.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hostels found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(hostelListProvider(filters));
                      },
                      child: ListView.builder(
                        itemCount: hostels.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          return _buildHostelCard(context, hostels[index]);
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(hostelListProvider(filters));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelCard(BuildContext context, Hostel hostel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/hostel/${hostel.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: hostel.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          hostel.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_outlined),
                        ),
                      )
                    : const Icon(Icons.image_outlined),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hostel.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hostel.isVerified)
                          Icon(
                            Icons.verified,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${hostel.city}, ${hostel.address}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${hostel.rating.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${hostel.reviewsCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...hostel.amenities.take(3).map((amenity) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(_getAmenityLabel(amenity)),
                                labelStyle: const TextStyle(fontSize: 10),
                                padding: EdgeInsets.zero,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PKR ${hostel.priceRange.min.toStringAsFixed(0)} - ${hostel.priceRange.max.toStringAsFixed(0)}/mo',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAmenityLabel(String amenity) {
    switch (amenity) {
      case AppConstants.amenityWifi:
        return 'Wi-Fi';
      case AppConstants.amenityFood:
        return 'Food';
      case AppConstants.amenitySecurity:
        return '24/7 Security';
      case AppConstants.amenityAC:
        return 'AC';
      default:
        return amenity;
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersBottomSheet(
        selectedCity: _selectedCity,
        selectedAmenities: _selectedAmenities,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (city, amenities, minPrice, maxPrice) {
          setState(() {
            _selectedCity = city;
            _selectedAmenities = amenities;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _currentPage = 0;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final String? selectedCity;
  final List<String> selectedAmenities;
  final double? minPrice;
  final double? maxPrice;
  final Function(String?, List<String>, double?, double?) onApply;

  const _FiltersBottomSheet({
    required this.selectedCity,
    required this.selectedAmenities,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late String? _city;
  late List<String> _amenities;
  late double? _minPrice;
  late double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _city = widget.selectedCity;
    _amenities = List.from(widget.selectedAmenities);
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // City filter
            Text('City', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter city name',
                prefixIcon: const Icon(Icons.location_city),
              ),
              onChanged: (value) => _city = value.isEmpty ? null : value,
              controller: TextEditingController(text: _city ?? ''),
            ),
            
            const SizedBox(height: 24),
            
            // Amenities filter
            Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                AppConstants.amenityWifi,
                AppConstants.amenityFood,
                AppConstants.amenitySecurity,
                AppConstants.amenityAC,
                AppConstants.amenityElectricityBackup,
              ].map((amenity) {
                final isSelected = _amenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _amenities.add(amenity);
                      } else {
                        _amenities.remove(amenity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Price range
            Text('Price Range (PKR)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min'),
                    onChanged: (value) =>
                        _minPrice = value.isEmpty ? null : double.tryParse(value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max'),
                    onChanged: (value) =>
                        _maxPrice = value.isEmpty ? null : double.tryParse(value),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _city = null;
                        _amenities = [];
                        _minPrice = null;
                        _maxPrice = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_city, _amenities, _minPrice, _maxPrice);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

