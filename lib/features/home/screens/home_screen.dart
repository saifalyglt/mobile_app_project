import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/hostel_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/hostel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final filters = HostelFilters(sortBy: 'rating', limit: 6);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user?.name ?? 'Guest'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Find your perfect hostel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search hostels, cities...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      // TODO: Show filter bottom sheet
                    },
                  ),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    context.push('/hostels?city=$query');
                  }
                },
              ),
            ),

            // Quick Filters
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildQuickFilterChip('All Cities', null, () {
                    context.push('/hostels');
                  }),
                  _buildQuickFilterChip('Lahore', 'Lahore', () {
                    context.push('/hostels?city=Lahore');
                  }),
                  _buildQuickFilterChip('Karachi', 'Karachi', () {
                    context.push('/hostels?city=Karachi');
                  }),
                  _buildQuickFilterChip('Islamabad', 'Islamabad', () {
                    context.push('/hostels?city=Islamabad');
                  }),
                  _buildQuickFilterChip('Rawalpindi', 'Rawalpindi', () {
                    context.push('/hostels?city=Rawalpindi');
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Featured Hostels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Hostels',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/hostels'),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Hostel List
            Consumer(
              builder: (context, ref, child) {
                final hostelsAsync = ref.watch(hostelListProvider(filters));

                return hostelsAsync.when(
                  data: (hostels) {
                    if (hostels.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No hostels found')),
                      );
                    }

                    return SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hostels.length,
                        itemBuilder: (context, index) {
                          final hostel = hostels[index];
                          return _buildHostelCard(context, hostel);
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(child: Text('Error: $error')),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, String? city, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildHostelCard(BuildContext context, Hostel hostel) {
    return GestureDetector(
      onTap: () => context.push('/hostel/${hostel.id}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: hostel.thumbnailUrl != null
                    ? Image.network(
                        hostel.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_outlined, size: 48),
                      )
                    : const Icon(Icons.image_outlined, size: 48),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
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
                            hostel.city,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                          ],
                        ),
                        Text(
                          'PKR ${hostel.priceRange.min.toStringAsFixed(0)}/mo',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
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
}

