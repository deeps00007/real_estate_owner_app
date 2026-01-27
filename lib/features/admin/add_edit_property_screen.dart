import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../core/auth_bloc.dart';
import '../../models/property.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_event.dart';
import '../map/location_picker_screen.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final Property? property; // If null, we are adding new
  final bool isEdit;

  const AddEditPropertyScreen({super.key, this.property})
    : isEdit = property != null;

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;
  late TextEditingController _imageUrlController;
  late TextEditingController _typeController;

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.property?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.property?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.property?.price.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: widget.property?.address ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.property?.imageUrl ?? '',
    );
    _typeController = TextEditingController(
      text: widget.property?.type ?? 'Apartment',
    );

    if (widget.isEdit) {
      _selectedLocation = LatLng(widget.property!.lat, widget.property!.lng);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _saveProperty() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on map')),
        );
        return;
      }

      final ownerId = context.read<AuthBloc>().state.ownerId;
      if (ownerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Not logged in as owner')),
        );
        return;
      }

      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final property = Property(
        id: widget.isEdit
            ? widget.property!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        price: price,
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : 'https://picsum.photos/400/300', // Default
        type: _typeController.text,
        ownerId: ownerId,
        address: _addressController.text,
      );

      final bloc = context.read<PropertyBloc>();
      if (widget.isEdit) {
        bloc.add(UpdateProperty(property));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Property Updated!')));
      } else {
        bloc.add(AddProperty(property));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Property Added!')));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Property' : 'Add New Property'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image Preview (if URL valid)
            if (_imageUrlController.text.isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_imageUrlController.text),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            _buildTextField('Title', _titleController),
            const SizedBox(height: 16),
            _buildTextField('Price', _priceController, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField('Type (e.g., Apartment)', _typeController),
            const SizedBox(height: 16),
            _buildTextField('Description', _descController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Address / Location Name', _addressController),
            const SizedBox(height: 16),
            _buildTextField('Image URL', _imageUrlController),

            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Location Coordinates'),
              subtitle: Text(
                _selectedLocation != null
                    ? '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                    : 'Not selected',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.map, color: Color(0xFFFF80AB)),
                onPressed: _pickLocation,
              ),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF80AB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.isEdit ? 'Update Listing' : 'Publish Listing',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
