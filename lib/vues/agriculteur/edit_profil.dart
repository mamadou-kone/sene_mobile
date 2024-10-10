import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/agriculteur.dart';
import '../../controleur/agriculture_controleur.dart';
import '../../couleur.dart';

class AgriculteurEditForm extends StatefulWidget {
  final Agriculteur agriculteur;
  final String? image;

  AgriculteurEditForm({required this.agriculteur, this.image});

  @override
  _AgriculteurEditFormState createState() => _AgriculteurEditFormState();
}

class _AgriculteurEditFormState extends State<AgriculteurEditForm> {
  final _formKey = GlobalKey<FormState>();
  final AgriculteurController _controller = AgriculteurController();

  late String email;
  late String nom;
  late String prenom;
  late String address;
  late String tel;
  late String password;
  Uint8List? image; // Utiliser Uint8List pour l'image

  @override
  void initState() {
    super.initState();
    email = widget.agriculteur.email;
    nom = widget.agriculteur.nom;
    prenom = widget.agriculteur.prenom;
    address = widget.agriculteur.address;
    tel = widget.agriculteur.tel;
    password = widget.agriculteur.password;

    // Décoder l'image base64
    if (widget.image != null && widget.image!.isNotEmpty) {
      image = base64Decode(widget.image!);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path)
            .readAsBytesSync(); // Lire les octets de l'image
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        Agriculteur agriculteur = Agriculteur(
          id: widget.agriculteur.id,
          email: email,
          nom: nom,
          prenom: prenom,
          address: address,
          tel: tel,
          password: password, // Ne pas exposer le mot de passe
        );

        await _controller.updateAgriculteur(
            widget.agriculteur.id, agriculteur, image);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Agriculteur mis à jour avec succès !')));
        Navigator.pop(context);
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
        title: Text('Modifier Agriculteur'),
        backgroundColor: Couleur.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Affichage de l'image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: image == null
                      ? (widget.image != null && widget.image!.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                base64Decode(widget.image!), // Afficher l'image
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.person, size: 60, color: Colors.grey))
                      : ClipOval(
                          child: Image.memory(
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
                  child: Text('Mettre à jour'),
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
        initialValue: label == 'Email'
            ? email
            : label == 'Nom'
                ? nom
                : label == 'Prénom'
                    ? prenom
                    : label == 'Adresse'
                        ? address
                        : label == 'Téléphone'
                            ? tel
                            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
        onSaved: onSaved,
        obscureText: obscureText,
      ),
    );
  }
}
