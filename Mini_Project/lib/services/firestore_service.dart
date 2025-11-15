import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveResult(String subject, int score) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = _db.collection("users").doc(user.uid);

    await userDoc.set({
      "email": user.email,
    }, SetOptions(merge: true));

    await userDoc.collection("results").add({
      "subject": subject,
      "score": score,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
}
