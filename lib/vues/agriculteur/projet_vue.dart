import 'dart:convert'; // Pour utiliser base64Decode
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/agriculteur/detail_projet.dart';
import '../../controleur/projet_controleur.dart';
import '../../models/projet.dart';
import '../../services/projet_service.dart';
import 'ajout_projet.dart';

class ProjetPage extends StatefulWidget {
  const ProjetPage({Key? key}) : super(key: key);

  @override
  State<ProjetPage> createState() => _ProjetPageState();
}

class _ProjetPageState extends State<ProjetPage> {
  late ProjetController controller;
  String currentUserId = 'ID_UTILISATEUR_CONNECTE'; // Remplacez par l'ID réel
  int selectedIndex = 0; // Indice de catégorie sélectionnée

  @override
  void initState() {
    super.initState();
    controller = ProjetController(
        ProjetService(), currentUserId); // Passer l'ID de l'utilisateur
    controller.loadProjets(); // Chargement des projets au démarrage
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Catégories de projets
    List<String> projectCategories = ['Tous', 'Mes projets'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Projets', style: TextStyle(color: Colors.white)),
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
                    Icon(
                      Icons.search,
                      color: Colors.black54.withOpacity(.6),
                    ),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher un projet',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Catégories de projets
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              height: 50.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: projectCategories.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        // Filtrer les projets ici selon la catégorie sélectionnée
                        if (selectedIndex == 1) {
                          controller
                              .filterMyProjets(); // Filtrer pour "Mes projets"
                        } else {
                          controller
                              .loadProjets(); // Recharger tous les projets
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        projectCategories[index],
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
            // Liste des projets
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: size.height * 0.7,
              child: FutureBuilder(
                future: controller.loadProjets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else {
                    // Utiliser la bonne liste de projets
                    List<Projet> projetsToDisplay = selectedIndex == 1
                        ? controller
                            .getMyProjets() // Projets de l'utilisateur connecté
                        : controller.getProjets(); // Tous les projets

                    return ListView.builder(
                      itemCount: projetsToDisplay.length,
                      itemBuilder: (BuildContext context, int index) {
                        final projet = projetsToDisplay[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: DetailProjetPage(projet: projet),
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
                                  // Affichage de l'image
                                  projet.image != null
                                      ? Image.memory(
                                          base64Decode(projet.image! as String),
                                          height: 100, // Hauteur de l'image
                                          width: 100, // Largeur de l'image
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 100,
                                          width: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child: Text('Pas d\'image')),
                                        ),
                                  const SizedBox(
                                      width:
                                          16), // Espace entre l'image et le texte
                                  // Informations du projet
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          projet.titre,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          projet.description,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Montant Nécessaire: \$${projet.montantNecessaire}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Montant Collecté: \$${projet.montantCollecte}',
                                          style: TextStyle(
                                            color: Couleur.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logique pour ajouter un nouveau projet
          Navigator.push(
            context,
            PageTransition(
              child: ProjetForm(),
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
