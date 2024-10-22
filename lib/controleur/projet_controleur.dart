import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/projet.dart';
import '../services/auth_controleur.dart';
import '../services/projet_service.dart';

class ProjetController with ChangeNotifier {
  final ProjetService projetService;
  List<Projet> projets = [];
  List<Projet> myProjets =
      []; // Liste pour les projets de l'utilisateur connecté
  String currentUserId = AuthController.instance.userId ?? '';

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
  Future<void> addProjet(String titre, String description,
      double montantNecessaire, String agriculteurId,
      {File? image}) async {
    if (agriculteurId.isEmpty) {
      throw Exception('ID de l\'agriculteur est requis');
    }

    Projet projet = Projet(
      titre: titre,
      description: description,
      montantNecessaire: montantNecessaire,
      statut: true,
      agriculteur: {'id': agriculteurId},
    );

    try {
      await projetService.create('projet', projet.toJson(), image: image);
      await loadProjets(); // Recharge la liste des projets
      filterMyProjets(); // Met à jour la liste des projets de l'utilisateur
    } catch (e) {
      print('Erreur lors de l\'ajout du projet: $e');
    }
  }

  // Charger les projets de l'utilisateur connecté
  Future<void> loadMyProjets() async {
    try {
      myProjets = await projetService.fetchProjetsByAgriculteur(currentUserId);
      notifyListeners(); // Notifie les écouteurs de changement
    } catch (e) {
      print('Erreur lors du chargement des projets de l\'utilisateur: $e');
    }
  }

  // Mettre à jour un projet
  Future<void> updateProjet(
      int? id, Projet projet, Uint8List? imageBytes) async {
    // Convertir le projet en JSON
    final projetData = projet.toJson();

    // Afficher le JSON dans la console
    print('Données du projet à envoyer: ${jsonEncode(projetData)}');

    if (id == null) {
      throw Exception('L\'ID ne peut pas être nul');
    }

    try {
      if (imageBytes != null) {
        await projetService.updateProjetWithImage(
            'projet/${id.toString()}', projetData, imageBytes);
        print('Mise à jour réussie avec image');
      } else {
        await projetService.update('projet/${id.toString()}', projetData);
        print('Mise à jour réussie sans image');
      }

      // Rechargez les projets après la mise à jour
      await loadProjets();
      filterMyProjets();
    } catch (e) {
      print('Erreur lors de la mise à jour du projet: $e');
      throw e; // Propagation de l'erreur
    }
  }
}
