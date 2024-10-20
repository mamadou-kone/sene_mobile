import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Importer Uint8List
import '../config.dart';
import '../models/agriculteur.dart';
import '../services/crud/agriculteur_service.dart';
import 'package:http/http.dart' as http;

class AgriculteurController {
  final AgriculteurService _crudService;

  AgriculteurController() : _crudService = AgriculteurService();

  Future<void> addAgriculteur(Agriculteur agriculteur, File? image) async {
    await _crudService.create('agriculteur', agriculteur.toJson(),
        image: image);
  }

  Future<List<Agriculteur>> getAgriculteurs() async {
    final data = await _crudService.read('agriculteur');
    return (data as List).map((item) => Agriculteur.fromJson(item)).toList();
  }

  Future<void> updateAgriculteur(
      String id, Agriculteur agriculteur, Uint8List? imageBytes) async {
    // Changement ici
    final agriculteurData = agriculteur.toJson();
    if (imageBytes != null) {
      // Changement ici
      await _crudService.updateWithImage(
          'agriculteur/$id', agriculteurData, imageBytes); // Changement ici
    } else {
      await _crudService.update('agriculteur/$id', agriculteurData);
    }
  }

  Future<void> deleteAgriculteur(String id) async {
    await _crudService.delete('agriculteur/$id');
  }

  Future<Map<String, dynamic>?> fetchAgriculteurInfo(String userId) async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/agriculteur/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load agriculteur info');
    }
  }
}
