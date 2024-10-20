import 'Produit.dart'; // Importer ton modèle de Produit

class PanierProduit {
  final int? id;
  final int panierId;
  final Produit produit;
  final int quantite;

  PanierProduit({
    this.id,
    required this.panierId,
    required this.produit,
    required this.quantite,
  });

  // Méthode pour convertir un PanierProduit en JSON
  Map<String, dynamic> toJson() {
    return {
      'panier': {'id': panierId},
      'produit': {'id': produit.id}, // Utiliser l'ID du produit
      'quantite': quantite,
    };
  }

  // Méthode pour créer un PanierProduit à partir de JSON
  factory PanierProduit.fromJson(Map<String, dynamic> json) {
    return PanierProduit(
      id: json['id'],
      panierId: json['panier']['id'],
      produit: Produit.fromJson(
          json['produit']), // Utilisation de Produit.fromJson()
      quantite: json['quantite'],
    );
  }
}
