import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/user_secure_storage.dart';

class AuthProviders with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool rememberMe = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isLoading => _isLoading;

  String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> toggleRememberMe(bool value) async {
    rememberMe = value;
    notifyListeners();
  }

  Future<void> addUserProduct(String userId, Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('users').doc(userId).collection('products').add(productData);
      debugPrint("Product added successfully for user $userId.");
    } catch (e) {
      debugPrint("Error adding product for user $userId: $e");
    }
  }

  Future<String?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _setLoading(false);

      if (rememberMe) {
        await UserSecureStorage.write('email', value: email);
        await UserSecureStorage.write('password', value: password);
        await UserSecureStorage.write('uid', value: userCredential.user!.uid);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that email.';
      }
      return e.message;
    }
  }

  Future<String?> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);

      if (rememberMe) {
        await UserSecureStorage.write('email', value: email);
        await UserSecureStorage.write('password', value: password);
        await UserSecureStorage.write('uid', value: userCredential.user!.uid);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    }
  }

  Future<void> loadRememberedCredentials(TextEditingController emailController,
      TextEditingController passwordController) async {
    final email = await UserSecureStorage.read('email');
    final password = await UserSecureStorage.read('password');
    if (email != null && password != null) {
      emailController.text = email;
      passwordController.text = password;
      rememberMe = true;
      notifyListeners();
    }
  }

  Future<String?> signOut() async {
    _setLoading(true);
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _auth.signOut();
        debugPrint('User signed out.');
        await UserSecureStorage.delete('uid');
        final uid = await UserSecureStorage.read('uid');
        debugPrint('Deleted uid: $uid');
        await user.delete();

        _setLoading(false);
        return null;
      } else {
        _setLoading(false);
        return 'No user is currently signed in.';
      }
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'requires-recent-login') {
        return 'Please re-authenticate and try again.';
      }
      return e.message;
    } catch (e) {
      _setLoading(false);
      return 'An error occurred. Please try again.';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
