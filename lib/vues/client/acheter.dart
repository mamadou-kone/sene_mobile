import 'dart:convert'; // Pour utiliser base64Decode
import 'package:flutter/material.dart';
import 'package:sene_mobile/controleur/panier_controleur.dart';
import 'package:sene_mobile/models/produit.dart';
import 'package:sene_mobile/services/auth_controleur.dart';
import '../../couleur.dart';

class AcheterPage extends StatefulWidget {
  final Produit produit;

  const AcheterPage({Key? key, required this.produit}) : super(key: key);

  @override
  _AcheterPageState createState() => _AcheterPageState();
}

class _AcheterPageState extends State<AcheterPage> {
  AuthController authController = AuthController.instance;
  bool _isLoading = false;

  // Méthode pour ajouter le produit au panier
  Future<void> _ajouterAuPanier() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit ajouté au panier avec succès !')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var agriculteur = widget.produit.agriculteur;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produit.nom),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Afficher l'image du produit
              widget.produit.image != null
                  ? Image.memory(
                      base64Decode(widget.produit.image!),
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    )
                  : Container(),
              const SizedBox(height: 16),

              // Détails du produit
              Text(
                'Prix du Produit: ${widget.produit.prix} FCFA',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Couleur.primary),
              ),
              const SizedBox(height: 8),
              Text(
                widget.produit.description.isNotEmpty
                    ? widget.produit.description
                    : 'Pas de description disponible.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Afficher les informations de l'agriculteur avec photo
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: agriculteur['image'] != null &&
                            agriculteur['image'].isNotEmpty
                        ? MemoryImage(base64Decode(agriculteur['image']))
                        : null,
                    radius: 30,
                    child: agriculteur['image'] == null ||
                            agriculteur['image'].isEmpty
                        ? Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créé par : ${agriculteur['nom']} ${agriculteur['prenom']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Téléphone : ${agriculteur['tel']}'),
                        Text('Adresse : ${agriculteur['address']}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bouton pour ajouter au panier
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _ajouterAuPanier,
                        icon: Icon(Icons.shopping_cart, color: Colors.white),
                        label: Text(
                          'Ajouter au panier',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Couleur.primary,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
