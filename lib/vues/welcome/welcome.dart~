import 'package:flutter/material.dart';

import '../../couleur.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond
          Image.asset(
            'assets/images/bg.png', //
            fit: BoxFit.cover,
          ),
          // Contenu en haut de l'image
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Image.asset(
                'assets/images/logo_sene_noir.png',
              )),
              SizedBox(height: 40),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 50, right: 50),
                child: Text(
                  'Bienvenue! Vous voulez investir ou Acheter ou encore vendre?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Couleur.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // Action pour le bouton Investir
                    Navigator.pushNamed(context, '/loginInvestisseur');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primary),
                  child: Text('Investir',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // Action pour le bouton Vendre
                    Navigator.pushNamed(context, '/loginVendre');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primary),
                  child: Text(
                    'Vendre',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // Action pour le bouton Acheter
                    Navigator.pushNamed(context, '/loginAchater');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primary),
                  child: Text('Acheter',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
