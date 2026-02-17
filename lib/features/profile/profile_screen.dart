import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_bloc.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_event.dart'; // Added
import '../map/bloc/property_state.dart';
import 'my_properties_screen.dart';
import 'activity_list_screen.dart';
import 'static_content_screen.dart'; // Added
import '../admin/send_notification_screen.dart'; // Added

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
                  _buildListTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Send Notification',
                    subtitle: 'Broadcast to all users',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SendNotificationScreen(ownerId: user?.uid ?? ''),
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
                          sections: [
                            ContentSection(
                              title: 'Buying & Renting',
                              body:
                                  'Q: How do I schedule a viewing?\n'
                                  'A: Navigate to the property details page and tap the "Chat" button to connect directly with the agent or owner to arrange a visit.\n\n'
                                  'Q: Are the prices negotiable?\n'
                                  'A: Prices listed are asking prices. You can negotiate directly with the seller via our chat feature.',
                            ),
                            ContentSection(
                              title: 'Account Management',
                              body:
                                  'Q: How do I update my profile?\n'
                                  'A: Tap the edit icon on your profile picture to update your personal details.\n\n'
                                  'Q: Can I switch to an owner account?\n'
                                  'A: Yes, please contact support to upgrade your account status to list properties.',
                            ),
                            ContentSection(
                              title: 'Contact Support',
                              body:
                                  'Need more help? Reach out to our 24/7 support team at support@realestateapp.com or call +1-800-REAL-EST.',
                            ),
                          ],
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
                          lastUpdated: 'February 15, 2026',
                          sections: [
                            ContentSection(
                              title: '1. Information Collection',
                              body:
                                  'We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with other users. This may include your name, email address, phone number, and profile picture.',
                            ),
                            ContentSection(
                              title: '2. Usage of Information',
                              body:
                                  'We use the information we collect to operate and improve our services, facilitate communication between buyers and sellers, and detect and prevent fraud.',
                            ),
                            ContentSection(
                              title: '3. Data Sharing',
                              body:
                                  'We do not sell your personal data. We may share information with third-party service providers (e.g., cloud hosting, analytics) solely to support our application functionality.',
                            ),
                            ContentSection(
                              title: '4. Data Security',
                              body:
                                  'We implement industry-standard security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
                            ),
                          ],
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
                          lastUpdated: 'January 1, 2026',
                          sections: [
                            ContentSection(
                              title: '1. Acceptance of Terms',
                              body:
                                  'By accessing or using our application, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the service.',
                            ),
                            ContentSection(
                              title: '2. User Conduct',
                              body:
                                  'You agree strictly not to use the service for any unlawful purpose. You are responsible for all content you post and interactions you have with other users.',
                            ),
                            ContentSection(
                              title: '3. Property Listings',
                              body:
                                  'We strive for accuracy but do not guarantee that property descriptions or prices are error-free. We verify listings to the best of our ability but recommend personal due diligence.',
                            ),
                            ContentSection(
                              title: '4. Termination',
                              body:
                                  'We reserve the right to terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
                            ),
                          ],
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
