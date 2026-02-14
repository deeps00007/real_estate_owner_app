import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_model.dart';

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
  Future<void> sendMessage(String chatId, String text, String senderId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': senderId,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

    // Update last message in chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
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
