import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// Provider gérant l'authentification et la session utilisateur
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<void> init() async {
    try {
      _currentUser = await StorageService.instance.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider init error: $e');
    }
  }


  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();
      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
        orElse: () => throw Exception('Credentials not found'),
      );

      _currentUser = user;
      await StorageService.instance.saveCurrentUser(user);
      return true;
    } catch (_) {
      _error = 'Email ou mot de passe incorrect';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();


      final exists = users.any(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
      if (exists) {
        _error = 'Cet email est déjà utilisé';
        return false;
      }


      final newUser = User(
        id: const Uuid().v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        createdAt: DateTime.now(),
      );

      await StorageService.instance.saveUser(newUser);
      _currentUser = newUser;
      await StorageService.instance.saveCurrentUser(newUser);
      return true;
    } catch (e) {
      _error = 'Une erreur est survenue. Réessayez.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await StorageService.instance.clearCurrentUser();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
      );
      await StorageService.instance.saveUser(updated);
      await StorageService.instance.saveCurrentUser(updated);
      _currentUser = updated;
    } catch (e) {
      _error = 'Impossible de mettre à jour le profil';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
}
