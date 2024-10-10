import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/projet.dart';

class ProjetService {
  ProjetService();

  // Ajouter un projet
  Future<void> create(String endpoint, Map<String, dynamic> data,
      {File? image}) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('${Config.baseUrl}/$endpoint'));

    request.fields['projet'] = jsonEncode(data);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

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
}
