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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Couleur.primary,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: clientInfo == null
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
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
                              'Nom: ${clientInfo!['nom'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Prénom: ${clientInfo!['prenom'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${clientInfo!['email'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Téléphone: ${clientInfo!['tel'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Adresse: ${clientInfo!['address'] ?? 'Non renseigné'}',
                              style: TextStyle(
                                  fontSize: 24, color: Couleur.primary),
                            ),
                            SizedBox(height: 30),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClientEditForm(
                                        client: Client(
                                          id: clientInfo!['id'] ??
                                              'non renseigné',
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
