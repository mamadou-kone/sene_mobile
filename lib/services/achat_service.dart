import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/investissement.dart';
import '../config.dart';

class AchatService {
  Future<void> achat(Investissement investissement) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/investissement'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(investissement.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'investissement');
    }
  }

  Future<List<Investissement>> getAllInvestissements() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/investissement'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((invest) => Investissement.fromJson(invest))
          .toList();
    } else {
      throw Exception('Erreur lors de la récupération des investissements');
    }
  }
}
