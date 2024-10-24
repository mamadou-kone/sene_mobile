import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/projet.dart';

class ProjetService {
  ProjetService();

  // Ajouter un projet
  Future<void> create(String endpoint, Map<String, dynamic> data,
      {File? image}) async {
    var uri = Uri.parse('${Config.baseUrl}/$endpoint');
    var request = http.MultipartRequest('POST', uri);

    // Ajouter les données du projet en JSON
    request.headers['Content-Type'] = 'application/json';
    request.fields['projet'] = jsonEncode(data);

    // Ajouter une image si elle est fournie
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    // Envoyer la requête
    final streamedResponse = await request.send();
    await _handleStreamedResponse(streamedResponse);
  }

  // Gérer la réponse du serveur
  Future<void> _handleStreamedResponse(http.StreamedResponse response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Projet ajouté avec succès');
    } else {
      final responseData = await response.stream.bytesToString();
      throw Exception('Erreur lors de l\'ajout du projet : $responseData');
    }
  }

  // Récupérer la liste des projets
  Future<List<Projet>> fetchProjets() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/projet'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Projet.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors du chargement des projets : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau : $e');
    }
  }

  // Récupérer les projets par agriculteur
  Future<List<Projet>> fetchProjetsByAgriculteur(String agriculteurId) async {
    try {
      final response = await http.get(
          Uri.parse('${Config.baseUrl}/projet/agriculteur/$agriculteurId'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse
              .map((projetJson) => Projet.fromJson(projetJson))
              .toList();
        } else if (jsonResponse is Map && jsonResponse['projets'] != null) {
          List<dynamic> projetsList = jsonResponse['projets'];
          return projetsList
              .map((projetJson) => Projet.fromJson(projetJson))
              .toList();
        } else {
          throw Exception(
              'Réponse inattendue : l\'objet est un Map sans liste de projets.');
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des projets : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau : $e');
    }
  }

  // Mise à jour d'un projet avec ou sans image
  Future<void> updateProjetWithImage(
      String endpoint, Map<String, dynamic> data, Uint8List? imageBytes) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('${Config.baseUrl}/$endpoint'));

    // Convertir les données du projet en JSON
    request.headers['Content-Type'] = 'application/json';
    request.fields['projet'] = jsonEncode(data);

    if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
      ));
    }

    final streamedResponse = await request.send();
    await _handleUpdateResponse(streamedResponse);
  }

  // Mise à jour d'un projet sans image
  Future<void> update(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    await _handleResponse(response);
  }

  // Gestion de la réponse de mise à jour
  Future<void> _handleUpdateResponse(http.StreamedResponse response) async {
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Projet mis à jour avec succès');
    } else {
      final responseData = await response.stream.bytesToString();
      throw Exception(
          'Erreur lors de la mise à jour du projet : $responseData');
    }
  }

  // Gestion de la réponse générique
  Future<void> _handleResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Réponse traitée avec succès');
    } else {
      final responseData = response.body;
      throw Exception('Erreur lors de la requête : $responseData');
    }
  }
}
