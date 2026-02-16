import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_bloc.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_event.dart'; // Added
import '../map/bloc/property_state.dart';
import 'my_properties_screen.dart';
import 'activity_list_screen.dart';
import 'static_content_screen.dart'; // Added

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(LoadUserActivity());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final isOwner = state.isOwner;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.black),
                onPressed: () {
                  // TODO: Navigate to Settings
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : const NetworkImage(
                                    'https://i.pravatar.cc/300?img=5',
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF673AB7), // Deep Purple
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isOwner
                            ? 'Admin User'
                            : (user?.displayName ?? 'Guest User'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'admin@realestate.com',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // 2. Owner Tools (If Owner)
                if (isOwner) ...[
                  _buildSectionHeader('Owner Tools'),
                  _buildListTile(
                    icon: Icons.home_work_outlined,
                    title: 'My Properties',
                    subtitle: 'Manage your listings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyPropertiesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                ],

                // 3. My Activity
                BlocBuilder<PropertyBloc, PropertyState>(
                  builder: (context, propertyState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('My Activity'),
                        _buildListTile(
                          icon: Icons.favorite_border,
                          title: 'Saved Properties',
                          subtitle:
                              '${propertyState.savedPropertyIds.length} items',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityListScreen(
                                  title: 'Saved Properties',
                                  propertyIds: propertyState.savedPropertyIds,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          icon: Icons.history,
                          title: 'Recently Viewed',
                          subtitle:
                              '${propertyState.recentPropertyIds.length} items',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityListScreen(
                                  title: 'Recently Viewed',
                                  propertyIds: propertyState.recentPropertyIds,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          icon: Icons.chat_bubble_outline,
                          title: 'My Inquiries',
                          onTap: () {}, // TODO: Link to Chat
                        ),
                        const Divider(height: 32),
                      ],
                    );
                  },
                ),

                // 4. Support & Legal
                _buildSectionHeader('Support & Legal'),
                _buildListTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaticContentScreen(
                          title: 'Help Center',
                          content:
                              'Welcome to the Real Estate App Help Center.\n\n'
                              'Frequently Asked Questions:\n\n'
                              '1. How do I contact a listing agent?\n'
                              '   - Go to the property details page and click the "Chat" icon to start a conversation.\n\n'
                              '2. How can I save a property?\n'
                              '   - Tap the heart icon on any property card or detail page to add it to your Saved Properties.\n\n'
                              '3. Can I list my own property?\n'
                              '   - Yes! If you are an owner, you can use the "Add Property" feature in the main menu.\n\n'
                              'For further assistance, please contact support@realestateapp.com.',
                        ),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaticContentScreen(
                          title: 'Privacy Policy',
                          content:
                              'Privacy Policy\n\n'
                              'Last updated: February 2026\n\n'
                              '1. Information We Collect\n'
                              '   - We collect personal information you provide, such as name, email, and user preferences.\n\n'
                              '2. How We Use Your Information\n'
                              '   - To provide and improve our services.\n'
                              '   - To communicate with you regarding your account or listings.\n\n'
                              '3. Data Security\n'
                              '   - We implement security measures to protect your data.\n\n'
                              '4. Your Rights\n'
                              '   - You can access, update, or delete your personal information through your profile settings.\n\n'
                              'By using this app, you agree to the collection and use of information in accordance with this policy.',
                        ),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaticContentScreen(
                          title: 'Terms of Service',
                          content:
                              'Terms of Service\n\n'
                              '1. Acceptance of Terms\n'
                              '   - By accessing usage of this app, you agree to be bound by these Terms.\n\n'
                              '2. User Accounts\n'
                              '   - You are responsible for maintaining the confidentiality of your account credentials.\n\n'
                              '3. Prohibited Conduct\n'
                              '   - You agree not to use the app for any unlawful purpose or to harass others.\n\n'
                              '4. Liability\n'
                              '   - We are not liable for any damages arising from your use of this app.\n\n'
                              '5. Changes to Terms\n'
                              '   - We reserve the right to modify these terms at any time.',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Logout Header
                Center(
                  child: TextButton(
                    onPressed: () {
                      print("ProfileScreen: Logout tapped");
                      context.read<AuthBloc>().add(Logout());
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 80), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
