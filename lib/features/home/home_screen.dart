import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_state.dart';
import '../../core/auth_bloc.dart'; // Added
import '../property_details/property_detail_screen.dart';
import 'widgets/property_card.dart';
import 'widgets/nearest_property_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 24),
              // _buildCategories(),
              // const SizedBox(height: 32),
              _buildSectionHeader('Best Offers', onSeeMore: () {}),
              const SizedBox(height: 16),
              _buildBestOffersList(context),
              const SizedBox(height: 32),
              _buildSectionHeader('Nearest You', onSeeMore: () {}),
              const SizedBox(height: 16),
              _buildNearestList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final name = user?.displayName?.split(' ').first ?? 'User';
        final photoUrl = user?.photoURL;

        return Row(
          children: [
            // 1. Avatar
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  image: DecorationImage(
                    image: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : const NetworkImage(
                            'https://i.pravatar.cc/150?img=32',
                          ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Name & Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<PropertyBloc, PropertyState>(
                    buildWhen: (previous, current) =>
                        previous.currentAddress != current.currentAddress,
                    builder: (context, state) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              state.currentAddress ?? 'Brisbane, Australia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. Notification Bell
            const SizedBox(width: 12),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for house, apartment...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0F2C59),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }

  // Widget _buildCategories() {
  //   final categories = [
  //     {'icon': Icons.grid_view, 'label': 'All'},
  //     {'icon': Icons.home_outlined, 'label': 'House'},
  //     {'icon': Icons.apartment_outlined, 'label': 'Apartment'},
  //   ];

  //   return SizedBox(
  //     height: 48,
  //     child: ListView.separated(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: categories.length,
  //       separatorBuilder: (_, __) => const SizedBox(width: 12),
  //       itemBuilder: (context, index) {
  //         final isSelected = index == 0; // Mock selection
  //         final item = categories[index];

  //         return Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //           decoration: BoxDecoration(
  //             color: isSelected ? const Color(0xFF673AB7) : Colors.transparent,
  //             borderRadius: BorderRadius.circular(24),
  //             border: Border.all(
  //               color: isSelected ? Colors.transparent : Colors.grey.shade300,
  //             ),
  //           ),
  //           child: Row(
  //             children: [
  //               if (isSelected) ...[
  //                 Icon(item['icon'] as IconData, color: Colors.white, size: 18),
  //                 const SizedBox(width: 8),
  //               ],
  //               Text(
  //                 item['label'] as String,
  //                 style: TextStyle(
  //                   color: isSelected ? Colors.white : Colors.grey[600],
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF1A1A1A),
          ),
        ),
        GestureDetector(
          onTap: onSeeMore,
          child: const Text(
            'See all',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBestOffersList(BuildContext context) {
    return SizedBox(
      height: 280,
      child: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state.properties.isEmpty) {
            return const Center(child: Text('No properties found'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.properties.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final property = state.properties[index];
              return PropertyCard(
                property: property,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailScreen(property: property),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNearestList(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state.properties.isEmpty) {
          return const SizedBox.shrink();
        }
        final reversed = state.properties.reversed.toList();

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reversed.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final property = reversed[index];
            return NearestPropertyCard(
              property: property,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailScreen(property: property),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
