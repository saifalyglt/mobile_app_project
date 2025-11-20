import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/hostel.dart';
import '../../../core/constants/app_constants.dart';

class AddHostelScreen extends ConsumerStatefulWidget {
  final String? hostelId;

  const AddHostelScreen({super.key, this.hostelId});

  @override
  ConsumerState<AddHostelScreen> createState() => _AddHostelScreenState();
}

class _AddHostelScreenState extends ConsumerState<AddHostelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final List<Room> _rooms = [];
  final List<String> _amenities = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.hostelId != null;
    if (_isEditMode) {
      _loadHostel();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadHostel() async {
    final service = ref.read(backendServiceProvider);
    final hostel = await service.getHostelById(widget.hostelId!);
    if (hostel != null) {
      _nameController.text = hostel.name;
      _cityController.text = hostel.city;
      _addressController.text = hostel.address;
      _descriptionController.text = hostel.description ?? '';
      _phoneController.text = hostel.phoneNumber ?? '';
      _emailController.text = hostel.email ?? '';
      _rooms.clear();
      _rooms.addAll(hostel.rooms);
      _amenities.clear();
      _amenities.addAll(hostel.amenities);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Hostel' : 'Add Hostel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hostel Name',
                  hintText: 'Enter hostel name',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter hostel name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter city',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter city' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter full address',
                ),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'Enter email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              
              // Room Types
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Room Types',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addRoom,
                  ),
                ],
              ),
              ..._rooms.asMap().entries.map((entry) {
                return _buildRoomCard(entry.key, entry.value);
              }),
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
                children: [
                  AppConstants.amenityWifi,
                  AppConstants.amenityFood,
                  AppConstants.amenitySecurity,
                  AppConstants.amenityAC,
                  AppConstants.amenityElectricityBackup,
                ].map((amenity) {
                  return FilterChip(
                    label: Text(amenity),
                    selected: _amenities.contains(amenity),
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
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : () => _saveHostel(user?.id ?? ''),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Update Hostel' : 'Add Hostel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(int index, Room room) {
    final typeController = TextEditingController(text: room.type);
    final priceController = TextEditingController(text: room.price.toString());
    final quantityController = TextEditingController(text: room.quantity.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                onChanged: (value) {
                  _rooms[index] = Room(
                    type: value,
                    price: _rooms[index].price,
                    quantity: _rooms[index].quantity,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _rooms[index] = Room(
                    type: _rooms[index].type,
                    price: double.tryParse(value) ?? 0,
                    quantity: _rooms[index].quantity,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _rooms[index] = Room(
                    type: _rooms[index].type,
                    price: _rooms[index].price,
                    quantity: int.tryParse(value) ?? 0,
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _rooms.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addRoom() {
    setState(() {
      _rooms.add(const Room(type: 'Single', price: 5000, quantity: 1));
    });
  }

  Future<void> _saveHostel(String ownerId) async {
    if (!_formKey.currentState!.validate()) return;
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one room type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(backendServiceProvider);
      final priceRange = PriceRange(
        min: _rooms.map((r) => r.price).reduce((a, b) => a < b ? a : b),
        max: _rooms.map((r) => r.price).reduce((a, b) => a > b ? a : b),
      );

      if (_isEditMode) {
        final existing = await service.getHostelById(widget.hostelId!);
        if (existing != null) {
          final updated = existing.copyWith(
            name: _nameController.text,
            city: _cityController.text,
            address: _addressController.text,
            priceRange: priceRange,
            rooms: _rooms,
            amenities: _amenities,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            phoneNumber:
                _phoneController.text.isEmpty ? null : _phoneController.text,
            email: _emailController.text.isEmpty ? null : _emailController.text,
          );
          await service.updateHostel(updated);
        }
      } else {
        await service.createHostel(
          ownerId: ownerId,
          name: _nameController.text,
          city: _cityController.text,
          address: _addressController.text,
          priceRange: priceRange,
          rooms: _rooms,
          amenities: _amenities,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          phoneNumber:
              _phoneController.text.isEmpty ? null : _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditMode
                  ? 'Hostel updated successfully'
                  : 'Hostel added successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

