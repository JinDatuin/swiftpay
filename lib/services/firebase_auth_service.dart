import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // Sign In with Email and Password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }

  // Register with Email and Password
  Future<User?> register(String email, String password, String fullName, String phoneNumber) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );
        await _firestore.saveUser(newUser);
      }
      return result.user;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
