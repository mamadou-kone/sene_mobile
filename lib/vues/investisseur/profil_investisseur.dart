import 'dart:convert';
import 'package:flutter/material.dart';
import '../../controleur/investisseur_controleur.dart';
import '../../models/investisseur.dart';
import '../../services/auth_controleur.dart';
import '../../couleur.dart';
import 'edit_investisseur.dart';

class InvestorProfilePage extends StatefulWidget {
  @override
  _InvestorProfilePageState createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  final InvestisseurController investisseurController =
      InvestisseurController();
  Map<String, dynamic>? investisseurInfo;

  @override
  void initState() {
    super.initState();
    _fetchInvestisseurInfo();
  }

  Future<void> _fetchInvestisseurInfo() async {
    final userId = AuthController.instance.userId;
    if (userId != null) {
      try {
        investisseurInfo =
            await investisseurController.fetchInvestisseurInfo(userId);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la récupération des informations')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Mon Profil', style: TextStyle(color: Colors.white))),
        backgroundColor: Couleur.primary,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: investisseurInfo == null
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: investisseurInfo!['image'] != null &&
                                investisseurInfo!['image'].isNotEmpty
                            ? MemoryImage(
                                base64Decode(investisseurInfo!['image']))
                            : null,
                        child: investisseurInfo!['image'] == null ||
                                investisseurInfo!['image'].isEmpty
                            ? Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Nom: ${investisseurInfo!['nom'] ?? 'Non renseigné'}',
                                style: TextStyle(
                                    fontSize: 24, color: Couleur.primary)),
                            SizedBox(height: 8),
                            Text(
                                'Prénom: ${investisseurInfo!['prenom'] ?? 'Non renseigné'}',
                                style: TextStyle(
                                    fontSize: 24, color: Couleur.primary)),
                            SizedBox(height: 8),
                            Text(
                                'Email: ${investisseurInfo!['email'] ?? 'Non renseigné'}',
                                style: TextStyle(
                                    fontSize: 24, color: Couleur.primary)),
                            SizedBox(height: 30),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InvestisseurEditForm(
                                        investisseur: Investisseur(
                                          id: investisseurInfo!['id'] ??
                                              'non renseigné',
                                          email: investisseurInfo!['email']!,
                                          nom: investisseurInfo!['nom']!,
                                          prenom: investisseurInfo!['prenom']!,
                                          tel: investisseurInfo!['tel']!,
                                          address:
                                              investisseurInfo!['address']!,
                                          password:
                                              '', // Ne pas exposer le mot de passe
                                        ),
                                        image: investisseurInfo!['image'],
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit),
                                label: Text('Éditer'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Couleur.primary,
                                ),
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
  }
}
