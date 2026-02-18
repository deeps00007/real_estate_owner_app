import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_model.dart';
import '../../core/notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or Create a chat between two users for a specific property
  Future<String> getOrCreateChat(
    String currentUserId,
    String otherUserId,
    String propertyId,
  ) async {
    // Check if chat already exists
    final QuerySnapshot result = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    // Filter locally because Firestore can only handle one array-contains query
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants']);
      final pId = data['propertyId'];

      if (participants.contains(otherUserId) && pId == propertyId) {
        return doc.id;
      }
    }

    // Create new chat if not found
    final docRef = await _firestore.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'propertyId': propertyId,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String receiverId,
    required String senderName,
  }) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add(
      {
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 0, // Sent
      },
    );

    // Update last message and increment unread count
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.$receiverId': FieldValue.increment(1),
    });

    // Send Silent Data Message for Delivery Receipt
    // The recipient app will wake up and call markMessageAsDelivered
    await NotificationService().sendNotification(
      receiverId: receiverId,
      title: 'New Message from $senderName',
      body: text,
      data: {
        'type': 'new_message',
        'chatId': chatId,
        // We might need messageId to mark specific message as delivered.
        // However, standard sendMessage doesn't return the ID easily unless we refactor.
        // For now, we can just wake up the chat.
      },
    );
  }

  // Mark specific message as Delivered (1)
  Future<void> markMessageAsDelivered(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'status': 1}); // Delivered
  }

  // Mark chat as Read (2)
  Future<void> markChatAsRead(String chatId, String currentUserId) async {
    // 1. Reset unread count for current user
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$currentUserId': 0,
    });

    // 2. Mark UNREAD messages as READ (status = 2)
    // Filter: senderId != currentUserId && status < 2
    final unreadMessagesQuery = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('status', isLessThan: 2)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    if (unreadMessagesQuery.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in unreadMessagesQuery.docs) {
        batch.update(doc.reference, {'status': 2}); // Read
      }
      await batch.commit();
    }
  }

  // Stream messages for a chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList();
        });
  }

  // Stream user's chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
        });
  }
}
