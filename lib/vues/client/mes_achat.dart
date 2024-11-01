import 'package:flutter/material.dart';

import '../../couleur.dart';

class MesAchat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Mes Achats',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Couleur.primary, // Couleur personnalisée pour l'AppBar
      ),
      body: Center(
        child: Text(
          'Bienvenue sur la page de Mes Achats!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Couleur.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
