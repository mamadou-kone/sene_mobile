import 'dart:convert';
import 'package:flutter/material.dart';
import '../../controleur/agriculture_controleur.dart';
import '../../couleur.dart';
import '../../models/agriculteur.dart';
import 'edit_profil.dart';

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
      setState(() {});
    } catch (e) {
      print('Erreur de chargement des informations : $e');
    }
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Couleur.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconForTitle(title), color: Couleur.primary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 4),
                Text(value ?? 'Non renseigné',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'nom':
        return Icons.person;
      case 'prénom':
        return Icons.person_outline;
      case 'email':
        return Icons.email;
      case 'téléphone':
        return Icons.phone;
      case 'adresse':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
        centerTitle: true,
      ),
      body: agriculteurInfo == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Couleur.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 30),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                agriculteurInfo!['image'] != null &&
                                        agriculteurInfo!['image'].isNotEmpty
                                    ? MemoryImage(
                                        base64Decode(agriculteurInfo!['image']))
                                    : null,
                            child: agriculteurInfo!['image'] == null ||
                                    agriculteurInfo!['image'].isEmpty
                                ? Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoCard('Nom', agriculteurInfo!['nom']),
                        _buildInfoCard('Prénom', agriculteurInfo!['prenom']),
                        _buildInfoCard('Email', agriculteurInfo!['email']),
                        _buildInfoCard('Téléphone', agriculteurInfo!['tel']),
                        _buildInfoCard('Adresse', agriculteurInfo!['address']),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
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
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
