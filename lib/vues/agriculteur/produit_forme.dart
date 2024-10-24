import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sene_mobile/models/produit.dart';
import 'package:sene_mobile/services/produit_service.dart';

class FormulaireProduit extends StatefulWidget {
  final Produit produit; // Produit à modifier

  const FormulaireProduit({Key? key, required this.produit}) : super(key: key);

  @override
  _FormulaireProduitState createState() => _FormulaireProduitState();
}

class _FormulaireProduitState extends State<FormulaireProduit> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String description;
  late double prix;
  late double quantite;
  Uint8List? imageBytes;
  final ProduitService produitService = ProduitService(); // Instance du service

  @override
  void initState() {
    super.initState();
    // Initialiser les champs avec les informations du produit
    nom = widget.produit.nom;
    description = widget.produit.description;
    prix = widget.produit.prix;
    quantite = widget.produit.quantite ?? 0.0;
    imageBytes = widget.produit.image != null
        ? base64Decode(widget.produit.image!)
        : null; // Charger l'image si disponible
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes(); // Lire les octets de l'image
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        await produitService.updateProduitWithImage(
          'produit/${widget.produit.id}',
          {
            'nom': nom,
            'description': description,
            'prix': prix,
            'quantite': quantite,
          },
          imageBytes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit mis à jour avec succès !')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Produit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: imageBytes == null
                      ? (widget.produit.image != null &&
                              widget.produit.image!.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                base64Decode(widget.produit.image!),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.image, size: 60, color: Colors.grey))
                      : ClipOval(
                          child: Image.memory(
                            imageBytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Nom', (value) {
                if (value!.isEmpty) return 'Veuillez entrer le nom du produit';
              }, (value) => nom = value!),
              _buildTextField('Description', (value) {
                if (value!.isEmpty) return 'Veuillez entrer une description';
              }, (value) => description = value!),
              _buildTextField('Prix', (value) {
                if (value!.isEmpty) return 'Veuillez entrer un prix';
              }, (value) => prix = double.tryParse(value!) ?? 0.0),
              _buildTextField('Quantité', (value) {
                if (value!.isEmpty) return 'Veuillez entrer une quantité';
              }, (value) => quantite = double.tryParse(value!) ?? 0.0),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Mettre à jour'),
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
        ),
        validator: validator,
        onSaved: onSaved,
        initialValue: label == 'Nom'
            ? nom
            : label == 'Description'
                ? description
                : label == 'Prix'
                    ? prix.toString()
                    : quantite.toString(),
      ),
    );
  }
}
