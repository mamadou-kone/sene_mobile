import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sene_mobile/models/projet.dart';
import 'package:sene_mobile/services/projet_service.dart';

class FormulaireProjet extends StatefulWidget {
  final Projet projet; // Projet à modifier

  const FormulaireProjet({Key? key, required this.projet}) : super(key: key);

  @override
  _FormulaireProjetState createState() => _FormulaireProjetState();
}

class _FormulaireProjetState extends State<FormulaireProjet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titreController;
  late TextEditingController descriptionController;
  late TextEditingController montantNecessaireController;
  late double montantCollecte; // Ajout de montantCollecte
  Uint8List? imageBytes;
  final ProjetService projetService = ProjetService(); // Instance du service

  @override
  void initState() {
    super.initState();
    titreController = TextEditingController(text: widget.projet.titre);
    descriptionController =
        TextEditingController(text: widget.projet.description);
    montantNecessaireController =
        TextEditingController(text: widget.projet.montantNecessaire.toString());
    montantCollecte =
        widget.projet.montantCollecte ?? 0.0; // Charger le montant collecté
    imageBytes = widget.projet.image != null && widget.projet.image!.isNotEmpty
        ? base64Decode(widget.projet.image!)
        : null; // Charger l'image si disponible
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes(); // Lire les octets de l'image
      setState(() {}); // Mettre à jour l'état avec la nouvelle image
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Imprimer les données pour débogage
      print('Données envoyées:');
      print('Titre: ${titreController.text}');
      print('Description: ${descriptionController.text}');
      print('Montant Nécessaire: ${montantNecessaireController.text}');
      print(
          'Montant Collecté: $montantCollecte'); // Afficher le montant collecté
      print('Image: ${imageBytes != null ? 'image fournie' : 'pas d\'image'}');

      try {
        await projetService.updateProjetWithImage(
          'projet/${widget.projet.id}', // Utiliser l'ID du projet à modifier
          {
            'titre': titreController.text,
            'description': descriptionController.text,
            'montantNecessaire': double.parse(montantNecessaireController.text),
            'montantCollecte': montantCollecte, // Ajouter le montant collecté
          },
          imageBytes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Projet mis à jour avec succès !')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour : ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    montantNecessaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Projet'),
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
                      ? (widget.projet.image != null &&
                              widget.projet.image!.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                base64Decode(widget.projet.image!),
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
              _buildTextField('Titre', titreController, (value) {
                if (value!.isEmpty) return 'Veuillez entrer le titre du projet';
                return null;
              }),
              _buildTextField('Description', descriptionController, (value) {
                if (value!.isEmpty) return 'Veuillez entrer une description';
                return null;
              }),
              _buildTextField('Montant Nécessaire', montantNecessaireController,
                  (value) {
                if (value!.isEmpty)
                  return 'Veuillez entrer un montant nécessaire';
                double? montant = double.tryParse(value);
                if (montant == null || montant <= 0) {
                  return 'Veuillez entrer un montant supérieur à zéro.';
                }
                return null;
              }),
              // Champ désactivé pour le montant collecté
              TextFormField(
                enabled: false,
                initialValue: montantCollecte.toString(),
                decoration: InputDecoration(
                  labelText: 'Montant Collecté',
                  border: OutlineInputBorder(),
                ),
              ),
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

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
