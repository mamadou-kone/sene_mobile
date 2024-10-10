import 'package:flutter/material.dart';
import 'package:sene_mobile/sans_acces.dart';
import 'package:sene_mobile/vues/agriculteur/agriculteur_vue.dart';
import 'package:sene_mobile/vues/agriculteur/home_agriculteur.dart';
import 'package:sene_mobile/vues/agriculteur/login_vente.dart';
import 'package:sene_mobile/vues/client/client_vue.dart';
import 'package:sene_mobile/vues/client/home_achat.dart';
import 'package:sene_mobile/vues/client/login_achat.dart';
import 'package:sene_mobile/vues/investisseur/home_investisseur.dart';
import 'package:sene_mobile/vues/investisseur/investisseur_vue.dart';
import 'package:sene_mobile/vues/investisseur/login_investisseur.dart';
import 'package:sene_mobile/vues/welcome/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => WelcomePage(),
        '/loginInvestisseur': (context) => LoginIvestisseur(),
        '/homeInvestisseur': (context) => HomeInvestisseur(),
        '/access_denied': (context) => AccessDeniedPage(),
        '/loginVendre': (context) => LoginVendre(),
        '/clientAjout': (context) => ClientForm(),
        '/loginAchat': (context) => LoginAcheter(),
        '/homeAchat': (context) => HomeAchat(),
        '/agriculteurAjout': (context) => AgriculteurForm(),
        '/homeAgriculteur': (context) => HomeAgriculteur(
              userInfo: {},
            ),
        '/investisseurAjout': (context) => InvestisseurForm(),
        '/clientAjout': (context) => ClientForm(),
        '/loginAchater': (context) => LoginAcheter(),
      },
    );
  }
}
