import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_search_modal.dart'; // 👈 import the separate file

class RotatingSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const RotatingSearchBar({super.key, this.onChanged, this.onSubmitted});

  @override
  State<RotatingSearchBar> createState() => _RotatingSearchBarState();
}

class _RotatingSearchBarState extends State<RotatingSearchBar>
    with SingleTickerProviderStateMixin {
  final List<String> _keywords = ["Apartment", "Villa", "Office", "Flats"];
  late final List<String> _loopList;

  final TextEditingController _controller = TextEditingController();
  late final PageController _pageController;
  late stt.SpeechToText _speech;

  bool _isListening = false;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _loopList = [..._keywords, ..._keywords];
    _pageController = PageController(initialPage: 0);
    _speech = stt.SpeechToText();

    // Trigger rebuild when typing to hide shifting background text
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_controller.text.isEmpty && !_isListening) {
        _currentIndex++;

        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        if (_currentIndex == _keywords.length) {
          Future.delayed(const Duration(milliseconds: 600), () {
            _currentIndex = 0;
            _pageController.jumpToPage(0);
          });
        }
      }
    });
  }

  Future<void> _listen() async {
    bool available = await _speech.initialize();
    if (!available) return;

    if (!_isListening) {
      setState(() => _isListening = true);

      _showVoiceBottomSheet();

      _speech.listen(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
          widget.onChanged?.call(result.recognizedWords); // Trigger callback

          if (result.finalResult) {
            _stopListening();
          }
        },
      );
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    Navigator.of(context).pop();
  }

  void _showVoiceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Listening...",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 30),

              /// 👇 Wave imported from separate file
              const VoiceWave(),

              const SizedBox(height: 30),
              Text(
                _controller.text.isEmpty ? "Start speaking" : _controller.text,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _stopListening,
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _pageController.dispose();
    _speech.stop();
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
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
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

          GestureDetector(
            onTap: _listen,
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.green : Colors.grey,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
