import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../core/auth_bloc.dart';
import '../../core/image_upload_service.dart';
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
  late TextEditingController _bedsController;
  late TextEditingController _bathsController;
  late TextEditingController _sqftController;
  late TextEditingController _agentNameController;
  late TextEditingController _agentPhoneController;
  bool _hasKitchen = false;
  List<String> _galleryUrls = [];
  List<File> _galleryFiles = [];

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
    _bedsController = TextEditingController(
      text: widget.property?.beds.toString() ?? '0',
    );
    _bathsController = TextEditingController(
      text: widget.property?.baths.toString() ?? '0',
    );
    _sqftController = TextEditingController(
      text: widget.property?.sqft.toString() ?? '0.0',
    );
    _agentNameController = TextEditingController(
      text: widget.property?.agentName ?? '',
    );
    _agentPhoneController = TextEditingController(
      text: widget.property?.agentPhone ?? '',
    );
    _hasKitchen = widget.property?.hasKitchen ?? false;
    _galleryUrls = List.from(widget.property?.gallery ?? []);

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
    _bedsController.dispose();
    _bathsController.dispose();
    _sqftController.dispose();
    _agentNameController.dispose();
    _agentPhoneController.dispose();
    super.dispose();
  }

  File? _selectedImage;
  bool _isUploading = false;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageUrlController.clear(); // Clear URL if local image selected
      });
    }
  }

  void _pickGalleryImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _galleryFiles.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
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

  Future<void> _saveProperty() async {
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

      setState(() => _isUploading = true);

      String imageUrl = _imageUrlController.text;
      if (_selectedImage != null) {
        final uploadedUrl = await ImageUploadService().uploadImage(
          _selectedImage!,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
            setState(() => _isUploading = false);
            return;
          }
        }
      }

      if (imageUrl.isEmpty) {
        imageUrl = 'https://picsum.photos/400/300'; // Default
      }

      // Upload Gallery Images
      List<String> finalGallery = List.from(_galleryUrls);
      if (_galleryFiles.isNotEmpty) {
        for (var file in _galleryFiles) {
          final url = await ImageUploadService().uploadImage(file);
          if (url != null) {
            finalGallery.add(url);
          }
        }
      }

      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int beds = int.tryParse(_bedsController.text) ?? 0;
      final int baths = int.tryParse(_bathsController.text) ?? 0;
      final double sqft = double.tryParse(_sqftController.text) ?? 0.0;

      final property = Property(
        id: widget.isEdit
            ? widget.property!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        price: price,
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
        imageUrl: imageUrl,
        type: _typeController.text,
        ownerId: ownerId,
        address: _addressController.text,
        beds: beds,
        baths: baths,
        sqft: sqft,
        hasKitchen: _hasKitchen,
        agentName: _agentNameController.text,
        agentPhone: _agentPhoneController.text,
        gallery: finalGallery,
      );

      if (!mounted) return;

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
            // Image Preview (Local or Network)
            if (_selectedImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (_imageUrlController.text.isNotEmpty)
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

            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
            if (_isUploading) ...[
              const SizedBox(height: 10),
              const Center(child: LinearProgressIndicator()),
              const Center(child: Text('Uploading Image...')),
            ],
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gallery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _pickGalleryImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                ),
              ],
            ),
            if (_galleryUrls.isNotEmpty || _galleryFiles.isNotEmpty)
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._galleryUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    ..._galleryFiles.map(
                      (file) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            const Text(
              'Amenities & Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Beds',
                    _bedsController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Baths',
                    _bathsController,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Area (sqft)',
                    _sqftController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Kitchen'),
                    value: _hasKitchen,
                    onChanged: (val) => setState(() => _hasKitchen = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Listing Agent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField('Agent Name', _agentNameController),
            const SizedBox(height: 16),
            _buildTextField(
              'Agent Phone',
              _agentPhoneController,
              isNumber: true,
            ),

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
