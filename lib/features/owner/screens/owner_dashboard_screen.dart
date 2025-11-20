import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/hostel.dart';
import '../../../core/models/booking.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, ${user?.name ?? 'Owner'}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/owner/add-hostel'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (mounted) {
                  context.go('/sign-in');
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Hostels'),
              Tab(text: 'Bookings'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: user == null
            ? const Center(child: Text('Please sign in'))
            : TabBarView(
                children: [
                  _buildMyHostelsTab(user.id),
                  _buildBookingsTab(user.id),
                  _buildProfileTab(user),
                ],
              ),
      ),
    );
  }

  Widget _buildMyHostelsTab(String ownerId) {
    return FutureBuilder<List<Hostel>>(
      future: _getOwnerHostels(ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final hostels = snapshot.data ?? [];

        if (hostels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hostels yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.push('/owner/add-hostel'),
                  child: const Text('Add Hostel'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hostels.length,
          itemBuilder: (context, index) {
            final hostel = hostels[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
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
                          ),
                        )
                      : const Icon(Icons.image_outlined),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(hostel.name)),
                    if (hostel.isVerified)
                      Icon(
                        Icons.verified,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hostel.city),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(' ${hostel.rating.toStringAsFixed(1)}'),
                        Text(' • ${hostel.reviewsCount} reviews'),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('View'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/owner/edit-hostel/${hostel.id}');
                    } else if (value == 'view') {
                      context.push('/hostel/${hostel.id}');
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingsTab(String ownerId) {
    return FutureBuilder<List<Booking>>(
      future: ref.read(backendServiceProvider).getOwnerBookings(ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No bookings yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Booking #${booking.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room: ${booking.roomType}'),
                    Text(
                        '${booking.startDate.toString().split(' ')[0]} - ${booking.endDate.toString().split(' ')[0]}'),
                    Text(
                      'PKR ${booking.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                trailing: booking.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _updateBookingStatus(booking.id, 'confirmed'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _updateBookingStatus(booking.id, 'cancelled'),
                          ),
                        ],
                      )
                    : Chip(
                        label: Text(
                          booking.status,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: booking.status == 'confirmed'
                            ? Colors.green
                            : booking.status == 'cancelled'
                                ? Colors.red
                                : Colors.orange,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            child: Text(
              (user.name ?? user.email)[0].toUpperCase(),
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? 'Owner',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(user.email),
          if (user.isOwnerVerified == false) ...[
            const SizedBox(height: 24),
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.pending, color: Colors.orange, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Verification Pending',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account verification is pending. Admin will review your documents.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<List<Hostel>> _getOwnerHostels(String ownerId) async {
    final service = ref.read(backendServiceProvider);
    final allHostels = await service.getHostels();
    return allHostels.where((h) => h.ownerId == ownerId).toList();
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    // TODO: Implement booking status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking status updated to $status')),
    );
    setState(() {});
  }
}

