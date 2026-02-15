import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final List<String> _searchKeywords = [
    'House',
    'Apartment',
    'Villa',
    'Plot',
    'Condo',
  ];

  final TextEditingController _controller = TextEditingController();

  int _currentIndex = 0;
  Timer? _timer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        _stopTimer();
        setState(() => _isTyping = true);
      } else {
        setState(() => _isTyping = false);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isTyping) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _searchKeywords.length;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          const Icon(Icons.search, color: Colors.grey),

          /// Animated Hint
          if (!_isTyping)
            Positioned(
              left: 36,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.6),
                    end: const Offset(0, 0),
                  ).animate(animation);

                  return ClipRect(
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: Text(
                  'Search for ${_searchKeywords[_currentIndex]}...',
                  key: ValueKey(_searchKeywords[_currentIndex]),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

          /// Actual TextField
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 36),
              isDense: true,
            ),
            style: const TextStyle(color: Colors.black),
            cursorColor: Color(0xFF0F2C59),
          ),
        ],
      ),
    );
  }
}
