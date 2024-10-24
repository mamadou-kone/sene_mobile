import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sene_mobile/couleur.dart'; // Assurez-vous que ce chemin est correct
import '../../models/agriculteur.dart';
import '../../controleur/agriculture_controleur.dart';

class AgriculteurForm extends StatefulWidget {
  @override
  _AgriculteurFormState createState() => _AgriculteurFormState();
}

class _AgriculteurFormState extends State<AgriculteurForm> {
  final _formKey = GlobalKey<FormState>();
  final AgriculteurController _controller = AgriculteurController();

  String email = '';
  String nom = '';
  String prenom = '';
  String address = '';
  String tel = '';
  String password = '';
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
        // Générer un ID unique (ici basé sur la date/heure, mais tu peux utiliser un UUID)
        String id = DateTime.now().millisecondsSinceEpoch.toString();

        Agriculteur agriculteur = Agriculteur(
          id: id, // Inclure l'identifiant
          email: email,
          nom: nom,
          prenom: prenom,
          address: address,
          tel: tel,
          password: password,
        );

        await _controller.addAgriculteur(agriculteur, image);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Agriculteur créé avec succès !')));
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
        title: Text('Créer un Agriculteur'),
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
              Text(
                'Informations de l\'agriculteur',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Couleur.primary),
              ),
              SizedBox(height: 20),
              _buildTextField('Email', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un email';
              }, (value) => email = value ?? ''),
              _buildTextField('Nom', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un nom';
              }, (value) => nom = value ?? ''),
              _buildTextField('Prénom', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un prénom';
              }, (value) => prenom = value ?? ''),
              _buildTextField('Adresse', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer une adresse';
              }, (value) => address = value ?? ''),
              _buildTextField('Téléphone', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer un numéro de téléphone';
              }, (value) => tel = value ?? ''),
              _buildTextField('Mot de passe', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer un mot de passe';
              }, (value) => password = value ?? '', obscureText: true),
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
                  child: Text('Créer Agriculteur'),
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
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Couleur.primary, width: 2.0),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
        validator: validator,
        onSaved: onSaved,
        obscureText: obscureText,
      ),
    );
  }
}
