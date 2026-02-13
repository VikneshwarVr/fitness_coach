import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AuthRepository() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Session? get currentSession => _supabase.auth.currentSession;
  String get displayName => currentUser?.userMetadata?['username'] ?? 'User';
  String get bio => currentUser?.userMetadata?['bio'] ?? '';
  String get sex => currentUser?.userMetadata?['sex'] ?? 'Not specified';
  String get birthday => currentUser?.userMetadata?['birthday'] ?? '';
  String? get profileImageUrl => currentUser?.userMetadata?['avatar_url'];

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? sex,
    String? birthday,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> metadata = Map.from(currentUser?.userMetadata ?? {});
      if (username != null) metadata['username'] = username;
      if (bio != null) metadata['bio'] = bio;
      if (sex != null) metadata['sex'] = sex;
      if (birthday != null) metadata['birthday'] = birthday;
      if (avatarUrl != null) metadata['avatar_url'] = avatarUrl;

      await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );

      // 2. Update public.profiles table for database storage
      await _supabase.from('profiles').upsert({
        'id': currentUser?.id,
        'username': username ?? metadata['username'],
        'full_name': username ?? metadata['username'], // Using username as full_name for now
        'avatar_url': avatarUrl ?? metadata['avatar_url'],
        'bio': bio ?? metadata['bio'],
        'sex': sex ?? metadata['sex'],
        'birthday': birthday ?? metadata['birthday'],
        'updated_at': DateTime.now().toIso8601String(),
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch from DB to ensure sync (optional but good for consistency)
  Future<void> fetchProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return;

      final data = await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
      if (data != null) {
        // We could update local state here if needed, 
        // but auth.updateUser already triggered metadata refresh.
        // This confirms it's in the DB.
      }
    } catch (e) {
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.fitness://login-callback/',
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<String?> uploadAvatar(String filePath) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '${currentUser!.id}/$fileName';

      await _supabase.storage.from('avatars').upload(path, file);

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
