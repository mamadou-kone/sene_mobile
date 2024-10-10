import 'package:sene_mobile/models/agriculteur.dart';

class Projet {
  final int? id; // Utiliser int si l'ID est un entier
  final String titre;
  final String description;
  final double montantNecessaire;
  final double? montantCollecte;
  final bool statut;
  final String? image; // Peut être une chaîne base64 ou une URL
  final Map<String, dynamic> agriculteur; // ID de l'agriculteur

  Projet({
    this.id,
    required this.titre,
    required this.description,
    required this.montantNecessaire,
    this.montantCollecte,
    required this.statut,
    this.image,
    required this.agriculteur,
  });

  factory Projet.fromJson(Map<String, dynamic> json) {
    return Projet(
      id: json['id'] != null ? json['id'] as int : null,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      montantNecessaire: (json['montantNecessaire'] as num?)?.toDouble() ?? 0.0,
      montantCollecte: (json['montantCollecte'] as num?)?.toDouble(),
      statut: json['statut'] ?? false,
      image: json['image'] is String ? json['image'] : null,
      agriculteur: json['agriculteur'] != null ? json['agriculteur'] : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'montantNecessaire': montantNecessaire,
      'montantCollecte': montantCollecte,
      'statut': statut,
      'image': image,
      'agriculteur': agriculteur,
    };
  }
}
