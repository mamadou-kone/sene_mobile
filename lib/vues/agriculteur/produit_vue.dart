import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/agriculteur/produit_forme.dart';
import '../../controleur/produit_controleur.dart';
import '../../models/produit.dart';
import '../../services/auth_controleur.dart';
import '../../services/produit_service.dart';
import 'ajout_produit.dart';
import 'detail_produit.dart';

class ProduitPage extends StatefulWidget {
  const ProduitPage({Key? key}) : super(key: key);

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  late ProduitController controller;
  String currentUserId = AuthController.instance.userId ?? '';
  int selectedIndex = 0; // Indice de catégorie sélectionnée
  List<Produit> produitsToDisplay = [];

  @override
  void initState() {
    super.initState();
    controller = ProduitController(ProduitService());
    controller.loadProduits().then((_) {
      setState(() {
        produitsToDisplay = controller.getProduits();
      });
    });
  }

  void _loadMyProduits() {
    controller.loadMyProduits().then((_) {
      setState(() {
        produitsToDisplay = controller.getMyProduits();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<String> productCategories = ['Tous', 'Mes produits'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Produits', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Couleur.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black54.withOpacity(.6)),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher un produit',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Catégories de produits
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              height: 50.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productCategories.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        if (index == 1) {
                          _loadMyProduits(); // Charger les produits de l'utilisateur
                        } else {
                          produitsToDisplay = controller
                              .getProduits(); // Afficher tous les produits
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        productCategories[index],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.w300,
                          color: selectedIndex == index
                              ? Couleur.primary
                              : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Liste des produits ou message si vide
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: size.height * 0.7,
              child: produitsToDisplay.isEmpty
                  ? Center(
                      child: Text('Aucun produit créé par vous',
                          style:
                              TextStyle(fontSize: 18, color: Colors.black54)))
                  : ListView.builder(
                      itemCount: produitsToDisplay.length,
                      itemBuilder: (BuildContext context, int index) {
                        final produit = produitsToDisplay[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: DetailProduitPage(produit: produit),
                                type: PageTransitionType.bottomToTop,
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  produit.image != null
                                      ? Image.memory(
                                          base64Decode(produit.image!),
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 100,
                                          width: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child: Text('Pas d\'image')),
                                        ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produit.nom,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          produit.description,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Prix: \$${produit.prix}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Quantité: ${produit.quantite ?? 'Non spécifiée'}',
                                          style: TextStyle(
                                            color: Couleur.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Bouton d'édition visible uniquement dans "Mes produits"
                                  if (selectedIndex == 1)
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Couleur.primary),
                                      onPressed: () {
                                        // Naviguer vers la page d'édition du produit
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            child: FormulaireProduit(
                                                produit:
                                                    produit), // Passez le produit à modifier
                                            type:
                                                PageTransitionType.bottomToTop,
                                          ),
                                        ).then((_) {
                                          // Recharger les produits après modification
                                          _loadMyProduits();
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: ProduitForm(), // Page pour ajouter un nouveau produit
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        backgroundColor: Couleur.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
