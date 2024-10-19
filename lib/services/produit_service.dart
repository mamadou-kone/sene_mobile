import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sene_mobile/models/produit.dart';
import '../config.dart';
import '../models/projet.dart';

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
    await _handleStreamedResponse(streamedResponse);
  }

  // Gérer la réponse du serveur
  Future<void> _handleStreamedResponse(http.StreamedResponse response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Produit ajouté avec succès');
    } else {
      final responseData = await response.stream.bytesToString();
      throw Exception('Erreur lors de l\'ajout du produit : $responseData');
    }
  }

  // Récupérer la liste des produit
  Future<List<Produit>> fetchProduit() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/produit'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Produit.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors du chargement des produit : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau : $e');
    }
  }
}
