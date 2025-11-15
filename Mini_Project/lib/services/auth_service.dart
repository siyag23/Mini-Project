import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ Define master admin emails
const List<String> masterAdminEmails = [
  'studentadmin@example.com', // replace with actual student admin email
  'vpg@gmail.com',            // professor admin
];

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ Save or update user info in Firestore
  Future<void> _saveUserInfo(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    // Check if user is a master admin
    final isAdmin = masterAdminEmails.contains(user.email);

    if (!snapshot.exists) {
      // First time: create user document with all required fields
      await userDoc.set({
        'email': user.email,
        'name': user.displayName ?? '',
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': isAdmin ? 'admin' : 'user', // assign role based on email
        'premium': false,                    // default premium
      });
    } else {
      // Existing user: update updatedAt and keep role/premium intact
      await userDoc.set({
        'updatedAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName ?? '',
        'name': user.displayName ?? '',
        'role': snapshot.data()?['role'] ?? (isAdmin ? 'admin' : 'user'),
        'premium': snapshot.data()?['premium'] ?? false,
      }, SetOptions(merge: true));
    }
  }

  // ✅ Sign up with Email and Password
  Future<User?> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update displayName in Auth profile
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        await _saveUserInfo(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Signup Error: ${e.message}");
      rethrow;
    }
  }

  // ✅ Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _saveUserInfo(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.message}");
      rethrow;
    }
  }

  // ✅ Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserInfo(userCredential.user!);
      }

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // ✅ Sign Out (both Google and Email)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ✅ Get current user
  User? get currentUser => _auth.currentUser;
}
