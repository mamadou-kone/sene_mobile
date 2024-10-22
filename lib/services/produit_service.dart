import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Assurez-vous d'importer Uint8List
import 'package:http/http.dart' as http;
import 'package:sene_mobile/models/produit.dart';
import '../config.dart';

class ProduitService {
  ProduitService();

  // Ajouter un produit
  Future<void> create(String endpoint, Map<String, dynamic> data,
      {File? image}) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('${Config.baseUrl}/$endpoint'));

    request.fields['produit'] = jsonEncode(data);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    await _handleCreateResponse(streamedResponse);
  }

  // Gérer la réponse du serveur pour la création
  Future<void> _handleCreateResponse(http.StreamedResponse response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Produit ajouté avec succès');
    } else {
      final responseData = await response.stream.bytesToString();
      throw Exception('Erreur lors de l\'ajout du produit : $responseData');
    }
  }

  // Récupérer la liste des produits
  Future<List<Produit>> fetchProduit() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/produit'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Produit.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors du chargement des produits : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau : $e');
    }
  }

  Future<List<Produit>> fetchProduitsByAgriculteur(String agriculteurId) async {
    try {
      final response = await http.get(
          Uri.parse('${Config.baseUrl}/produit/agriculteur/$agriculteurId'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse
              .map((produitJson) => Produit.fromJson(produitJson))
              .toList();
        } else if (jsonResponse is Map && jsonResponse['produits'] != null) {
          List<dynamic> produitsList = jsonResponse['produits'];
          return produitsList
              .map((produitJson) => Produit.fromJson(produitJson))
              .toList();
        } else {
          throw Exception(
              'Réponse inattendue : l\'objet est un Map sans liste de produits.');
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des produits : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau : $e');
    }
  }

  // Mise à jour d'un produit avec ou sans image

  Future<void> updateProduitWithImage(
      String endpoint, Map<String, dynamic> data, Uint8List? imageBytes) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('${Config.baseUrl}/$endpoint'));

    // Convertir les données du produit en JSON
    request.fields['produit'] = jsonEncode(data);

    if (imageBytes != null) {
      // Ajouter l'image au corps de la requête
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
      ));
    }

    // Envoyer la requête
    final streamedResponse = await request.send();
    await _handleUpdateResponse(streamedResponse);
  }

  // Mise à jour d'un produit sans image
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
      print('Produit mis à jour avec succès');
    } else {
      final responseData = await response.stream.bytesToString();
      throw Exception(
          'Erreur lors de la mise à jour du produit : $responseData');
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
