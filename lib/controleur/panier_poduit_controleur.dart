import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sene_mobile/config.dart';
import 'package:sene_mobile/models/panier_produit.dart';
import 'package:sene_mobile/models/produit.dart';

class PanierProduitController {
  get panierProduit => null;

  Future<void> ajouterProduitDansPanier(
      String panier, String produit, int quantite) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/panier-produit'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(panierProduit.toJson()), // Envoi de l'objet JSON
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Produit ajouté avec succès
        print('Produit ajouté dans le panier');
      } else {
        // Gérer l'erreur
        throw Exception('Échec de l\'ajout du produit dans le panier');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout du produit dans le panier: $e');
    }
  }

  Future<List<PanierProduit>> obtenirProduitsDuPanier(int panierId) async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/panier-produit/$panierId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => PanierProduit.fromJson(item)).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des produits: ${response.statusCode}');
    }
  }
}
