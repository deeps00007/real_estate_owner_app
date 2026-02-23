import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_bloc.dart';
import '../../models/chat_model.dart';
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
      leading: SizedBox(
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
