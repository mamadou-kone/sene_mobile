import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../couleur.dart';
import '../../models/produit.dart'; // Modèle produit
import '../../services/auth_controleur.dart'; // Contrôleur d'authentification
import '../../services/produit_service.dart'; // Service produit

class ProduitForm extends StatefulWidget {
  @override
  _ProduitFormState createState() => _ProduitFormState();
}

class _ProduitFormState extends State<ProduitForm> {
  // Utilisation du singleton AuthController
  final authController = AuthController.instance;
  final ProduitService produitService = ProduitService();
  final _formKey = GlobalKey<FormState>();

  String nom = '';
  String description = '';
  double prix = 0.0;
  double? quantite;
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

        // Création d'un objet Produit
        Produit produit = Produit(
          nom: nom,
          description: description,
          prix: prix,
          quantite: quantite,
          statut: true,
          agriculteur: {
            'id': agriculteurId,
          }, // Utilisation de l'ID de l'agriculteur
        );

        // Appel au service pour créer le produit
        await produitService.create('produit', produit.toJson(), image: image);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit créé avec succès !')));
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
        title: Text('Créer un Produit'),
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
              Text('Informations du Produit',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Couleur.primary)),
              SizedBox(height: 20),
              _buildTextField('Nom', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un nom';
              }, (value) => nom = value ?? ''),
              _buildTextField('Description', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer une description';
              }, (value) => description = value ?? ''),
              _buildTextField('Prix', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un prix';
                if (double.tryParse(value!) == null)
                  return 'Veuillez entrer un nombre valide';
              }, (value) {
                prix = double.tryParse(value!) ?? 0.0;
              }),
              _buildTextField('Quantité (optionnel)', null, (value) {
                quantite = double.tryParse(value ?? '');
              }, isOptional: true),
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
                  child: Text('Créer Produit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? Function(String?)? validator,
      Function(String?)? onSaved,
      {bool isOptional = false}) {
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
        keyboardType: label == 'Prix' || label == 'Quantité'
            ? TextInputType.number
            : TextInputType.text,
      ),
    );
  }
}
