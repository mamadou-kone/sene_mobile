import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/projet.dart';
import '../services/projet_service.dart';

class ProjetController with ChangeNotifier {
  final ProjetService projetService;
  List<Projet> projets = [];
  List<Projet> myProjets =
      []; // Liste pour les projets de l'utilisateur connecté

  // ID de l'utilisateur connecté
  final String currentUserId;

  ProjetController(this.projetService, this.currentUserId);

  // Charger la liste des projets
  Future<void> loadProjets() async {
    try {
      projets = await projetService.fetchProjets();
      notifyListeners(); // Notifie les écouteurs de changement
    } catch (e) {
      print('Erreur lors du chargement des projets: $e');
    }
  }

  // Filtrer les projets de l'utilisateur connecté
  void filterMyProjets() {
    myProjets = projets.where((projet) {
      return projet.agriculteur['id'] ==
          currentUserId; // Comparer l'ID de l'agriculteur
    }).toList();
    notifyListeners(); // Notifie les écouteurs de changement
  }

  // Obtenir la liste des projets
  List<Projet> getProjets() {
    return projets;
  }

  // Obtenir la liste des projets de l'utilisateur connecté
  List<Projet> getMyProjets() {
    return myProjets;
  }

  // Ajouter un nouveau projet
  Future<void> addProjet(
      String titre,
      String description,
      double montantNecessaire,
      String agriculteurId, // Ajout de l'ID de l'agriculteur
      {File? image}) async {
    if (agriculteurId.isEmpty) {
      throw Exception('ID de l\'agriculteur est requis');
    }

    Projet projet = Projet(
      titre: titre,
      description: description,
      montantNecessaire: montantNecessaire,
      statut: true,
      agriculteur: {'id': agriculteurId}, // Passer l'ID de l'agriculteur
    );

    try {
      await projetService.create('projet', projet.toJson(), image: image);
      await loadProjets(); // Recharge la liste des projets
      filterMyProjets(); // Met à jour la liste des projets de l'utilisateur
    } catch (e) {
      print('Erreur lors de l\'ajout du projet: $e');
    }
  }
}
