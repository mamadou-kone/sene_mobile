import 'dart:convert';
import 'package:flutter/material.dart';
import '../../controleur/client_controleur.dart';
import '../../models/client.dart';
import '../../services/auth_controleur.dart';
import '../../couleur.dart'; // Assurez-vous que ce fichier existe pour Couleur.primary
import 'edit_client.dart';

class ClientProfilePage extends StatefulWidget {
  @override
  _ClientProfilePageState createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final ClientController clientController = ClientController();
  Map<String, dynamic>? clientInfo;

  @override
  void initState() {
    super.initState();
    _fetchClientInfo();
  }

  Future<void> _fetchClientInfo() async {
    final userId = AuthController.instance.userId;
    if (userId != null) {
      try {
        clientInfo = await clientController.fetchClientInfo(userId);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération des informations'),
          ),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: Text('Déconnexion'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                clientController.logout(context); // Déconnecte l'utilisateur
              },
            ),
          ],
        );
      },
    );
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
                Text(value.isNotEmpty ? value : 'Non renseigné',
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
        automaticallyImplyLeading: false,
        title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _confirmLogout, // Appelle la fonction de confirmation
          ),
        ],
      ),
      body: clientInfo == null
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
                      child: Hero(
                        tag: 'client_profile_image', // Unique tag
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: clientInfo!['image'] != null &&
                                  clientInfo!['image'].isNotEmpty
                              ? MemoryImage(base64Decode(clientInfo!['image']))
                              : null,
                          child: clientInfo!['image'] == null ||
                                  clientInfo!['image'].isEmpty
                              ? Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoCard('Nom', clientInfo!['nom'] ?? ''),
                        _buildInfoCard('Prénom', clientInfo!['prenom'] ?? ''),
                        _buildInfoCard('Email', clientInfo!['email'] ?? ''),
                        _buildInfoCard('Téléphone', clientInfo!['tel'] ?? ''),
                        _buildInfoCard('Adresse', clientInfo!['address'] ?? ''),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientEditForm(
                                    client: Client(
                                      id: clientInfo!['id'] ?? 'non renseigné',
                                      email: clientInfo!['email']!,
                                      nom: clientInfo!['nom']!,
                                      prenom: clientInfo!['prenom']!,
                                      tel: clientInfo!['tel']!,
                                      address: clientInfo!['address']!,
                                      password:
                                          '', // Ne pas exposer le mot de passe
                                    ),
                                    image: clientInfo!['image'],
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
