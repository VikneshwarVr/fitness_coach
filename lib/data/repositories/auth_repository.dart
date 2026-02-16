import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/cache_service.dart';

class AuthRepository extends ChangeNotifier {
  final SupabaseClient _supabase;
  Map<String, dynamic>? _cachedProfile;

  AuthRepository([SupabaseClient? client]) : _supabase = client ?? Supabase.instance.client {
    // Load profile from cache initially
    _cachedProfile = CacheService.getCachedProfile();
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _cachedProfile = null;
        CacheService.clearAll();
      } else if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.userUpdated) {
        _syncProfile();
      }
      notifyListeners();
    });
  }

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Session? get currentSession => _supabase.auth.currentSession;
  
  String get displayName => _cachedProfile?['username'] ?? currentUser?.userMetadata?['username'] ?? 'User';
  String get bio => _cachedProfile?['bio'] ?? currentUser?.userMetadata?['bio'] ?? '';
  String get sex => _cachedProfile?['sex'] ?? currentUser?.userMetadata?['sex'] ?? 'Not specified';
  String get birthday => _cachedProfile?['birthday'] ?? currentUser?.userMetadata?['birthday'] ?? '';
  String? get profileImageUrl => _cachedProfile?['avatar_url'] ?? currentUser?.userMetadata?['avatar_url'];

  void _syncProfile() {
    if (currentUser != null) {
      final Map<String, dynamic> metadata = Map.from(currentUser?.userMetadata ?? {});
      _cachedProfile = metadata;
      CacheService.cacheProfile(metadata);
    }
  }

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

      // Update Local Cache
      _cachedProfile = metadata;
      await CacheService.cacheProfile(metadata);

      // 2. Update public.profiles table for database storage
      await _supabase.from('profiles').upsert({
        'id': currentUser?.id,
        'username': username ?? metadata['username'],
        'full_name': username ?? metadata['username'],
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

  Future<void> fetchProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return;

      final data = await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
      if (data != null) {
        _cachedProfile = Map<String, dynamic>.from(data);
        await CacheService.cacheProfile(_cachedProfile!);
        notifyListeners();
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
      await fetchProfile(); // Ensure profile is cached after sign in
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
      await CacheService.clearAll();
    } catch (e) {
      rethrow;
    }
  }
}
