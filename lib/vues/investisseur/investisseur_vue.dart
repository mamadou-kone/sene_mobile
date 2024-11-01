import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sene_mobile/couleur.dart';
import '../../models/investisseur.dart';
import '../../controleur/investisseur_controleur.dart';

class InvestisseurForm extends StatefulWidget {
  @override
  _InvestisseurFormState createState() => _InvestisseurFormState();
}

class _InvestisseurFormState extends State<InvestisseurForm> {
  final _formKey = GlobalKey<FormState>();
  final InvestisseurController _controller = InvestisseurController();
  bool _isLoading = false; // Loading state

  String email = '';
  String nom = '';
  String prenom = '';
  String address = '';
  String tel = '';
  String password = '';
  File? image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      _formKey.currentState?.save();

      try {
        Investisseur investisseur = Investisseur(
          email: email,
          nom: nom,
          prenom: prenom,
          address: address,
          tel: tel,
          password: password,
        );

        await _controller.addInvestisseur(investisseur, image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Investisseur créé avec succès !'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Navigate back after success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Erreur : $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text('Créer un Investisseur'),
        backgroundColor: Couleur.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Couleur.primary,
              height: 100,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -50,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 32, color: Couleur.primary),
                                    SizedBox(height: 4),
                                    Text(
                                      'Photo',
                                      style: TextStyle(
                                        color: Couleur.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
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
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations de l\'investisseur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Couleur.primary,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              'Email',
                              Icons.email_outlined,
                              (value) => value?.isEmpty ?? true
                                  ? 'Veuillez entrer un email'
                                  : null,
                              (value) => email = value ?? '',
                            ),
                            _buildTextField(
                              'Nom',
                              Icons.person_outline,
                              (value) => value?.isEmpty ?? true
                                  ? 'Veuillez entrer un nom'
                                  : null,
                              (value) => nom = value ?? '',
                            ),
                            _buildTextField(
                              'Prénom',
                              Icons.person_outline,
                              (value) => value?.isEmpty ?? true
                                  ? 'Veuillez entrer un prénom'
                                  : null,
                              (value) => prenom = value ?? '',
                            ),
                            _buildTextField(
                              'Adresse',
                              Icons.location_on_outlined,
                              (value) => value?.isEmpty ?? true
                                  ? 'Veuillez entrer une adresse'
                                  : null,
                              (value) => address = value ?? '',
                            ),
                            _buildTextField(
                              'Téléphone',
                              Icons.phone_outlined,
                              (value) => value?.isEmpty ?? true
                                  ? 'Veuillez entrer un numéro'
                                  : null,
                              (value) => tel = value ?? '',
                            ),
                            _buildTextField(
                              'Mot de passe',
                              Icons.lock_outline,
                              (value) => value?.isEmpty ?? true
                                  ? 'Veuillez entrer un mot de passe'
                                  : null,
                              (value) => password = value ?? '',
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Couleur.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Créer l\'investisseur',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    String? Function(String?)? validator,
    Function(String?)? onSaved, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Couleur.primary),
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
