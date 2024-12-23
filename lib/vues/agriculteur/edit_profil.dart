import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  bool _isLoading = false;

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
      setState(() => _isLoading = true);
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
          SnackBar(content: Text('Agriculteur mis à jour avec succès !')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(String label, IconData icon,
      String? Function(String?)? validator, Function(String?)? onSaved,
      {String? initialValue, bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Couleur.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text('Édition de l\'Agriculteur',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Couleur.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    image != null ? MemoryImage(image!) : null,
                                child: image == null
                                    ? (widget.image != null &&
                                            widget.image!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.memory(
                                              base64Decode(widget.image!),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(Icons.person,
                                            size: 60, color: Colors.grey))
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Couleur.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          'Nom',
                          Icons.person_outline,
                          (value) => value?.isEmpty ?? true
                              ? 'Veuillez entrer un nom'
                              : null,
                          (value) => nom = value ?? '',
                          initialValue: nom,
                        ),
                        _buildTextField(
                          'Prénom',
                          Icons.person,
                          (value) => value?.isEmpty ?? true
                              ? 'Veuillez entrer un prénom'
                              : null,
                          (value) => prenom = value ?? '',
                          initialValue: prenom,
                        ),
                        _buildTextField(
                          'Email',
                          Icons.email,
                          (value) => value?.isEmpty ?? true
                              ? 'Veuillez entrer un email'
                              : null,
                          (value) => email = value ?? '',
                          initialValue: email,
                        ),
                        _buildTextField(
                          'Téléphone',
                          Icons.phone,
                          (value) => value?.isEmpty ?? true
                              ? 'Veuillez entrer un numéro'
                              : null,
                          (value) => tel = value ?? '',
                          initialValue: tel,
                        ),
                        _buildTextField(
                          'Adresse',
                          Icons.location_on,
                          (value) => value?.isEmpty ?? true
                              ? 'Veuillez entrer une adresse'
                              : null,
                          (value) => address = value ?? '',
                          initialValue: address,
                        ),
                        _buildTextField(
                          'Mot de passe',
                          Icons.lock,
                          (value) => null,
                          (value) => password = value ?? '',
                          initialValue: password,
                          obscureText: true,
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Couleur.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save),
                                      SizedBox(width: 8),
                                      Text('Sauvegarder',
                                          style: TextStyle(fontSize: 16)),
                                    ],
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
