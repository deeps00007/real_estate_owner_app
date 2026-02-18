import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String propertyId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts; // Added: UserId -> Count

  Chat({
    required this.id,
    required this.participants,
    required this.propertyId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCounts = const {},
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      propertyId: data['propertyId'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'propertyId': propertyId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCounts': unreadCounts,
    };
  }
}

class Message {
  final String id; // Added ID for easier tracking
  final String senderId;
  final String text;
  final DateTime timestamp;
  final int status; // 0: Sent, 1: Delivered, 2: Read

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = 0,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status:
          data['status'] ??
          (data['isRead'] == true ? 2 : 0), // Migration compatibility
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }
}
