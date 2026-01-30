// lib\services\firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic CRUD operations for any collection

  // Create document
  Future<void> createDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw 'Failed to create document in $collection';
    }
  }

  // Get single document
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw 'Failed to fetch document from $collection';
    }
  }

  // Update document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw 'Failed to update document in $collection';
    }
  }

  // Delete document
  Future<void> deleteDocument(
    String collection,
    String docId,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw 'Failed to delete document from $collection';
    }
  }

  // Get collection with query
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      throw 'Failed to fetch collection $collection';
    }
  }

  // Stream single document
  Stream<Map<String, dynamic>?> streamDocument(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId).snapshots().map(
          (doc) => doc.exists ? doc.data() : null,
        );
  }

  // Stream collection
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);
    
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList(),
        );
  }

  // Batch operations
  Future<void> batchWrite(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final batch = _firestore.batch();

      for (var operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String;
        final data = operation['data'] as Map<String, dynamic>?;

        final docRef = _firestore.collection(collection).doc(docId);

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to execute batch operation';
    }
  }
}