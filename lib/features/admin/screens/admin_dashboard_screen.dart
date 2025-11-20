import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
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
              Tab(text: 'Owner Verifications'),
              Tab(text: 'Metrics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOwnerVerificationsTab(),
            _buildMetricsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerVerificationsTab() {
    return FutureBuilder<List<AppUser>>(
      future: ref.read(backendServiceProvider).getPendingOwnerVerifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final owners = snapshot.data ?? [];

        if (owners.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No pending verifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: owners.length,
          itemBuilder: (context, index) {
            final owner = owners[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(owner.name?[0].toUpperCase() ?? owner.email[0].toUpperCase()),
                ),
                title: Text(owner.name ?? 'Owner'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(owner.email),
                    if (owner.phoneNumber != null) Text(owner.phoneNumber!),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _verifyOwner(owner.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // TODO: Reject owner
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final metrics = snapshot.data ?? {};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMetricCard(
              'Total Hostels',
              '${metrics['totalHostels'] ?? 0}',
              Icons.business,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Total Bookings',
              '${metrics['totalBookings'] ?? 0}',
              Icons.book,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Total Users',
              '${metrics['totalUsers'] ?? 0}',
              Icons.people,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Pending Verifications',
              '${metrics['pendingVerifications'] ?? 0}',
              Icons.pending,
              Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getMetrics() async {
    final service = ref.read(backendServiceProvider);
    final hostels = await service.getHostels();
    final pendingOwners = await service.getPendingOwnerVerifications();
    
    // Get bookings count (would need a method in service)
    return {
      'totalHostels': hostels.length,
      'totalBookings': 0, // TODO: Add booking count method
      'totalUsers': 0, // TODO: Add user count method
      'pendingVerifications': pendingOwners.length,
    };
  }

  Future<void> _verifyOwner(String userId) async {
    try {
      await ref.read(backendServiceProvider).verifyOwner(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner verified successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

