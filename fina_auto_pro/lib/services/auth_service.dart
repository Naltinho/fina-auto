import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fina_auto_core/fina_auto_core.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get firebaseUser => _auth.currentUser;
  bool get isLoggedIn => firebaseUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserProfile?> getCurrentProfile() async {
    final uid = firebaseUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection(FinaCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> registerProfissional({
    required String email,
    required String password,
    required String nome,
    required ProfissionalSubtipo subtipo,
    String? telefone,
    double? latitude,
    double? longitude,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final profile = UserProfile(
      id: uid,
      email: email,
      nome: nome,
      tipo: UserType.profissional,
      profissionalSubtipo: subtipo,
      telefone: telefone,
    );
    await _firestore
        .collection(FinaCollections.users)
        .doc(uid)
        .set(profile.toFirestore());

    final profissionalData = {
      'userId': uid,
      'nome': nome,
      'email': email,
      'subtipo': subtipo.value,
      'ativo': true,
      if (telefone != null) 'telefone': telefone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'criadoEm': FieldValue.serverTimestamp(),
    };
    if (subtipo == ProfissionalSubtipo.oficina) {
      await _firestore
          .collection(FinaCollections.oficinas)
          .doc(uid)
          .set(profissionalData);
    } else {
      await _firestore
          .collection(FinaCollections.mecanicos)
          .doc(uid)
          .set(profissionalData);
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
