import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../couleur.dart';
import '../../models/agriculteur.dart';
import '../../models/projet.dart';
import '../../services/auth_controleur.dart';
import '../../services/projet_service.dart';

class ProjetForm extends StatefulWidget {
  @override
  _ProjetFormState createState() => _ProjetFormState();
}

class _ProjetFormState extends State<ProjetForm> {
  // Utilisation du singleton AuthController
  final authController = AuthController.instance;
  final ProjetService projetService = ProjetService();
  final _formKey = GlobalKey<FormState>();

  String titre = '';
  String description = '';
  double montantNecessaire = 0.0;
  File? image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        // Vérification que l'utilisateur est authentifié
        if (authController.currentUser == null) {
          throw Exception('Utilisateur non authentifié');
        }

        // Récupération de l'ID de l'agriculteur à partir des données de l'utilisateur connecté
        String agriculteurId = authController.currentUser!['userId'];
        print("ID de l'agriculteur: $agriculteurId");

        // Création d'un objet Projet
        Projet projet = Projet(
          titre: titre,
          description: description,
          montantNecessaire: montantNecessaire,
          statut: true,
          agriculteur: {
            'id': agriculteurId,
          }, // Utilisation de l'ID de l'agriculteur
        );

        // Appel au service pour créer le projet
        await projetService.create('projet', projet.toJson(), image: image);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Projet créé avec succès !')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Projet'),
        backgroundColor: Couleur.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations du Projet',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Couleur.primary)),
              SizedBox(height: 20),
              _buildTextField('Titre', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un titre';
              }, (value) => titre = value ?? ''),
              _buildTextField('Description', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer une description';
              }, (value) => description = value ?? ''),
              _buildTextField('Montant Nécessaire', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un montant';
                if (double.tryParse(value!) == null)
                  return 'Veuillez entrer un nombre valide';
              }, (value) {
                montantNecessaire = double.tryParse(value!) ?? 0.0;
              }),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: image == null
                      ? Icon(Icons.add_a_photo,
                          size: 50, color: Couleur.primary)
                      : ClipOval(
                          child: Image.file(
                            image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Couleur.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Créer Projet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? Function(String?)? validator,
      Function(String?)? onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Couleur.primary, width: 2.0),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
        keyboardType: label == 'Montant Nécessaire'
            ? TextInputType.number
            : TextInputType.text,
      ),
    );
  }
}
