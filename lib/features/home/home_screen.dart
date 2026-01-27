import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_state.dart';
import '../property_details/property_detail_screen.dart';
import 'widgets/property_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // High contrast off-white
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              _buildHeader(context),
              const SizedBox(height: 24),

              // 2. Search Bar
              _buildSearchBar(context),
              const SizedBox(height: 32),

              // 3. Featured Properties
              _buildSectionHeader('Featured Properties', onSeeMore: () {}),
              const SizedBox(height: 16),
              _buildFeaturedList(context),
              const SizedBox(height: 32),

              // 4. Recommended Properties
              _buildSectionHeader('Recommended for You', onSeeMore: () {}),
              const SizedBox(height: 16),
              _buildRecommendedList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF80AB),
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Silverlake, Los Angeles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://i.pravatar.cc/150?img=32',
                ), // Mock Avatar
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
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
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onSubmitted: (value) {
                      // Handle Search on Home? Or navigate to Map?
                      // For now, let's just log or no-op
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: const Color(
              0xFFF5F5F5,
            ), // Or Pink? Design has pink icon on grey bg
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.tune, color: Color(0xFFFF80AB)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: onSeeMore,
          child: const Text(
            'See More',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedList(BuildContext context) {
    return SizedBox(
      height: 320, // Height for the card
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
                isFeatured: true, // Use the large vertical card style
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

  Widget _buildRecommendedList(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state.properties.isEmpty) {
          return const SizedBox.shrink();
        }
        // Just taking the last few as "Recommended" for variety
        final recommended = state.properties.reversed.toList();

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: recommended.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final property = recommended[index];
            return PropertyCard(
              property: property,
              isFeatured: false, // Use standard horizontal style
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
