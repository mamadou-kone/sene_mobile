import 'dart:convert';
import 'dart:ui'; // Pour ImageFilter
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/services/auth_controleur.dart';
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
  String currentUserId = AuthController.instance.userId ?? '';
  String nom = AuthController.instance.currentUser?['nom'] ?? 'Invité';
  String prenom = AuthController.instance.currentUser?['prenom'] ?? '';
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = ProjetController(ProjetService(), currentUserId);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      await controller.loadProjets();
      setState(() {
        projects = controller.getProjets();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des projets')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Couleur.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue,",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "$nom $prenom 👋🏾",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
          SizedBox(width: 10),
        ],
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          isLoading ? _buildLoadingIndicator() : _buildHome(),
          MesInvestissement(userId: currentUserId),
          MessagePage(),
          InvestorProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Couleur.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un projet',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon:
                            Icon(Icons.search, color: Couleur.secondary),
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Projets en vedette',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildEnhancedCarousel(),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tous les projets',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Couleur.secondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _buildProjectGrid(),
          SizedBox(height: 20),
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

  int _currentCarouselIndex = 0;

  Widget _buildEnhancedCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: projects.length,
          itemBuilder: (context, index, realIndex) {
            final project = projects[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    offset: Offset(0, 3),
                  ),
                ],
                image: project.image != null && project.image!.isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(project.image!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                        color: Colors.black.withOpacity(0.7),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.titre,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Montant Nécessaire: ${project.montantNecessaire} FCFA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              // Remplacer setState avec un simple changement d'index sans reconstruire toute la page
              _currentCarouselIndex = index;
            },
          ),
        ),
        SizedBox(height: 10),
        _buildCarouselIndicators(),
      ],
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: projects.asMap().entries.map((entry) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentCarouselIndex == entry.key
                ? Couleur.primary
                : Colors.grey.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: projet.image != null && projet.image!.isNotEmpty
                        ? Image.memory(
                            base64Decode(projet.image!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[500],
                            ),
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          projet.titre,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${projet.montantNecessaire} FCFA',
                          style: TextStyle(
                            fontSize: 14,
                            color: Couleur.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          tabs: const [
            GButton(icon: Icons.home, text: 'Accueil'),
            GButton(icon: Icons.assignment, text: 'Investissement'),
            GButton(icon: Icons.message, text: 'Messages'),
            GButton(icon: Icons.person, text: 'Profil'),
          ],
        ),
      ),
    );
  }
}
