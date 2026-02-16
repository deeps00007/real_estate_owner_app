import 'package:flutter/material.dart';
import 'package:real_estate_owner_app/models/property.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_bloc.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_event.dart';
import '../admin/add_edit_property_screen.dart';
import '../chat/chat_screen.dart'; // Added
import '../chat/chat_service.dart'; // Added
import 'package:flutter_map_smart/flutter_map_smart.dart';
import 'package:flutter_map/flutter_map.dart' show MapController, TileLayer;
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final MapController _mapController = MapController();
  // Maintain local state for current zoom if needed, but controller handles it.

  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(
          images: widget.property.gallery,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Header)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: GestureDetector(
              onTap: () => _openGallery(context, 0),
              child: CachedNetworkImage(
                imageUrl: property.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // 2. Action Icons (Back, Favorite)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleIcon(
                  context,
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                // Owner Actions
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.isOwner && state.ownerId == property.ownerId) {
                      return Row(
                        children: [
                          _buildCircleIcon(
                            context,
                            icon: Icons.edit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditPropertyScreen(property: property),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildCircleIcon(
                            context,
                            icon: Icons.delete,
                            onTap: () {
                              context.read<PropertyBloc>().add(
                                DeleteProperty(property.id),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Property Deleted'),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return _buildCircleIcon(
                        context,
                        icon: Icons.favorite_border,
                        onTap: () {}, // TODO: Favorite toggle
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // 3. Main Content Sheet
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.4 - 30, // Overlap
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    32,
                    24,
                    100,
                  ), // Bottom padding for sticky bar
                  children: [
                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gallery (Thumbnail placeholder)
                              if (property.gallery.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: property.gallery.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () =>
                                            _openGallery(context, index),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: property.gallery[index],
                                            width: 90,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      width: 90,
                                                      height: 80,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),
                              Text(
                                property.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      property.address ?? 'No Address Provided',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amenities
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmenityItem(
                          Icons.bed_outlined,
                          '${property.beds} Beds',
                        ),
                        _buildAmenityItem(
                          Icons.bathtub_outlined,
                          '${property.baths} Baths',
                        ),
                        _buildAmenityItem(
                          Icons.aspect_ratio,
                          '${property.sqft.toStringAsFixed(0)} sqft',
                        ),
                        if (property.hasKitchen)
                          _buildAmenityItem(Icons.kitchen_outlined, 'Kitchen'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Host Info Card
                    const Text(
                      'Listing Agent',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          style: BorderStyle
                              .solid, // Can change to dashed manually or use a package
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: property.ownerPhotoUrl != null
                                ? NetworkImage(property.ownerPhotoUrl!)
                                : null,
                            child: property.ownerPhotoUrl == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.agentName.isNotEmpty
                                      ? property.agentName
                                      : 'Listing Agent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (property.agentPhone.isNotEmpty)
                                  Text(
                                    property.agentPhone,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildContactButton(
                                icon: Icons.chat_bubble_outline,
                                onTap: () => _handleChat(context),
                              ),
                              const SizedBox(width: 12),
                              _buildContactButton(
                                icon: Icons.phone_outlined,
                                onTap: () {
                                  // TODO: Implement phone call
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Phone call not implemented',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Description
                    const Text(
                      'About this home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      property.description,
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // Location Map
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FlutterMapSmart.simple(
                          items: [property],
                          mapController: _mapController,
                          initialCenter: LatLng(property.lat, property.lng),
                          initialZoom: 15.0, // Start slightly zoomed out
                          latitude: (p) => p.lat,
                          longitude: (p) => p.lng,
                          markerImage: (p) => p.imageUrl,
                          onTap: (p) {
                            // Zoom in on marker click
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(
                              LatLng(property.lat, property.lng),
                              currentZoom + 1,
                            );
                          },
                          // children: [
                          //   TileLayer(
                          //     urlTemplate:
                          //         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          //     userAgentPackageName:
                          //         'com.realestate.owner.app.v1',
                          //   ),
                          // ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // 4. Sticky Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          property.formattedPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D2D2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(
                          120,
                          50,
                        ), // Override global infinite width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Rent Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF2D2D2D)),
      ),
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.grey[600], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Future<void> _handleChat(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to chat')));
      return;
    }

    if (user.uid == widget.property.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    final ownerId = widget.property.ownerId;
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner information not available')),
      );
      return;
    }

    try {
      final chatService = ChatService();
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final chatId = await chatService.getOrCreateChat(
        user.uid,
        ownerId,
        widget.property.id,
      );

      // Dismiss loading
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              currentUserId: user.uid,
              otherUserName: widget.property.agentName.isNotEmpty
                  ? widget.property.agentName
                  : 'Listing Agent',
              otherUserId: ownerId,
              currentUserName: user.displayName ?? 'User',
            ),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading if showing
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
      }
    }
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white, size: 50),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
