import 'dart:convert'; // Pour utiliser base64Decode
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/investisseur/profil_investisseur.dart';

import '../../controleur/projet_controleur.dart';
import '../../models/projet.dart';
import '../../services/projet_service.dart';
import 'financer.dart';
import 'mes_investissement.dart';
import 'message_page.dart';

class HomeInvestisseur extends StatefulWidget {
  @override
  _HomeInvestisseurState createState() => _HomeInvestisseurState();
}

class _HomeInvestisseurState extends State<HomeInvestisseur> {
  late ProjetController controller;
  List<Projet> projects = [];
  String currentUserId = 'ID_UTILISATEUR_CONNECTE';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = ProjetController(ProjetService(), currentUserId);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await controller.loadProjets();
    setState(() {
      projects = controller.getProjets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Investisseur',
          style: TextStyle(color: Couleur.primary),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
// Action de recherche ici
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHome(),
          MesInvestissement(),
          MessagePage(),
          InvestorProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildCarousel(),
          _buildProjectGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un projet',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: projects.map((project) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinancierPage(projet: project),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      project.image != null
                          ? Image.memory(
                              base64Decode(project.image!),
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.titre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Montant Nécessaire: ${project.montantNecessaire}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildProjectGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final projet = projects[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinancierPage(projet: projet),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              color: Couleur.primary!.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ClipOval(
                      child: projet.image != null
                          ? Image.memory(
                              base64Decode(projet.image!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                    ),
                    SizedBox(height: 8),
                    Text(
                      projet.titre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Montant: ${projet.montantNecessaire}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: GNav(
          color: Couleur.secondary,
          activeColor: Colors.white,
          tabBackgroundColor: Couleur.primary,
          padding: const EdgeInsets.all(10),
          gap: 8,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: [
            const GButton(
              icon: Icons.home,
              text: 'Accueil',
            ),
            const GButton(
              icon: Icons.assignment,
              text: 'Investissement',
            ),
            const GButton(
              icon: Icons.message,
              text: 'Message',
            ),
            const GButton(
              icon: Icons.person,
              text: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
