import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import 'chat_service.dart';
import '../../core/notification_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserName;
  final String otherUserId;
  final String currentUserName;
  final String? otherUserProfileImage;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserName,
    required this.otherUserId,
    required this.currentUserName,
    this.otherUserProfileImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set current chat ID to suppress notifications
    NotificationService.currentChatId = widget.chatId;

    // Mark chat as read when opening
    _chatService.markChatAsRead(widget.chatId, widget.currentUserId);
  }

  @override
  void dispose() {
    // Clear current chat ID
    NotificationService.currentChatId = null;
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _chatService.sendMessage(
      chatId: widget.chatId,
      text: _messageController.text.trim(),
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      senderName: widget.currentUserName,
    );

    _messageController.clear();
    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        leadingWidth: 70,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[100], height: 1.0),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back_ios_new, size: 20),
              const SizedBox(width: 4),
              Hero(
                tag: 'profile_${widget.otherUserId}',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: widget.otherUserProfileImage != null
                      ? NetworkImage(widget.otherUserProfileImage!)
                      : null,
                  child: widget.otherUserProfileImage == null
                      ? Icon(Icons.person, color: Colors.grey[400], size: 20)
                      : null,
                ),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId),
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
                          Icons.mark_chat_unread_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;

                // Check for unread messages from the other user and mark them as read
                final unreadMessages = messages.where(
                  (msg) =>
                      msg.senderId != widget.currentUserId && msg.status != 2,
                );

                if (unreadMessages.isNotEmpty) {
                  Future.microtask(() {
                    _chatService.markChatAsRead(
                      widget.chatId,
                      widget.currentUserId,
                    );
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    final showDate =
                        index == messages.length - 1 ||
                        messages[index + 1].timestamp.day !=
                            message.timestamp.day;

                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDate(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.70,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            decoration: BoxDecoration(
                              gradient: isMe
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF0F2C59),
                                        Color(0xFF1B4F93),
                                      ], // Deep Blue Gradient
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isMe ? null : const Color(0xFFF2F4F8),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isMe
                                    ? const Radius.circular(20)
                                    : const Radius.circular(4),
                                bottomRight: isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(20),
                              ),
                              boxShadow: isMe
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0F2C59,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: isMe
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey[500],
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons
                                            .done_all, // Restored "Double Ticks"
                                        size: 16,
                                        color: message.status == 2
                                            ? Colors
                                                  .lightBlueAccent // Blue for Read
                                            : Colors.white.withOpacity(
                                                0.5,
                                              ), // Grey-ish for others
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type something...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2C59), Color(0xFF1B4F93)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F2C59).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
