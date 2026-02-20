import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FloatingPromotionVideo extends StatefulWidget {
  const FloatingPromotionVideo({super.key});

  // Static flag to track if video has been closed in this app session
  static bool isClosedForSession = false;

  @override
  State<FloatingPromotionVideo> createState() => _FloatingPromotionVideoState();
}

class _FloatingPromotionVideoState extends State<FloatingPromotionVideo> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isMuted = false;
  bool _isExpanded = false;

  final double _frameWidth = 120.0;
  final double _frameHeight = 200.0;
  final double _expandedWidth = 210.0;
  final double _expandedHeight = 350.0;
  String? _instagramToken;

  // For Draggability
  double? _left;
  double? _bottom;

  @override
  void initState() {
    super.initState();
    if (!FloatingPromotionVideo.isClosedForSession) {
      _fetchInstagramToken();
    }
  }

  Future<void> _fetchInstagramToken() async {
    try {
      final response = await http.get(Uri.parse(''));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          _instagramToken = data['data'][0]['api_key'];
          _fetchInstagramVideoUrl();
        } else {
          // If API returns invalid data, use fallback video
          _initializeVideoPlayer(
            'https://ik.imagekit.io/projectss/Follow%20for%20more_.mp4',
          );
        }
      } else {
        // If API fails, use fallback video
        _initializeVideoPlayer(
          'https://ik.imagekit.io/projectss/Follow%20for%20more_.mp4',
        );
      }
    } catch (e) {
      // If API fails, use fallback video
      _initializeVideoPlayer(
        'https://ik.imagekit.io/projectss/Follow%20for%20more_.mp4',
      );
    }
  }

  Future<void> _fetchInstagramVideoUrl() async {
    if (_instagramToken == null || _instagramToken!.isEmpty) {
      _initializeVideoPlayer(
        'https://ik.imagekit.io/projectss/Follow%20for%20more_.mp4',
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://graph.instagram.com/me/media?fields=media_url,media_type&access_token=$_instagramToken&limit=1',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final media = data['data'][0];
          if (media['media_type'] == 'VIDEO') {
            _initializeVideoPlayer(media['media_url']);
            return;
          }
        }
      }
      _initializeVideoPlayer(
        'https://ik.imagekit.io/projectss/Follow%20for%20more_.mp4',
      );
    } catch (e) {
      _initializeVideoPlayer(
        'https://ik.imagekit.io/projectss/Follow%20for%20more_.mp4',
      );
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: true,
            looping: true,
            showControls: false,
            aspectRatio: _frameWidth / _frameHeight,
          );
        });
      });
  }

  @override
  void dispose() {
    if (!FloatingPromotionVideo.isClosedForSession) {
      _videoController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  bool _defaultMuteApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultMuteApplied) {
      _defaultMuteApplied = true;
      _applyDefaultMute();
    }
  }

  Future<void> _applyDefaultMute() async {
    // set the flag so UI shows muted icon by default
    _isMuted = true;

    // Initialize position to bottom-left if not set
    if (_left == null && _bottom == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _left = 16.0;
          _bottom = 16.0;
        });
      });
    }

    // wait until the controller is created and initialized, then apply volume
    while (mounted) {
      if (_chewieController != null && _videoController.value.isInitialized) {
        await _videoController.setVolume(0.0);
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;

      // Recalculate dimensions for boundary check
      final double nextWidth = _isExpanded ? _expandedWidth : _frameWidth;
      final double nextHeight = _isExpanded ? _expandedHeight : _frameHeight;

      if (_left != null && _bottom != null) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Adjust _left if expanded width goes off-screen
        if (_left! + nextWidth > screenWidth - 16) {
          _left = screenWidth - nextWidth - 16;
        }
        if (_left! < 16) _left = 16;

        // Adjust _bottom if expanded height goes off-screen
        if (_bottom! + nextHeight > screenHeight - 16) {
          _bottom = screenHeight - nextHeight - 16;
        }
        if (_bottom! < 16) _bottom = 16;
      }
    });
  }

  void _closeVideo() {
    _videoController.pause();
    _chewieController?.dispose();
    _videoController.dispose();
    setState(() {
      FloatingPromotionVideo.isClosedForSession = true; // Set flag for session
    });
  }

  @override
  Widget build(BuildContext context) {
    if (FloatingPromotionVideo.isClosedForSession ||
        _chewieController == null ||
        !_videoController.value.isInitialized ||
        _left == null ||
        _bottom == null) {
      return const SizedBox.shrink(); // Hide if closed for session or pos not set
    }

    final double currentWidth = _isExpanded ? _expandedWidth : _frameWidth;
    final double currentHeight = _isExpanded ? _expandedHeight : _frameHeight;

    return Positioned(
      left: _left,
      bottom: _bottom,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _left = (_left ?? 0) + details.delta.dx;
            // bottom increases as we move UP (negative dy)
            _bottom = (_bottom ?? 0) - details.delta.dy;

            // Boundary checks
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            if (_left! < 16) _left = 16;
            if (_bottom! < 16) _bottom = 16;

            if (_left! + currentWidth > screenWidth - 16) {
              _left = screenWidth - currentWidth - 16;
            }
            if (_bottom! + currentHeight > screenHeight - 16) {
              _bottom = screenHeight - currentHeight - 16;
            }
          });
        },
        onPanEnd: (_) {
          final screenWidth = MediaQuery.of(context).size.width;
          final double currentWidth = _isExpanded
              ? _expandedWidth
              : _frameWidth;

          setState(() {
            // Magnetic Snapping: snap to nearest side
            if ((_left ?? 0) + (currentWidth / 2) < screenWidth / 2) {
              _left = 16.0; // Snap to Left
            } else {
              _left = screenWidth - currentWidth - 16.0; // Snap to Right
            }
          });
        },
        onTap: _toggleExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isExpanded ? _expandedWidth : _frameWidth,
          height: _isExpanded ? _expandedHeight : _frameHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Chewie(controller: _chewieController!),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _toggleMute,
                  padding: EdgeInsets.zero,
                  tooltip: _isMuted ? 'Unmute' : 'Mute',
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: _closeVideo, // Now closes permanently for session
                  padding: EdgeInsets.zero,
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
