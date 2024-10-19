import 'package:sene_mobile/models/agriculteur.dart';

class Produit {
  final int? id; // Utiliser int si l'ID est un entier
  final String nom;
  final String description;
  final double prix;
  final double? quantite;
  final bool statut;
  final String? image; // Peut être une chaîne base64 ou une URL
  final Map<String, dynamic> agriculteur; // ID de l'agriculteur

  Produit({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.quantite,
    required this.statut,
    this.image,
    required this.agriculteur,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] != null ? json['id'] as int : null,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      quantite: (json['quantite'] as num?)?.toDouble(),
      statut: json['statut'] ?? false,
      image: json['image'] is String ? json['image'] : null,
      agriculteur: json['agriculteur'] != null ? json['agriculteur'] : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'quantite': quantite,
      'statut': statut,
      'image': image,
      'agriculteur': agriculteur,
    };
  }
}
