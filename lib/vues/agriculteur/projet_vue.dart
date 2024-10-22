import 'dart:convert'; // Pour utiliser base64Decode
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/agriculteur/detail_projet.dart';
import 'package:sene_mobile/vues/agriculteur/projet_from.dart';
import '../../controleur/projet_controleur.dart';
import '../../models/projet.dart';
import '../../services/auth_controleur.dart';
import '../../services/projet_service.dart';
import 'ajout_projet.dart';

class ProjetPage extends StatefulWidget {
  const ProjetPage({Key? key}) : super(key: key);

  @override
  State<ProjetPage> createState() => _ProjetPageState();
}

class _ProjetPageState extends State<ProjetPage> {
  late ProjetController controller;
  String currentUserId = AuthController.instance.userId ?? '';
  int selectedIndex = 0; // Indice de catégorie sélectionnée
  late List<Projet> projetsToDisplay = []; // Liste des projets à afficher

  @override
  void initState() {
    super.initState();
    controller = ProjetController(ProjetService(), currentUserId);
    _loadProjects(); // Charger les projets au démarrage
  }

  void _loadProjects() {
    controller.loadProjets().then((_) {
      setState(() {
        projetsToDisplay = controller.getProjets();
      });
    });
  }

  void _loadMyProjets() {
    controller.loadMyProjets().then((_) {
      setState(() {
        projetsToDisplay = controller.getMyProjets();
      });
    });
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
                        if (selectedIndex == 1) {
                          _loadMyProjets();
                        } else {
                          _loadProjects(); // Recharger tous les projets
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
              child: ListView.builder(
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
                                    base64Decode(projet.image!),
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
                                width: 16), // Espace entre l'image et le texte
                            // Informations du projet
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            // Bouton d'édition visible uniquement pour "Mes projets"
                            if (selectedIndex == 1)
                              IconButton(
                                icon: Icon(Icons.edit, color: Couleur.primary),
                                onPressed: () {
                                  // Naviguer vers la page d'édition du projet
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: FormulaireProjet(
                                          projet:
                                              projet), // Passez le projet à modifier
                                      type: PageTransitionType.bottomToTop,
                                    ),
                                  ).then((_) {
                                    // Recharger les projets après modification
                                    _loadMyProjets();
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
