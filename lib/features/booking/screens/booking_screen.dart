import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/hostel_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/hostel.dart';
import 'package:uuid/uuid.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String hostelId;

  const BookingScreen({super.key, required this.hostelId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRoomType;
  Room? _selectedRoom;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelProvider(widget.hostelId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
      ),
      body: hostelAsync.when(
        data: (hostel) {
          if (hostel == null) {
            return const Center(child: Text('Hostel not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hostel info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hostel.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                hostel.city,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Room type selection
                Text(
                  'Select Room Type',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...hostel.rooms.map((room) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: RadioListTile<Room>(
                        title: Text(room.type),
                        subtitle: Text(
                          'PKR ${room.price.toStringAsFixed(0)}/month • ${room.availableQuantity ?? room.quantity} available',
                        ),
                        value: room,
                        groupValue: _selectedRoom,
                        onChanged: (value) {
                          setState(() {
                            _selectedRoom = value;
                            _selectedRoomType = value?.type;
                          });
                        },
                      ),
                    )),

                const SizedBox(height: 24),

                // Date selection
                Text(
                  'Select Dates',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Check-in Date'),
                          subtitle: Text(_startDate == null
                              ? 'Select date'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectDate(context, true),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Check-out Date'),
                          subtitle: Text(_endDate == null
                              ? 'Select date'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Price summary
                if (_selectedRoom != null && _startDate != null && _endDate != null)
                  Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Summary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Room type:'),
                              Text(
                                _selectedRoom!.type,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Duration:'),
                              Text(
                                '${_endDate!.difference(_startDate!).inDays} days',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount:',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'PKR ${_calculateTotal().toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: Container(
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
        child: ElevatedButton(
          onPressed: _canProceed() ? () => _proceedToPayment() : null,
          child: const Text('Proceed to Payment'),
        ),
      ),
    );
  }

  bool _canProceed() {
    return _selectedRoom != null && _startDate != null && _endDate != null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final firstDate = isStartDate ? now : (_startDate ?? now);
    final lastDate = DateTime(now.year + 1);

    final selected = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? now)
          : (_endDate ?? _startDate?.add(const Duration(days: 30)) ?? now),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selected;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          if (selected.isAfter(_startDate!)) {
            _endDate = selected;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date must be after start date')),
            );
          }
        }
      });
    }
  }

  double _calculateTotal() {
    if (_selectedRoom == null || _startDate == null || _endDate == null) {
      return 0;
    }
    final days = _endDate!.difference(_startDate!).inDays;
    final months = (days / 30).ceil();
    return _selectedRoom!.price * months;
  }

  Future<void> _proceedToPayment() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        context.go('/sign-in');
      }
      return;
    }

    final total = _calculateTotal();
    final bookingId = const Uuid().v4();

    setState(() => _isLoading = true);

    try {
      final service = ref.read(backendServiceProvider);
      await service.createBooking(
        hostelId: widget.hostelId,
        userId: user.id,
        roomType: _selectedRoomType!,
        startDate: _startDate!,
        endDate: _endDate!,
        amount: total,
        paymentMethod: 'Demo Payment',
        transactionId: 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        context.push('/booking-confirmation/$bookingId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

