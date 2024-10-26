import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sene_mobile/models/projet.dart';
import 'package:sene_mobile/services/projet_service.dart';
import '../../couleur.dart';

class FormulaireProjet extends StatefulWidget {
  final Projet projet;

  const FormulaireProjet({Key? key, required this.projet}) : super(key: key);

  @override
  _FormulaireProjetState createState() => _FormulaireProjetState();
}

class _FormulaireProjetState extends State<FormulaireProjet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titreController;
  late TextEditingController descriptionController;
  late TextEditingController montantNecessaireController;
  late double montantCollecte;
  Uint8List? imageBytes;
  final ProjetService projetService = ProjetService();
  bool _isLoading = false;

  // FocusNodes pour chaque champ de saisie
  final FocusNode _titreFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _montantNecessaireFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titreController = TextEditingController(text: widget.projet.titre);
    descriptionController =
        TextEditingController(text: widget.projet.description);
    montantNecessaireController =
        TextEditingController(text: widget.projet.montantNecessaire.toString());
    montantCollecte = widget.projet.montantCollecte ?? 0.0;
    imageBytes = widget.projet.image != null && widget.projet.image!.isNotEmpty
        ? base64Decode(widget.projet.image!)
        : null;

    // Écoutez les changements de focus
    _titreFocusNode.addListener(() {
      setState(() {});
    });
    _descriptionFocusNode.addListener(() {
      setState(() {});
    });
    _montantNecessaireFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await projetService.updateProjetWithImage(
          'projet/${widget.projet.id}',
          {
            'titre': titreController.text,
            'description': descriptionController.text,
            'montantNecessaire': double.parse(montantNecessaireController.text),
            'montantCollecte': montantCollecte,
          },
          imageBytes,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Projet mis à jour avec succès !'),
              ],
            ),
            backgroundColor: Couleur.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Erreur: ${e.toString()}')),
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
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    montantNecessaireController.dispose();
    _titreFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _montantNecessaireFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Couleur.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Modifier le Projet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
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
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: imageBytes == null
                              ? (widget.projet.image != null &&
                                      widget.projet.image!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.memory(
                                        base64Decode(widget.projet.image!),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.business,
                                      size: 60, color: Couleur.primary))
                              : ClipOval(
                                  child: Image.memory(
                                    imageBytes!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Couleur.primary, width: 2),
                            ),
                            child: Icon(Icons.camera_alt,
                                size: 20, color: Couleur.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      controller: titreController,
                      label: 'Titre du projet',
                      icon: Icons.title,
                      focusNode: _titreFocusNode,
                      validator: (value) =>
                          value!.isEmpty ? 'Le titre est requis' : null,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      controller: descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      focusNode: _descriptionFocusNode,
                      maxLines: 4,
                      validator: (value) =>
                          value!.isEmpty ? 'La description est requise' : null,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      controller: montantNecessaireController,
                      label: 'Montant nécessaire (FCFA)',
                      icon: Icons.money,
                      focusNode: _montantNecessaireFocusNode,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Le montant est requis';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Veuillez entrer un montant valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.savings, color: Couleur.primary),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Montant collecté',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${montantCollecte.toStringAsFixed(2)} FCFA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Couleur.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Couleur.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Mettre à jour le projet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    Color fillColor = focusNode.hasFocus
        ? Couleur.primary.withOpacity(0.1)
        : Colors.grey[50]!;
    Color cursorColor = Couleur.primary;
    Color labelColor = focusNode.hasFocus ? Couleur.primary : Colors.grey;
    Color borderColor =
        focusNode.hasFocus ? Couleur.primary : Colors.grey[300]!;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: Icon(icon, color: Couleur.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Couleur.primary),
        ),
        filled: true,
        fillColor: fillColor,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: cursorColor,
    );
  }
}
