import 'package:flutter/material.dart';

import '../../models/projet.dart';

class DetailProjetPage extends StatelessWidget {
  final Projet projet; // Paramètre pour recevoir le projet

  const DetailProjetPage({Key? key, required this.projet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projet.titre), // Affiche le titre du projet
      ),
      body: Center(
        child: Text(projet.description), // Affiche la description du projet
      ),
    );
  }
}
