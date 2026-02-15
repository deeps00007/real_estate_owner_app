import 'dart:async';
import 'package:flutter/material.dart';

class RotatingSearchBar extends StatefulWidget {
  const RotatingSearchBar({super.key});

  @override
  State<RotatingSearchBar> createState() => _RotatingSearchBarState();
}

class _RotatingSearchBarState extends State<RotatingSearchBar> {
  final List<String> _keywords = [
    "Apartment",
    "Villa",
    "Office",
    "Flats",
  ];

  final TextEditingController _controller = TextEditingController();
  final PageController _pageController = PageController();

  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_controller.text.isEmpty) {
        _currentIndex = (_currentIndex + 1) % _keywords.length;

        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 12),

          /// TEXT AREA
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                /// 🔥 ROTATING HINT TEXT
                IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _controller.text.isEmpty ? 1 : 0,
                    child: SizedBox(
                      height: 22,
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: _keywords.length,
                        itemBuilder: (context, index) {
                          return Text(
                            'Search "${_keywords[index]}"',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                /// 🔥 ACTUAL TEXT FIELD
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  cursorColor: Colors.white,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withOpacity(0.4),
          ),

          const SizedBox(width: 8),

          const Icon(Icons.mic, color: Colors.grey, size: 22),
        ],
      ),
    );
  }
}
