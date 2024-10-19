import 'package:sene_mobile/models/produit.dart';

class PanierProduit {
  final int? id; // ID de l'association PanierProduit
  final int panierId; // ID du panier
  final Produit produit; // Détails du produit
  final int quantite; // Quantité de ce produit dans le panier

  PanierProduit({
    this.id,
    required this.panierId,
    required this.produit,
    required this.quantite,
  });

  factory PanierProduit.fromJson(Map<String, dynamic> json) {
    return PanierProduit(
      id: json['id'], // ID de l'association PanierProduit
      panierId: json['panier']['id'], // ID du panier
      produit:
          Produit.fromJson(json['produit']), // Utilisation du modèle Produit
      quantite: json['quantite'] ?? 0, // Quantité
    );
  }
}
