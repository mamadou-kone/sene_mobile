import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/agriculteur/login_vente.dart';
import 'package:sene_mobile/vues/agriculteur/produit_vue.dart';
import 'package:sene_mobile/vues/agriculteur/profil_vue.dart';
import 'package:sene_mobile/vues/agriculteur/projet_vue.dart';
import '../../controleur/agriculture_controleur.dart';

class HomeAgriculteur extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  HomeAgriculteur({required this.userInfo});

  @override
  _HomeAgriculteurState createState() => _HomeAgriculteurState();
}

class _HomeAgriculteurState extends State<HomeAgriculteur> {
  Map<String, dynamic>? agriculteurInfo;
  final AgriculteurController agriculteurController = AgriculteurController();

  @override
  void initState() {
    super.initState();
    _fetchAgriculteurInfo();
  }

  Future<void> _fetchAgriculteurInfo() async {
    try {
      agriculteurInfo = await agriculteurController
          .fetchAgriculteurInfo(widget.userInfo['userId']);
      setState(() {});
    } catch (e) {
      print('Erreur de chargement des informations : $e');
    }
  }

  Widget _buildDrawerHeader() {
    return Container(
      color: Couleur.primary,
      padding: EdgeInsets.all(55),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                agriculteurInfo != null && agriculteurInfo!['image'] != null
                    ? MemoryImage(base64Decode(agriculteurInfo!['image']))
                    : null,
            child: agriculteurInfo == null || agriculteurInfo!['image'] == null
                ? Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          SizedBox(height: 10),
          Text(
            '${agriculteurInfo?['nom'] ?? ''} ${agriculteurInfo?['prenom'] ?? ''}',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          Text(
            agriculteurInfo?['email'] ?? '',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Tableau de bord',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Couleur.primary,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildDashboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Couleur.primary,
            Couleur.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${widget.userInfo['nom']}!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Vendez vos produits et suivez vos projets en besoin de financement.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos activités',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildDashboardCard(
                'Produits',
                Icons.inventory,
                Colors.green,
                ProduitPage(),
              ),
              _buildDashboardCard(
                'Projets',
                Icons.assignment,
                Colors.orange,
                ProjetPage(),
              ),
              _buildDashboardCard(
                'Profil',
                Icons.person,
                Colors.blue,
                ProfilPage(userId: widget.userInfo['userId']),
              ),
              _buildDashboardCard(
                'Statistiques',
                Icons.bar_chart,
                Colors.purple,
                SizedBox(), // Conteneur vide, aucune action
              ),
            ],
          ),
          SizedBox(height: 30),
          _buildWeatherWidget(),
          SizedBox(height: 30),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        if (page is! SizedBox) {
          // Vérifie que le conteneur n'est pas vide
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.wb_sunny,
              size: 50,
              color: Colors.orange,
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Météo du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '28°C - Ensoleillé',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activités récentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildActivityItem(
              'Nouveau produit ajouté',
              'Il y a 2 heures',
              Icons.add_circle,
              Colors.green,
            ),
            _buildActivityItem(
              'Projet mis à jour',
              'Il y a 5 heures',
              Icons.update,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      ),
      child: Drawer(
        width: 250,
        child: Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDrawerHeader(),
              SizedBox(height: 20),
              _buildMenuItem(Icons.person, 'Mon Profil',
                  ProfilPage(userId: widget.userInfo['userId'])),
              _buildMenuItem(Icons.assignment, 'Projets', ProjetPage()),
              _buildMenuItem(Icons.list, 'Produits', ProduitPage()),
              Spacer(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Couleur.primary),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Couleur.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 10),
            Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onPressed: () {
        _showLogoutDialog();
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Couleur.primary, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    // Effacer le token de connexion
    await agriculteurController
        .logout(); // Assurez-vous d'avoir une méthode logout dans votre contrôleur

    // Naviguer vers la page de connexion
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginVendre()), // Remplacez par votre page de connexion
      (Route<dynamic> route) => false, // Supprime toutes les routes précédentes
    );
  }
}
