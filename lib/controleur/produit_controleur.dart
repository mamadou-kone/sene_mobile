import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sene_mobile/services/produit_service.dart';
import '../models/produit.dart';
import '../models/projet.dart';
import '../services/projet_service.dart';

class ProduitController with ChangeNotifier {
  final ProduitService produitService;
  List<Produit> produits = [];
  List<Produit> myProduits =
      []; // Liste pour les produits de l'utilisateur connecté

  // ID de l'utilisateur connecté
  final String currentUserId;

  ProduitController(this.produitService, this.currentUserId);

  // Charger la liste des produits
  Future<void> loadProduit() async {
    try {
      produits = await produitService.fetchProduit();
      notifyListeners(); // Notifie les écouteurs de changement
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }

  // Filtrer les produits de l'utilisateur connecté
  void filterMyProduits() {
    myProduits = produits.where((produit) {
      return produit.agriculteur['id'] ==
          currentUserId; // Comparer l'ID de l'agriculteur
    }).toList();
    notifyListeners(); // Notifie les écouteurs de changement
  }

  // Obtenir la liste des produits
  List<Produit> getProduits() {
    return produits;
  }

  // Obtenir la liste des produits de l'utilisateur connecté
  List<Produit> getMyProduits() {
    return myProduits;
  }

  // Ajouter un nouveau produit
  Future<void> addProduits(String nom, String description, double prix,
      double quantite, String agriculteurId, // Ajout de l'ID de l'agriculteur
      {File? image}) async {
    if (agriculteurId.isEmpty) {
      throw Exception('ID de l\'agriculteur est requis');
    }

    Produit produit = Produit(
      nom: nom,
      description: description,
      prix: prix,
      quantite: quantite,
      statut: true,
      agriculteur: {'id': agriculteurId}, // Passer l'ID de l'agriculteur
    );

    try {
      await produitService.create('produit', produit.toJson(), image: image);
      await loadProduit(); // Recharge la liste des produits
      filterMyProduits(); // Met à jour la liste des produits de l'utilisateur
    } catch (e) {
      print('Erreur lors de l\'ajout du prduit: $e');
    }
  }
}
