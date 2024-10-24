import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/models/projet.dart';
import 'package:sene_mobile/services/projet_service.dart';

import '../../models/investissement.dart';
import '../../services/ivestissement_service.dart';
import '../../services/auth_controleur.dart';

class MesProjets extends StatelessWidget {
  final ProjetService projetService = ProjetService();
  final AuthController authController = AuthController.instance;

  Future<List<Projet>> _getProjetsForUser() async {
    final projets = await projetService.fetchProjets();

    // Filtrer les investissements par ID de l'investisseur connecté
    final userId = authController.currentUser!['userId'].toString();
    return projets.where((projet) => projet.agriculteur == userId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Mes Investissements', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary, // Changer la couleur de l'AppBar
      ),
      body: FutureBuilder<List<Projet>>(
        future: _getProjetsForUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun investissement trouvé'));
          }

          final projets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(
                16.0), // Ajouter du padding autour de la liste
            itemCount: projets.length,
            itemBuilder: (context, index) {
              final projet = projets[index];

              return Card(
                elevation: 4, // Ajouter une ombre pour les cartes
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0), // Espacement entre les cartes
                child: ListTile(
                  leading: Icon(Icons.monetization_on,
                      color: Colors.green), // Icône pour l'investissement
                  title: Text(
                    'Montant: ${projet.montantNecessaire}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Date: ${projet.titre}',
                    style: TextStyle(
                        color: Colors.grey[600]), // Couleur gris pour la date
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
