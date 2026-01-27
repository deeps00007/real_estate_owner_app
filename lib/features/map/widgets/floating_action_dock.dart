import 'package:flutter/material.dart';

class FloatingActionDock extends StatelessWidget {
  final VoidCallback onExpand;
  final VoidCallback onNavigate;
  final VoidCallback onRefresh;
  final VoidCallback onFilter;
  final VoidCallback onMore; // Added
  final bool isNearbyActive;

  const FloatingActionDock({
    super.key,
    required this.onExpand,
    required this.onNavigate,
    required this.onRefresh,
    required this.onFilter,
    required this.onMore, // Added
    this.isNearbyActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(Icons.fullscreen, onExpand, color: Colors.pinkAccent),
          const SizedBox(width: 24),
          _buildIcon(Icons.navigation, onNavigate, color: Colors.pinkAccent),
          const SizedBox(width: 24),
          _buildIcon(Icons.refresh, onRefresh, color: Colors.pinkAccent),
          const SizedBox(width: 24),
          _buildIcon(
            Icons.radar,
            onFilter,
            color: isNearbyActive ? const Color(0xFFFF80AB) : Colors.grey,
          ), // or filter icon
          const SizedBox(width: 24),
          _buildIcon(Icons.more_horiz, onMore, color: Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color ?? const Color(0xFFFF80AB), size: 24),
    );
  }
}
