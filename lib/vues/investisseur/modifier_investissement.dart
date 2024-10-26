import 'package:flutter/material.dart';
import '../../models/investissement.dart';
import '../../services/ivestissement_service.dart';

class ModifierInvestissementPage extends StatefulWidget {
  final Investissement investissement;

  const ModifierInvestissementPage({Key? key, required this.investissement})
      : super(key: key);

  @override
  _ModifierInvestissementPageState createState() =>
      _ModifierInvestissementPageState();
}

class _ModifierInvestissementPageState
    extends State<ModifierInvestissementPage> {
  final InvestissementService _investissementService = InvestissementService();
  final _formKey = GlobalKey<FormState>();
  late double _montant;

  @override
  void initState() {
    super.initState();
    _montant = widget.investissement
        .montant; // Initialiser le montant avec la valeur existante
  }

  void _modifierInvestissement() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Enregistrer le montant

      // Créer un nouvel objet Investissement avec le montant modifié
      Investissement updatedInvestissement = Investissement(
        montant: _montant,
        dateInvestissement: widget.investissement.dateInvestissement,
        investisseurId: widget.investissement.investisseurId,
        projetId: widget.investissement.projetId,
      );

      try {
        await _investissementService.investir(
            updatedInvestissement); // Appeler le service pour mettre à jour
        Navigator.pop(context); // Retourner à la page précédente
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Investissement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _montant.toString(),
                decoration: InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  return null; // Aucune erreur
                },
                onSaved: (value) {
                  if (value != null) {
                    _montant = double.tryParse(value) ?? _montant;
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _modifierInvestissement,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
