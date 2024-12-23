import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sene_mobile/services/auth_controleur.dart';
import '../../couleur.dart';
import '../../models/projet.dart';
import '../../models/investissement.dart';
import '../../services/ivestissement_service.dart';

class FinancierPage extends StatefulWidget {
  final Projet projet;
  const FinancierPage({Key? key, required this.projet}) : super(key: key);

  @override
  _FinancierPageState createState() => _FinancierPageState();
}

class _FinancierPageState extends State<FinancierPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montantController = TextEditingController();
  AuthController authController = AuthController.instance;
  bool _isLoading = false;

  // Calculer le montant restant
  double getMontantRestant() {
    double montantCollecte = widget.projet.montantCollecte ?? 0.0;
    return widget.projet.montantNecessaire - montantCollecte;
  }

// Ajouter la méthode submitInvestment qui manquait
  Future<void> submitInvestment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final montant = double.tryParse(_montantController.text);
      if (montant != null) {
        try {
          final investissement = Investissement(
            montant: montant,
            investisseurId: authController.currentUser!['userId'].toString(),
            projetId: widget.projet.id.toString(),
          );

          await InvestissementService().investir(investissement);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Investissement réussi !')),
            );
            Navigator.pop(context);
          }
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Erreur lors de l\'investissement : $error')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Montant invalide')),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  } // ... le reste de vos méthodes existantes ...

  @override
  Widget build(BuildContext context) {
    double montantRestant = getMontantRestant();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projet.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du projet
            if (widget.projet.image != null)
              Card(
                elevation: 4,
                child: Image.memory(
                  base64Decode(widget.projet.image!),
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            SizedBox(height: 16),

            // Informations financières
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Montant nécessaire
                    ListTile(
                      title: Text(
                        'Montant Nécessaire',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${widget.projet.montantNecessaire} FCFA',
                        style: TextStyle(
                          fontSize: 15,
                          color: Couleur.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),

                    // Montant collecté
                    ListTile(
                      title: Text(
                        'Montant Collecté',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${widget.projet.montantCollecte ?? 0.0} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),

                    // Montant restant
                    ListTile(
                      title: Text(
                        'Montant Restant',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '$montantRestant FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Description
            Text(
              widget.projet.description ?? 'Pas de description disponible.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Formulaire d'investissement
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _montantController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Entrez le montant à investir',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      final montant = double.tryParse(value);
                      if (montant == null || montant <= 0) {
                        return 'Veuillez entrer un montant valide';
                      }
                      if (montant > montantRestant) {
                        return 'Le montant ne peut pas dépasser $montantRestant FCFA';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: submitInvestment,
                          icon: Icon(Icons.attach_money, color: Colors.white),
                          label: Text(
                            'Investir',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Couleur.primary,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
