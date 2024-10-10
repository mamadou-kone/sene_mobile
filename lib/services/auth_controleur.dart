import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/user.dart';

class AuthController {
  static final AuthController _instance = AuthController._internal();

  // Stocke l'utilisateur connecté
  Map<String, dynamic>? currentUser;

  // Constructeur privé pour le singleton
  AuthController._internal();

  // Accès à l'instance unique
  static AuthController get instance => _instance;

  final String apiUrl = 'http://10.175.48.25:8080/auth/connexion';

  // Fonction de login qui stocke le token et les informations de l'utilisateur
  Future<Map<String, dynamic>> login(User user) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['bearer'] != null) {
        String token = data['bearer'];
        final jwt = JWT.decode(token);
        String userId = jwt.payload['userId'] ?? '0';
        String role = jwt.payload['role'] ?? 'unknown';
        String nom = jwt.payload['nom'] ?? 'inconnu';
        String prenom = jwt.payload['prenom'] ?? 'inconnu';
        String email = jwt.payload['sub'] ?? 'inconnu';
        String? imageBase64 = jwt.payload['image'];
        Uint8List? imageBytes;

        if (imageBase64 != null) {
          imageBytes = base64Decode(imageBase64);
        }

        // Stocker les informations de l'utilisateur
        currentUser = {
          'userId': userId,
          'role': role,
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'image': imageBytes,
          'token': token,
        };

        return {'success': true, ...currentUser!};
      }
    }
    return {'success': false};
  }

  // Récupérer le userId
  String? get userId => currentUser?['userId'];

  // Récupérer l'email de l'utilisateur connecté
  String? get email => currentUser?['email'];

// Autres getters pour les informations utilisateur
}
