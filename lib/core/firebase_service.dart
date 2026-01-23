import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/property.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Property>> getPropertiesStream(String? ownerId) {
    final query = ownerId != null
        ? _firestore.collection('properties').where('ownerId', isEqualTo: ownerId)
        : _firestore.collection('properties');
    return query.orderBy('price').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Property.fromJson(doc.data())).toList());
  }

  Future<void> addProperty(Property property) async {
    await _firestore.collection('properties').add(property.toJson());
  }

  String? get currentUserId => _auth.currentUser?.uid;
}
