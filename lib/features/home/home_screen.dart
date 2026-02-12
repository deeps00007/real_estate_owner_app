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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF673AB7),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: BlocBuilder<PropertyBloc, PropertyState>(
                          buildWhen: (previous, current) =>
                              previous.currentAddress != current.currentAddress,
                          builder: (context, state) {
                            return Text(
                              state.currentAddress ?? 'Brisbane, Queensland',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, size: 28),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: state.user?.photoURL != null
                        ? NetworkImage(state.user!.photoURL!)
                        : const NetworkImage(
                            'https://i.pravatar.cc/150?img=32',
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
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search your home...',
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
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.tune, color: Colors.black87),
        ),
      ],
    );
  }

  // Widget _buildCategories() {
  //   final categories = ['All', 'Rent', 'Buy', 'House', 'Apartment'];
  //   return SizedBox(
  //     height: 40,
  //     child: ListView.separated(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: categories.length,
  //       separatorBuilder: (_, __) => const SizedBox(width: 12),
  //       itemBuilder: (context, index) {
  //         final isSelected = index == 0; // Mock selection
  //         return Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
  //           decoration: BoxDecoration(
  //             color: isSelected
  //                 ? const Color(0xFF673AB7)
  //                 : const Color(0xFFF5F5F5),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Text(
  //             categories[index],
  //             style: TextStyle(
  //               color: isSelected ? Colors.white : Colors.grey[600],
  //               fontWeight: FontWeight.w500,
  //             ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
