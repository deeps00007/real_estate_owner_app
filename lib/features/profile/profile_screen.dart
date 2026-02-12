import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_bloc.dart';
import 'my_properties_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFF80AB), // Pink background
          body: Stack(
            children: [
              // 1. Header Content
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 300,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleIcon(Icons.menu),
                            _buildCircleIcon(Icons.edit),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: state.user?.photoURL != null
                                ? NetworkImage(state.user!.photoURL!)
                                : const NetworkImage(
                                    'https://i.pravatar.cc/300?img=5',
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Info
                        Text(
                          state.isOwner
                              ? 'Admin User'
                              : (state.user?.displayName ?? 'Guest User'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.isOwner
                              ? 'admin@realestate.com'
                              : (state.user?.email ?? 'No Email'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Main Content Sheet
              Positioned.fill(
                top: 280, // Overlap
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (state.isOwner) ...[
                        _buildMenuItem(
                          context,
                          Icons.home_work,
                          'My Properties',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MyPropertiesScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildMenuItem(
                        context,
                        Icons.person,
                        'My Profile',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        Icons.palette,
                        'App Theme',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        Icons.settings,
                        'Settings',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        Icons.notifications,
                        'Notifications',
                        onTap: () {},
                      ),
                      const SizedBox(height: 40),

                      // Actions
                      _buildActionButton(
                        context,
                        label: state.isOwner
                            ? 'Switch to User'
                            : 'Switch Account',
                        isPrimary: true,
                        onTap: () {
                          if (state.isOwner) {
                            context.read<AuthBloc>().add(Logout());
                          } else {
                            _showAdminLoginDialog(context);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        context,
                        label: 'Logout',
                        isPrimary: false,
                        onTap: () {
                          context.read<AuthBloc>().add(Logout());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFFFF80AB), size: 24),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF80AB)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFFFF80AB) : Colors.grey[200],
        foregroundColor: isPrimary ? Colors.white : Colors.grey,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 56), // Ensure standard height
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isPrimary ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  void _showAdminLoginDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin Login'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter Admin ID (OWNER123)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                LoginAsOwner(controller.text.trim()),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
