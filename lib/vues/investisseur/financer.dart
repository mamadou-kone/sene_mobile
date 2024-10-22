import 'dart:convert'; // Pour utiliser base64Decode
import 'package:flutter/material.dart';
import 'package:sene_mobile/services/auth_controleur.dart';
import '../../couleur.dart';
import '../../models/projet.dart'; // Modèle Projet
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

  Future<void> _submitInvestment() async {
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

          // Affichage des données dans le terminal
          print('Données de l\'investissement :');
          print('Montant: ${investissement.montant}');
          print('Date d\'investissement: ${investissement.dateInvestissement}');
          print('ID de l\'investisseur: ${investissement.investisseurId}');
          print('ID du projet: ${investissement.projetId}');

          await InvestissementService().investir(investissement);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Investissement réussi !')),
          );

          // Retour à la page précédente
          Navigator.pop(context);
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors de l\'investissement : $error')),
          );
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projet.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afficher l'image du projet
            widget.projet.image != null
                ? Card(
                    elevation: 4,
                    child: Image.memory(
                      base64Decode(widget.projet.image!),
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  )
                : Container(),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                title: Text(
                  'Montant Nécessaire',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '\$${widget.projet.montantNecessaire}',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 16),
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
                      if (montant > widget.projet.montantNecessaire) {
                        return 'Le montant ne peut pas dépasser ${widget.projet.montantNecessaire}';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _submitInvestment,
                          label: Text(
                            'Investir',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Couleur.primary,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
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
