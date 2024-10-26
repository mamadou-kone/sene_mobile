import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sene_mobile/models/produit.dart';
import 'package:sene_mobile/services/produit_service.dart';
import '../../couleur.dart';

class FormulaireProduit extends StatefulWidget {
  final Produit produit;

  const FormulaireProduit({Key? key, required this.produit}) : super(key: key);

  @override
  _FormulaireProduitState createState() => _FormulaireProduitState();
}

class _FormulaireProduitState extends State<FormulaireProduit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomController;
  late TextEditingController descriptionController;
  late TextEditingController prixController;
  late TextEditingController quantiteController;
  Uint8List? imageBytes;
  final ProduitService produitService = ProduitService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.produit.nom);
    descriptionController =
        TextEditingController(text: widget.produit.description);
    prixController =
        TextEditingController(text: widget.produit.prix.toString());
    quantiteController =
        TextEditingController(text: widget.produit.quantite?.toString() ?? '0');
    imageBytes = widget.produit.image != null
        ? base64Decode(widget.produit.image!)
        : null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        await produitService.updateProduitWithImage(
          'produit/${widget.produit.id}',
          {
            'nom': nomController.text,
            'description': descriptionController.text,
            'prix': double.parse(prixController.text),
            'quantite': double.parse(quantiteController.text),
          },
          imageBytes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit mis à jour avec succès !')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    descriptionController.dispose();
    prixController.dispose();
    quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Couleur.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Modifier Produit',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                              ? (widget.produit.image != null &&
                                      widget.produit.image!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.memory(
                                        base64Decode(widget.produit.image!),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.image,
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
                        controller: nomController,
                        label: 'Nom du produit',
                        icon: Icons.title),
                    SizedBox(height: 16),
                    _buildInputField(
                        controller: descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        maxLines: 4),
                    SizedBox(height: 16),
                    _buildInputField(
                        controller: prixController,
                        label: 'Prix (FCFA)',
                        icon: Icons.money,
                        keyboardType: TextInputType.number),
                    SizedBox(height: 16),
                    _buildInputField(
                        controller: quantiteController,
                        label: 'Quantité',
                        icon: Icons.add_box,
                        keyboardType: TextInputType.number),
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
                      child: Text('Mettre à jour',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Couleur.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
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
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value!.isEmpty) return 'Ce champ est requis';
        return null;
      },
    );
  }
}
