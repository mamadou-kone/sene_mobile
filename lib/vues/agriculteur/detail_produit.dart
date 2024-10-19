import 'package:flutter/material.dart';

import '../../models/produit.dart'; // Modèle produit

class DetailProduitPage extends StatelessWidget {
  final Produit produit; // Paramètre pour recevoir le produit

  const DetailProduitPage({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produit.nom), // Affiche le nom du produit
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produit.nom,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              produit.description,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Prix: ${produit.prix.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            if (produit.quantite != null)
              Text(
                'Quantité: ${produit.quantite}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
