import 'dart:io';
import '../models/investisseur.dart'; // Assurez-vous que le chemin est correct
import '../services/crud/investisseur_service.dart'; // Vérifiez que ce chemin est correct

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

  Future<void> updateInvestisseur(String id, Investisseur investisseur) async {
    await _crudService.update('investisseur/$id', investisseur.toJson());
  }

  Future<void> deleteInvestisseur(String id) async {
    await _crudService.delete('investisseur/$id');
  }
}
