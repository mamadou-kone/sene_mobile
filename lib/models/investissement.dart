import 'investisseur.dart';

class Investissement {
  final double montant;
  final String? dateInvestissement; // Format selon vos besoins
  final String investisseurId; // ID de l'investisseur
  final String projetId; // ID du projet

  Investissement({
    required this.montant,
    this.dateInvestissement,
    required this.investisseurId,
    required this.projetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
      'dateInvestissement': dateInvestissement,
      'investisseur': {
        'id': investisseurId,
      },
      'projet': {
        'id': projetId,
      }
    };
  }

  factory Investissement.fromJson(Map<String, dynamic> json) {
    return Investissement(
      montant: json['montant']?.toDouble() ?? 0.0,
      dateInvestissement: json['dateInvestissement'] ?? 'Date non disponible',
      investisseurId: json['investisseur']['id']?.toString() ??
          'ID non disponible', // Récupère uniquement l'ID
      projetId: json['projet']['id']?.toString() ??
          'ID non disponible', // Modifie ici pour l'ID du projet
    );
  }
}
