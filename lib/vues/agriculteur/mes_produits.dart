import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../couleur.dart';
import '../../models/produit.dart';
import '../../services/auth_controleur.dart';
import '../../services/produit_service.dart';

class MesProduits extends StatelessWidget {
  final ProduitService produitService = ProduitService();
  final AuthController authController = AuthController.instance;

  Future<List<Produit>> _getProduitsForUser() async {
    if (authController.currentUser == null) {
      print('L\'utilisateur n\'est pas connecté');
      return []; // Retourne une liste vide
    }

    final userId = authController.currentUser!['userId'].toString();
    print('Récupération des produits pour l\'utilisateur ID: $userId');

    final produits = await produitService.fetchProduitsByAgriculteur(userId);
    print('Produits récupérés: ${produits.length}');
    produits.forEach((produit) {
      print('Produit: ${produit.nom}, Prix: ${produit.prix}');
    });
    return produits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Produits', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
      ),
      body: FutureBuilder<List<Produit>>(
        future: _getProduitsForUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit trouvé'));
          }

          final produits = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: produit.image != null
                      ? Image.network(produit.image!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.broken_image, color: Colors.grey),
                  title: Text(
                    produit.nom,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Prix: ${produit.prix} FCFA\nQuantité: ${produit.quantite ?? 0}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
