import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'name': name,
      'role': 'user',
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Method ambil data user //
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    return doc.data();
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    return doc.data()?['role'];
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};

    if (name != null && name.trim().isNotEmpty) {
      data['name'] = name.trim();
    }

    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }

    if (data.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(data);
    }
  }

  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }
}
