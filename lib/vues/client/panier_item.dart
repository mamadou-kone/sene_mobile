import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../couleur.dart';
import '../../models/panier_produit.dart';

class PanierItem extends StatelessWidget {
  final PanierProduit panierProduit;
  final Function(String, int) onUpdateQuantite;

  const PanierItem({
    Key? key,
    required this.panierProduit,
    required this.onUpdateQuantite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        child: const Icon(
          IconlyLight.delete,
          color: Colors.white,
          size: 25,
        ),
      ),
      onDismissed: (direction) {
        // Logique de suppression à implémenter
      },
      child: SizedBox(
        height: 125,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0.1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (panierProduit.produit.image != null &&
                    panierProduit.produit.image!.isNotEmpty)
                  Container(
                    height: double.infinity,
                    width: 90,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: MemoryImage(
                            base64Decode(panierProduit.produit.image!)),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(panierProduit.produit.nom,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Prix: ${panierProduit.produit.prix} FCFA',
                        style: Theme.of(context).textTheme.bodySmall,
                        selectionColor: Couleur.primary,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Quantité : ${panierProduit.quantite}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Couleur.primary,
                                ),
                          ),
                          SizedBox(
                            height: 30,
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(99),
                              constraints: const BoxConstraints(
                                minHeight: 30,
                                minWidth: 30,
                              ),
                              isSelected: const [false, true, false],
                              children: [
                                const Icon(Icons.remove, size: 20),
                                Text(
                                  "${panierProduit.quantite}",
                                  style: TextStyle(color: Couleur.primary),
                                ),
                                const Icon(Icons.add, size: 20),
                              ],
                              onPressed: (int index) {
                                if (index == 0 && panierProduit.quantite > 1) {
                                  onUpdateQuantite(panierProduit.id.toString(),
                                      panierProduit.quantite - 1);
                                } else if (index == 2) {
                                  onUpdateQuantite(panierProduit.id.toString(),
                                      panierProduit.quantite + 1);
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
