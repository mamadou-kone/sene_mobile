import 'dart:convert';
import '../config.dart';
import '../models/panier_produit.dart'; // Import de PanierProduit
import 'package:http/http.dart' as http;

class PanierController {
  Future<List<PanierProduit>> getProduitsPanier(String userId) async {
    final url = '${Config.baseUrl}/panier/client/$userId/produits';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 201 || response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.isEmpty) {
        return []; // Retourne une liste vide si aucune donnée n'est présente
      }

      List<PanierProduit> panierProduits = [];
      for (var panierProduitData in jsonResponse) {
        //Pour Créer un objet PanierProduit à partir des données
        panierProduits.add(PanierProduit.fromJson(panierProduitData));
      }

      return panierProduits; // Retourner la liste de PanierProduit
    } else {
      throw Exception('Erreur lors de la récupération des produits du panier');
    }
  }

  Future<void> updateQuantite(
      String panierProduitId, int nouvelleQuantite) async {
    final url =
        '${Config.baseUrl}/panier-produit/update-quantite?panierProduitId=$panierProduitId&nouvelleQuantite=$nouvelleQuantite';

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print("Quantité mise à jour avec succès");
    } else {
      throw Exception('Erreur lors de la mise à jour de la quantité');
    }
  }

  Future<void> addProduitToPanier(
      String userId, String produitId, String panierId, int quantite) async {
    final url = '${Config.baseUrl}/panier-produit';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'produit': {
          'id': produitId,
        },
        'panier': {
          'id': panierId,
          'client': {
            'id': userId,
          },
        },
        'quantite': quantite, // Ajoutez la quantité souhaitée
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Produit ajouté au panier avec succès');
    } else {
      throw Exception(
          'Erreur lors de l\'ajout du produit au panier : ${response.body}');
    }
  }
}
