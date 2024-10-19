import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/investisseur.dart';
import '../services/crud/investisseur_service.dart';
import '../config.dart';

class InvestisseurController {
  final InvestisseurService _crudService;

  InvestisseurController() : _crudService = InvestisseurService();

  Future<void> addInvestisseur(Investisseur investisseur, File? image) async {
    await _crudService.create('investisseur', investisseur.toJson(),
        image: image);
  }

  Future<List<Investisseur>> getInvestisseurs() async {
    final data = await _crudService.read('investisseur');
    return (data as List).map((item) => Investisseur.fromJson(item)).toList();
  }

  Future<void> updateInvestisseur(
      int? id, Investisseur investisseur, Uint8List? imageBytes) async {
    // Convertir l'objet Investisseur en JSON
    final investisseurData = investisseur.toJson();

    if (id == null) {
      throw Exception('L\'ID ne peut pas être nul');
    }

    if (imageBytes != null) {
      // Si une image est fournie, mettre à jour avec l'image
      await _crudService.updateWithImage(
          'investisseur/${id.toString()}', investisseurData, imageBytes);
    } else {
      // Sinon, mettre à jour sans image
      await _crudService.update(
          'investisseur/${id.toString()}', investisseurData);
    }
  }

  Future<void> deleteInvestisseur(String id) async {
    await _crudService.delete('investisseur/$id');
  }

  Future<Map<String, dynamic>?> fetchInvestisseurInfo(String userId) async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/investisseur/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load investisseur info');
    }
  }
}
