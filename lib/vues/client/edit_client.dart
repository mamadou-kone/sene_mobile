import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controleur/client_controleur.dart';
import '../../models/client.dart';
import '../../couleur.dart';

class ClientEditForm extends StatefulWidget {
  final Client client;
  final String? image;

  const ClientEditForm({required this.client, this.image, Key? key})
      : super(key: key);

  @override
  _ClientEditFormState createState() => _ClientEditFormState();
}

class _ClientEditFormState extends State<ClientEditForm> {
  final _formKey = GlobalKey<FormState>();
  final ClientController _controller = ClientController();

  late String email;
  late String nom;
  late String prenom;
  late String address;
  late String tel;
  String? password;
  Uint8List? image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    email = widget.client.email;
    nom = widget.client.nom;
    prenom = widget.client.prenom;
    address = widget.client.address;
    tel = widget.client.tel;

    if (widget.image?.isNotEmpty ?? false) {
      image = base64Decode(widget.image!);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path).readAsBytesSync();
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      _formKey.currentState?.save();
      try {
        final updatedClient = Client(
          id: widget.client.id,
          email: email,
          nom: nom,
          prenom: prenom,
          tel: tel,
          address: address,
          password: password ?? widget.client.password,
        );

        await _controller.updateClient(widget.client.id, updatedClient, image);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client mis à jour avec succès !')),
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
      String? Function(String?)? validator, void Function(String?)? onSaved,
      {String? initialValue, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        title: const Text('Édition du client',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.primary,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
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
                                      : const Icon(Icons.person,
                                          size: 60, color: Colors.grey))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
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
                      const SizedBox(height: 30),
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
                          (value) => password = value,
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Couleur.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.save, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Sauvegarder',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
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
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
