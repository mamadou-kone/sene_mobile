import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sene_mobile/models/panier_produit.dart';
import 'package:sene_mobile/vues/client/panier_item.dart';
import '../../controleur/panier_controleur.dart';
import '../../couleur.dart';

class PanierPage extends StatefulWidget {
  final String userId;

  PanierPage({required this.userId});

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  late Future<List<PanierProduit>> panierProduitsFuture;

  @override
  void initState() {
    super.initState();
    panierProduitsFuture = PanierController().getProduitsPanier(widget.userId);
  }

  // Méthode pour mettre à jour la quantité dans le panier
  void _updateQuantite(String panierProduitId, int nouvelleQuantite) async {
    try {
      await PanierController()
          .updateQuantite(panierProduitId, nouvelleQuantite);
      setState(() {
        panierProduitsFuture =
            PanierController().getProduitsPanier(widget.userId);
      });
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mon Panier')),
      body: FutureBuilder<List<PanierProduit>>(
        future: panierProduitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Votre panier est vide'));
          } else {
            List<PanierProduit> panierProduits = snapshot.data!;
            final total = panierProduits.fold(
                0.0,
                (total, panierProduit) =>
                    total +
                    (panierProduit.produit.prix * panierProduit.quantite));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...panierProduits.map((panierProduit) {
                    return PanierItem(
                      panierProduit: panierProduit,
                      onUpdateQuantite: _updateQuantite,
                    );
                  }).toList(),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total (${panierProduits.length} articles)"),
                      Text(
                        "$total FCFA",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Couleur.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Logique pour procéder au paiement
                      },
                      label: Text(
                        "Procéder au paiement",
                        style: TextStyle(color: Couleur.primary),
                      ),
                      icon: Icon(Icons.arrow_forward, color: Couleur.primary),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
