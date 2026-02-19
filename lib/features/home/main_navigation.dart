import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../chat/chat_list_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../map/bloc/property_bloc.dart';
import '../map/bloc/property_event.dart';
import 'home_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../promotion/floating_promotion_video.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Fetch user location when app starts (and user is logged in)
    context.read<PropertyBloc>().add(FetchUserLocation());

    _screens = [
      HomeScreen(onProfileTap: () => _onItemTapped(4)),
      const MapScreen(),
      const Center(child: Text('Wishlist - Coming Soon')),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  DateTime? _lastPopTime;

  Future<void> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPopTime == null ||
        now.difference(_lastPopTime!) > const Duration(seconds: 2)) {
      _lastPopTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: _screens),
            const FloatingPromotionVideo(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0F2C59), // Navy Blue
            unselectedItemColor: Colors.grey[400],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: 'Maps',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Message',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
