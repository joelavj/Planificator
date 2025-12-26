import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class AuthRepository extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final logger = Logger();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Connexion utilisateur
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          userId, email, nom, prenom, password, isAdmin, createdAt
        FROM User
        WHERE email = ?
      ''';

      final row = await _db.queryOne(sql, [email]);

      if (row == null) {
        _errorMessage = 'Email ou mot de passe incorrect';
        logger.w('Tentative de connexion avec un email inexistant: $email');
        return false;
      }

      // Vérifier le mot de passe (comparaison simple)
      // En production, utiliser bcrypt ou un autre algorithme sécurisé
      if (row['password'] != password) {
        _errorMessage = 'Email ou mot de passe incorrect';
        logger.w('Tentative de connexion échouée pour: $email');
        return false;
      }

      _currentUser = User.fromMap(row);
      _isAuthenticated = true;

      logger.i('Utilisateur ${_currentUser!.email} connecté');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la connexion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription utilisateur
  Future<bool> register(
    String email,
    String nom,
    String prenom,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Vérifier si l'email existe déjà
      const checkSql = 'SELECT userId FROM User WHERE email = ?';
      final existing = await _db.queryOne(checkSql, [email]);

      if (existing != null) {
        _errorMessage = 'Cet email est déjà utilisé';
        logger.w('Tentative d\'inscription avec un email existant: $email');
        return false;
      }

      // Créer le nouvel utilisateur
      const insertSql = '''
        INSERT INTO User (email, nom, prenom, password, isAdmin, createdAt)
        VALUES (?, ?, ?, ?, ?, ?)
      ''';

      final userId = await _db.insert(insertSql, [
        email,
        nom,
        prenom,
        password, // En production, utiliser bcrypt
        false,
        DateTime.now().toIso8601String(),
      ]);

      _currentUser = User(
        userId: userId,
        email: email,
        nom: nom,
        prenom: prenom,
        isAdmin: false,
        createdAt: DateTime.now(),
      );
      _isAuthenticated = true;

      logger.i('Nouvel utilisateur créé: $email');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de l\'inscription: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Déconnexion
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    logger.i('Utilisateur déconnecté');
    notifyListeners();
  }

  /// Charge l'utilisateur actuel
  Future<bool> loadCurrentUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          userId, email, nom, prenom, password, isAdmin, createdAt
        FROM User
        WHERE userId = ?
      ''';

      final row = await _db.queryOne(sql, [userId]);

      if (row != null) {
        _currentUser = User.fromMap(row);
        _isAuthenticated = true;
        logger.i('Utilisateur $userId chargé');
        return true;
      } else {
        _errorMessage = 'Utilisateur non trouvé';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement de l\'utilisateur: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour le profil utilisateur
  Future<bool> updateProfile(String nom, String prenom) async {
    if (_currentUser == null) {
      _errorMessage = 'Aucun utilisateur connecté';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        UPDATE User
        SET nom = ?, prenom = ?
        WHERE userId = ?
      ''';

      await _db.execute(sql, [nom, prenom, _currentUser!.userId]);

      _currentUser = _currentUser!.copyWith(nom: nom, prenom: prenom);

      logger.i('Profil de l\'utilisateur ${_currentUser!.userId} mis à jour');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la mise à jour du profil: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change le mot de passe
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) {
      _errorMessage = 'Aucun utilisateur connecté';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        UPDATE User
        SET password = ?
        WHERE userId = ?
      ''';

      await _db.execute(sql, [newPassword, _currentUser!.userId]);

      logger.i('Mot de passe de l\'utilisateur ${_currentUser!.userId} changé');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du changement de mot de passe: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime le compte
  Future<bool> deleteAccount(String password) async {
    if (_currentUser == null) {
      _errorMessage = 'Aucun utilisateur connecté';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = 'DELETE FROM User WHERE userId = ?';

      await _db.execute(sql, [_currentUser!.userId]);

      final deletedUserId = _currentUser!.userId;
      _currentUser = null;
      _isAuthenticated = false;

      logger.i('Compte de l\'utilisateur $deletedUserId supprimé');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la suppression du compte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vérifie si l'email existe
  Future<bool> emailExists(String email) async {
    try {
      const sql = 'SELECT userId FROM User WHERE email = ?';
      final row = await _db.queryOne(sql, [email]);
      return row != null;
    } catch (e) {
      logger.e('Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }
}
