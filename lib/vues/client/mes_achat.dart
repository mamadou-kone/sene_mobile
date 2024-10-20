import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sene_mobile/couleur.dart';

import '../../models/investissement.dart';
import '../../services/ivestissement_service.dart';
import '../../services/auth_controleur.dart';

class MesAchat extends StatelessWidget {
  final InvestissementService investissementService = InvestissementService();
  final AuthController authController = AuthController.instance;

  Future<List<Investissement>> _getInvestissementsForUser() async {
    final investissements = await investissementService.getAllInvestissements();

    // Filtrer les investissements par ID de l'investisseur connecté
    final userId = authController.currentUser!['userId'].toString();
    return investissements
        .where((investissement) => investissement.investisseurId == userId)
        .toList();
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
      body: FutureBuilder<List<Investissement>>(
        future: _getInvestissementsForUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun investissement trouvé'));
          }

          final investissements = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(
                16.0), // Ajouter du padding autour de la liste
            itemCount: investissements.length,
            itemBuilder: (context, index) {
              final investissement = investissements[index];

              return Card(
                elevation: 4, // Ajouter une ombre pour les cartes
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0), // Espacement entre les cartes
                child: ListTile(
                  leading: Icon(Icons.monetization_on,
                      color: Colors.green), // Icône pour l'investissement
                  title: Text(
                    'Montant: ${investissement.montant}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Date: ${investissement.dateInvestissement}',
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
