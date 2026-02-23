import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_bloc.dart';
import '../../models/chat_model.dart';
import '../../models/property.dart';
import '../property_details/property_detail_screen.dart';
import 'chat_service.dart';
import 'chat_screen.dart';
import '../../core/firebase_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  Stream<List<Chat>>? _chatsStream;
  String? _currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthBloc>().state.user;
    if (user != null && _currentUserId != user.uid) {
      _currentUserId = user.uid;
      _chatsStream = _chatService.getUserChats(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;

          if (user == null) {
            return const Center(child: Text('Please login to view messages'));
          }

          if (_chatsStream == null) {
            return const Center(child: Text('Loading...'));
          }

          return StreamBuilder<List<Chat>>(
            stream: _chatsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              final chats = snapshot.data!;

              return ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 82),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatTile(
                    chat: chat,
                    currentUserId: user.uid,
                    currentUserName: user.displayName ?? 'User',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  final Chat chat;
  final String currentUserId;
  final String currentUserName;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _otherUserData;
  Map<String, dynamic>? _propertyData;

  @override
  bool get wantKeepAlive => true; // Prevent re-fetching when scrolling/returning

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final otherUserId = widget.chat.participants.firstWhere(
      (id) => id != widget.currentUserId,
      orElse: () => '',
    );

    Future<Map<String, dynamic>?> userFuture = Future.value(null);
    if (otherUserId.isNotEmpty) {
      userFuture = FirebaseService().getUserDetails(otherUserId);
    }

    Future<Map<String, dynamic>?> propertyFuture = Future.value(null);
    if (widget.chat.propertyId.isNotEmpty) {
      propertyFuture = FirebaseService().getPropertyDetails(
        widget.chat.propertyId,
      );
    }

    final results = await Future.wait([userFuture, propertyFuture]);

    if (mounted) {
      setState(() {
        _otherUserData = results[0];
        _propertyData = results[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final otherUserId = widget.chat.participants.firstWhere(
      (id) => id != widget.currentUserId,
      orElse: () => 'Unknown',
    );

    final otherUserName = _otherUserData?['displayName'] ?? 'User';
    final otherUserImage = _otherUserData?['photoURL'];

    void showAvatarDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      // Main User Avatar
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2C59).withOpacity(0.05),
                          image: otherUserImage != null
                              ? DecorationImage(
                                  image: NetworkImage(otherUserImage),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: otherUserImage == null
                            ? const Icon(
                                Icons.person,
                                size: 100,
                                color: Color(0xFF0F2C59),
                              )
                            : null,
                      ),
                      // Semi-transparent Title Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            otherUserName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Property Image Badge
                      if (_propertyData != null &&
                          _propertyData!['imageUrl'] != null)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(_propertyData!['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chat,
                            color: Color(0xFF0F2C59),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: widget.chat.id,
                                  currentUserId: widget.currentUserId,
                                  otherUserName: otherUserName,
                                  otherUserId: otherUserId,
                                  currentUserName: widget.currentUserName,
                                  otherUserProfileImage: otherUserImage,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF0F2C59),
                          ),
                          onPressed: () {
                            if (_propertyData == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Property details not available',
                                  ),
                                ),
                              );
                              return;
                            }
                            // Close dialog first
                            Navigator.pop(context);
                            // Parse data and navigate
                            try {
                              final property = Property.fromJson(
                                _propertyData!,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailScreen(property: property),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error loading property: $e'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: widget.chat.id,
              currentUserId: widget.currentUserId,
              otherUserName: otherUserName,
              otherUserId: otherUserId,
              currentUserName: widget.currentUserName,
              otherUserProfileImage: otherUserImage,
            ),
          ),
        );
      },
      leading: GestureDetector(
        onTap: showAvatarDialog,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF0F2C59),
                backgroundImage: otherUserImage != null
                    ? NetworkImage(otherUserImage)
                    : null,
                child: otherUserImage == null
                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                    : null,
              ),
              if (_propertyData != null && _propertyData!['imageUrl'] != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2), // White border
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(_propertyData!['imageUrl']),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              widget.chat.lastMessage.isNotEmpty
                  ? widget.chat.lastMessage
                  : 'Started a conversation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeago.format(widget.chat.lastMessageTime),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (widget.chat.unreadCounts[widget.currentUserId] != null &&
              widget.chat.unreadCounts[widget.currentUserId]! > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.chat.unreadCounts[widget.currentUserId].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
