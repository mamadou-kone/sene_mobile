import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controleur/investisseur_controleur.dart';
import '../../models/investisseur.dart';
import '../../couleur.dart';

class InvestisseurEditForm extends StatefulWidget {
  final Investisseur investisseur;
  final String? image;

  InvestisseurEditForm({required this.investisseur, this.image});

  @override
  _InvestisseurEditFormState createState() => _InvestisseurEditFormState();
}

class _InvestisseurEditFormState extends State<InvestisseurEditForm> {
  final _formKey = GlobalKey<FormState>();
  final InvestisseurController _controller = InvestisseurController();

  late String email;
  late String nom;
  late String prenom;
  late String address;
  late String tel;
  String? password;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    email = widget.investisseur.email;
    nom = widget.investisseur.nom;
    prenom = widget.investisseur.prenom;
    address = widget.investisseur.address;
    tel = widget.investisseur.tel;

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
        Investisseur updatedInvestisseur = Investisseur(
          id: widget.investisseur.id,
          email: email,
          nom: nom,
          prenom: prenom,
          tel: tel,
          address: address,
          password: password ?? widget.investisseur.password,
        );

        await _controller.updateInvestisseur(
            widget.investisseur.id, updatedInvestisseur, image);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Investisseur mis à jour avec succès !')));
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
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Édition de l\'investisseur',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null ? MemoryImage(image!) : null,
                    child: image == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Nom', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un nom';
              }, (value) => nom = value ?? '', initialValue: nom),
              _buildTextField('Prénom', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un prénom';
              }, (value) => prenom = value ?? '', initialValue: prenom),
              _buildTextField('Email', (value) {
                if (value?.isEmpty ?? true) return 'Veuillez entrer un email';
              }, (value) => email = value ?? '', initialValue: email),
              _buildTextField('Téléphone', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer un numéro de téléphone';
              }, (value) => tel = value ?? '', initialValue: tel),
              _buildTextField('Adresse', (value) {
                if (value?.isEmpty ?? true)
                  return 'Veuillez entrer une adresse';
              }, (value) => address = value ?? '', initialValue: address),
              _buildTextField(
                  'Mot de passe', (value) {}, (value) => password = value ?? '',
                  initialValue: password),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Couleur.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Sauvegarder'),
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
      {String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
