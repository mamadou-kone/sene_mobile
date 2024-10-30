import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../../config.dart';
import '../../models/investissement.dart';
import '../../couleur.dart';

class MesInvestissement extends StatelessWidget {
  final String userId;

  MesInvestissement({required this.userId});

  Future<List<Map<String, dynamic>>> getInvestissementsByUser(
      String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/investissement/investisseur/$userId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          return List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey('investissements')) {
          return List<Map<String, dynamic>>.from(jsonData['investissements']);
        }
        throw Exception('Format JSON inattendu');
      }
      throw Exception('Erreur de récupération : ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Couleur.primary,
        title: Center(
          child: Text(
            'Mes Investissements',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Implémenter le filtrage ici
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getInvestissementsByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun investissement trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final investissements = snapshot.data!;
          double totalInvestissement = investissements.fold(
            0,
            (sum, item) =>
                sum + (double.tryParse(item['montant'].toString()) ?? 0),
          );

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Couleur.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total des investissements',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${totalInvestissement.toStringAsFixed(2)} FCFA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: investissements.length,
                  itemBuilder: (context, index) {
                    final investissement = investissements[index];
                    final projetImageBase64 =
                        investissement['projet']?['image'] as String?;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          // Navigation vers les détails
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'projet_${investissement['projet']['id']}',
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: projetImageBase64 != null &&
                                            projetImageBase64.isNotEmpty
                                        ? DecorationImage(
                                            image: MemoryImage(base64Decode(
                                                projetImageBase64)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.grey[200],
                                  ),
                                  child: projetImageBase64 == null ||
                                          projetImageBase64.isEmpty
                                      ? Icon(Icons.business,
                                          size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      investissement['projet']['titre'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        SizedBox(width: 4),
                                        Text(
                                          '${investissement['montant']} FCFA',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Couleur.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  color: Couleur.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
