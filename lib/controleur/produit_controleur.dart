import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sene_mobile/services/auth_controleur.dart';
import 'package:sene_mobile/services/produit_service.dart';
import '../models/produit.dart';

class ProduitController with ChangeNotifier {
  final ProduitService _produitService;
  List<Produit> produits = [];
  List<Produit> myProduits =
      []; // Liste pour les produits de l'utilisateur connecté

  // ID de l'utilisateur connecté
  String currentUserId = AuthController.instance.userId ?? '';

  ProduitController(this._produitService);

  // Charger la liste des produits
  Future<void> loadProduits() async {
    try {
      produits = await _produitService.fetchProduit();
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
  List<Produit> getProduits() => produits;

  // Obtenir la liste des produits de l'utilisateur connecté
  List<Produit> getMyProduits() => myProduits;

  // Ajouter un nouveau produit
  Future<void> addProduit(String nom, String description, double prix,
      double quantite, String agriculteurId,
      {File? image}) async {
    if (agriculteurId.isEmpty) {
      throw Exception('ID de l\'agriculteur est requis');
    }

    // Créer un nouvel objet produit
    Produit produit = Produit(
      nom: nom,
      description: description,
      prix: prix,
      quantite: quantite,
      statut: true,
      agriculteur: {'id': agriculteurId}, // Passer l'ID de l'agriculteur
    );

    try {
      await _produitService.create('produit', produit.toJson(), image: image);
      await loadProduits(); // Recharge la liste des produits
      filterMyProduits(); // Met à jour la liste des produits de l'utilisateur
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
    }
  }

  // Charger les produits de l'utilisateur connecté
  Future<void> loadMyProduits() async {
    try {
      myProduits =
          await _produitService.fetchProduitsByAgriculteur(currentUserId);
      notifyListeners(); // Notifie les écouteurs de changement
    } catch (e) {
      print('Erreur lors du chargement des produits de l\'utilisateur: $e');
    }
  }

  // Mettre à jour un produit
  Future<void> updateProduit(
      int? id, Produit produit, Uint8List? imageBytes) async {
    // Convertir l'objet produit en JSON
    final produitData = produit.toJson();

    if (id == null) {
      throw Exception('L\'ID ne peut pas être nul');
    }

    try {
      if (imageBytes != null) {
        // Mettre à jour avec l'image si fournie
        await _produitService.updateProduitWithImage(
            'produit/${id.toString()}', produitData, imageBytes);
      } else {
        // Sinon, mettre à jour sans image
        await _produitService.update('produit/${id.toString()}', produitData);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
    }
  }
}
