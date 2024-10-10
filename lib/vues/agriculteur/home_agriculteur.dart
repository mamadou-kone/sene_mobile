import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/agriculteur/produit_vue.dart';
import 'package:sene_mobile/vues/agriculteur/profil_vue.dart';
import 'package:sene_mobile/vues/agriculteur/projet_vue.dart';

class HomeAgriculteur extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  HomeAgriculteur({required this.userInfo});

  @override
  _HomeAgriculteurState createState() => _HomeAgriculteurState();
}

class _HomeAgriculteurState extends State<HomeAgriculteur> {
  String? activeItem; // L'élément actuellement actif

  void _onItemTap(String item) {
    setState(() {
      activeItem = item; // Met à jour l'élément actif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue, ${widget.userInfo['nom']}!',
            style: TextStyle(fontSize: 24)),
      ),
      drawer: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0), // Arrondi en haut à droite
          bottomRight: Radius.circular(30.0), // Arrondi en bas à droite
        ),
        child: Drawer(
          width: 200,
          child: Container(
            color: Colors.grey[300], // Couleur du Drawer
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // En-tête personnalisé
                Container(
                  color: Couleur.primary, // Couleur du DrawerHeader
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40, // Taille de l'image
                        backgroundImage: widget.userInfo['image'] != null
                            ? MemoryImage(widget.userInfo['image'] as Uint8List)
                            : null,
                        child: widget.userInfo['image'] == null
                            ? Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          '${widget.userInfo['nom']} ${widget.userInfo['prenom']}',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.userInfo['email'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Boutons du Drawer
                _buildMenuItem(Icons.person, 'Mon Profil',
                    ProfilPage(userId: widget.userInfo['userId'])),
                _buildMenuItem(Icons.assignment, 'Projet', ProjetPage()),
                _buildMenuItem(Icons.list, 'Produit', ProduitPage()),
                Spacer(), // Espace pour pousser le bouton de déconnexion vers le bas
                Container(
                  width: 190,
                  height: 50,
                  margin: EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Couleur.primary,
                    borderRadius:
                        BorderRadius.circular(30), // Ajoute un bord arrondi
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout,
                        color: Colors.white), // Icône pour Déconnexion
                    title: Text('Déconnexion',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Action pour déconnexion
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Bienvenue, ${widget.userInfo['nom']}!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Widget targetPage) {
    final isSelected = activeItem == title; // Vérifie si l'élément est actif

    return GestureDetector(
      onTap: () {
        _onItemTap(title);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  targetPage), // Navigation vers la page cible
        );
      },
      child: Container(
        color:
            isSelected ? Couleur.primary : Colors.grey[300], // Couleur de fond
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : Couleur.primary, // Couleur de l'icône
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Couleur.primary, // Couleur du texte
            ),
          ),
        ),
      ),
    );
  }
}
