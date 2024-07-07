import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> deleteFlightLog(String documentId) async {
    try {
      await _db.collection('flightLogs').doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
