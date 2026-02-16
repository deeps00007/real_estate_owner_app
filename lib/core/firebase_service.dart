import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/property.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Property>> getPropertiesStream(String? ownerId) {
    final query = ownerId != null
        ? _firestore
              .collection('properties')
              .where('ownerId', isEqualTo: ownerId)
        : _firestore.collection('properties');
    return query
        .orderBy('price')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            // Fallback for legacy data with missing/empty id
            if (data['id'] == null || data['id'] == '') {
              data['id'] = doc.id;
            }
            return Property.fromJson(data);
          }).toList(),
        );
  }

  Future<void> addProperty(Property property) async {
    await _firestore.collection('properties').add(property.toJson());
  }

  Future<void> updateProperty(Property property) async {
    final query = await _firestore
        .collection('properties')
        .where('id', isEqualTo: property.id)
        .get();
    for (var doc in query.docs) {
      await doc.reference.update(property.toJson());
    }
  }

  Future<void> deleteProperty(String id) async {
    final query = await _firestore
        .collection('properties')
        .where('id', isEqualTo: id)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> saveUserToken(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'email': _auth.currentUser?.email, // Optional: useful for debugging
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['role'] as String?;
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return null;
  }

  Future<void> upgradeUserToOwner(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'role': 'owner',
    }, SetOptions(merge: true));
  }

  Future<void> toggleSavedProperty(
    String uid,
    String propertyId,
    bool isSaved,
  ) async {
    final docRef = _firestore.collection('users').doc(uid);
    if (isSaved) {
      await docRef.update({
        'savedPropertyIds': FieldValue.arrayUnion([propertyId]),
      });
    } else {
      await docRef.update({
        'savedPropertyIds': FieldValue.arrayRemove([propertyId]),
      });
    }
  }

  Future<void> addToRecentlyViewed(String uid, String propertyId) async {
    final docRef = _firestore.collection('users').doc(uid);
    // Use a transaction or specific logic if we want to limit array size,
    // but for simplicity, allow arrayUnion. Ideally, we should pull, filter, limit, and push back.
    // For MVP: Just add it.
    await docRef.set({
      'recentPropertyIds': FieldValue.arrayUnion([propertyId]),
    }, SetOptions(merge: true));
  }

  Future<Map<String, List<String>>> getUserActivity(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final saved = List<String>.from(data['savedPropertyIds'] ?? []);
        final recent = List<String>.from(data['recentPropertyIds'] ?? []);
        return {'saved': saved, 'recent': recent};
      }
    } catch (e) {
      print('Error fetching user activity: $e');
    }
    return {'saved': [], 'recent': []};
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final query = await _firestore.collection('users').get();
      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'fcmToken': data['fcmToken'],
          'email': data['email'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;
}
