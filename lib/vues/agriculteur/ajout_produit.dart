import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../couleur.dart';
import '../../models/produit.dart';
import '../../services/auth_controleur.dart';
import '../../services/produit_service.dart';

class ProduitForm extends StatefulWidget {
  @override
  _ProduitFormState createState() => _ProduitFormState();
}

class _ProduitFormState extends State<ProduitForm> {
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
        if (authController.currentUser == null) {
          throw Exception('Utilisateur non authentifié');
        }

        String agriculteurId = authController.currentUser!['userId'];

        Produit produit = Produit(
          nom: nom,
          description: description,
          prix: prix,
          quantite: quantite,
          statut: true,
          agriculteur: {'id': agriculteurId},
        );

        await produitService.create('produit', produit.toJson(), image: image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit créé avec succès !'),
            backgroundColor: Couleur.secondary,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Créer un Produit',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Couleur.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Couleur.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 40, color: Couleur.primary),
                                SizedBox(height: 5),
                                Text(
                                  'Ajouter une photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Couleur.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : ClipOval(
                              child: Image.file(
                                image!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildTextField(
                            'Nom du produit',
                            Icons.shopping_basket,
                            (value) {
                              if (value?.isEmpty ?? true)
                                return 'Veuillez entrer un nom';
                              return null;
                            },
                            (value) => nom = value ?? '',
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            'Description',
                            Icons.description,
                            (value) {
                              if (value?.isEmpty ?? true)
                                return 'Veuillez entrer une description';
                              return null;
                            },
                            (value) => description = value ?? '',
                            maxLines: 3,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            'Prix (FCFA)',
                            Icons.attach_money,
                            (value) {
                              if (value?.isEmpty ?? true)
                                return 'Veuillez entrer un prix';
                              if (double.tryParse(value!) == null)
                                return 'Veuillez entrer un nombre valide';
                              return null;
                            },
                            (value) {
                              prix = double.tryParse(value!) ?? 0.0;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            'Quantité',
                            Icons.inventory,
                            null,
                            (value) {
                              quantite = double.tryParse(value ?? '');
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Couleur.primary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Créer le produit',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    String? Function(String?)? validator,
    Function(String?)? onSaved, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Couleur.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Couleur.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      onSaved: onSaved,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
