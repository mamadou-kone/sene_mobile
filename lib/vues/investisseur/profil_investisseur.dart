import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../controleur/investisseur_controleur.dart';
import '../../couleur.dart';
import '../../models/investisseur.dart';
import '../../services/auth_controleur.dart';
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
            child: Icon(
              _getIconForTitle(title),
              color: Couleur.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value ?? 'Non renseigné',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: investisseurInfo == null
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
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: investisseurInfo!['image'] !=
                                          null &&
                                      investisseurInfo!['image'].isNotEmpty
                                  ? MemoryImage(
                                      base64Decode(investisseurInfo!['image']))
                                  : null,
                              child: investisseurInfo!['image'] == null ||
                                      investisseurInfo!['image'].isEmpty
                                  ? Icon(Icons.person,
                                      size: 60, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoCard('Nom', investisseurInfo!['nom']),
                        _buildInfoCard('Prénom', investisseurInfo!['prenom']),
                        _buildInfoCard('Email', investisseurInfo!['email']),
                        _buildInfoCard('Téléphone', investisseurInfo!['tel']),
                        _buildInfoCard('Adresse', investisseurInfo!['address']),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InvestisseurEditForm(
                                    investisseur: Investisseur(
                                      id: investisseurInfo!['id'] ??
                                          'non renseigné',
                                      email: investisseurInfo!['email']!,
                                      nom: investisseurInfo!['nom']!,
                                      prenom: investisseurInfo!['prenom']!,
                                      tel: investisseurInfo!['tel']!,
                                      address: investisseurInfo!['address']!,
                                      password: '',
                                    ),
                                    image: investisseurInfo!['image'],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Modifier le profil'),
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
