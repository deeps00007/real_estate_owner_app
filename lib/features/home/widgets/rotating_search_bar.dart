import 'dart:async';
import 'package:flutter/material.dart';

class RotatingSearchBar extends StatefulWidget {
  const RotatingSearchBar({super.key});

  @override
  State<RotatingSearchBar> createState() => _RotatingSearchBarState();
}

class _RotatingSearchBarState extends State<RotatingSearchBar> {
  final List<String> _keywords = ["Apartment", "Villa", "Office", "Flats"];

  late final List<String> _loopList;

  final TextEditingController _controller = TextEditingController();
  late final PageController _pageController;

  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    /// Duplicate list for smooth looping
    _loopList = [..._keywords, ..._keywords];

    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_controller.text.isEmpty) {
        _currentIndex++;

        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        /// 🔥 When reaching duplicate end, reset silently
        if (_currentIndex == _keywords.length) {
          Future.delayed(const Duration(milliseconds: 600), () {
            _currentIndex = 0;
            _pageController.jumpToPage(0);
          });
        }
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

          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _controller.text.isEmpty ? 1 : 0,
                    child: Row(
                      children: [
                        const Text(
                          'Search ',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(
                          height: 52,
                          width: 140,
                          child: PageView.builder(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: _loopList.length,
                            itemBuilder: (context, index) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '"${_loopList[index]}"',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                TextField(
                  controller: _controller,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          Container(height: 24, width: 1, color: Colors.grey),
          const SizedBox(width: 8),
          const Icon(Icons.mic, color: Colors.grey, size: 22),
        ],
      ),
    );
  }
}
