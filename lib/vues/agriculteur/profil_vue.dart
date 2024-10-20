import 'dart:convert';
import 'package:flutter/material.dart';
import '../../controleur/agriculture_controleur.dart';
import '../../couleur.dart';
import '../../models/agriculteur.dart';
import 'edit_profil.dart'; // Assurez-vous d'importer votre page d'édition

class ProfilPage extends StatefulWidget {
  final String userId;

  ProfilPage({required this.userId});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? agriculteurInfo;
  final AgriculteurController agriculteurController = AgriculteurController();

  @override
  void initState() {
    super.initState();
    _fetchAgriculteurInfo();
  }

  Future<void> _fetchAgriculteurInfo() async {
    try {
      agriculteurInfo =
          await agriculteurController.fetchAgriculteurInfo(widget.userId);
      print('Infos agriculteur: $agriculteurInfo'); // Debug
      setState(() {});
    } catch (e) {
      print('Erreur de chargement des informations : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
      ),
      body: Center(
        child: agriculteurInfo == null
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: agriculteurInfo!['image'] != null &&
                              agriculteurInfo!['image'].isNotEmpty
                          ? MemoryImage(base64Decode(agriculteurInfo!['image']))
                          : null,
                      child: agriculteurInfo == null ||
                              agriculteurInfo!['image'] == null ||
                              agriculteurInfo!['image'].isEmpty
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
                              'Nom: ${agriculteurInfo!['nom'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary)),
                          SizedBox(height: 8),
                          Text(
                              'Prénom: ${agriculteurInfo!['prenom'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary)),
                          SizedBox(height: 8),
                          Text('Email: ${agriculteurInfo!['email']}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary)),
                          SizedBox(height: 8),
                          Text(
                              'Adresse: ${agriculteurInfo!['address'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary)),
                          SizedBox(height: 8),
                          Text(
                              'Téléphone: ${agriculteurInfo!['tel'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary)),
                          SizedBox(height: 30),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgriculteurEditForm(
                                      agriculteur: Agriculteur(
                                        id: widget.userId,
                                        nom: agriculteurInfo!['nom'],
                                        prenom: agriculteurInfo!['prenom'],
                                        email: agriculteurInfo!['email'],
                                        address: agriculteurInfo!['address'],
                                        tel: agriculteurInfo!['tel'],
                                        password:
                                            '', // Ne pas exposer le mot de passe
                                      ),
                                      image: agriculteurInfo!['image'],
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
    );
  }
}
