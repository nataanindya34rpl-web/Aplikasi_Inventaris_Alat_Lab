
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  Future<UserCredential> register({
    required String name,
    required String kelas,
    required String email,
    required String password,
    String foto = '',
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final newUser = credential.user;

    if (newUser == null) {
      throw Exception('Gagal membuat akun.');
    }

    final user = UserModel(
      userId: newUser.uid,
      name: name.trim(),
      email: email.trim(),
      kelas: kelas.trim(),
      foto: foto.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _db
          .collection('users')
          .doc(newUser.uid)
          .set(user.toMap());

      return credential;
    } catch (e) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return UserModel.fromMap(snapshot.data()!);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return UserModel.fromMap(snapshot.data()!);
    });
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String kelas,
    required String foto,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name.trim(),
      'kelas': kelas.trim(),
      'foto': foto.trim(),
    }, SetOptions(merge: true));
  }
}
