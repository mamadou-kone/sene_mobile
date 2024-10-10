import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../config.dart';

class ClientService {
  ClientService();

  Future<void> create(String endpoint, Map<String, dynamic> data,
      {File? image}) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('${Config.baseUrl}/$endpoint'));

    // Envoyer les données sous forme de JSON
    request.fields['client'] =
        jsonEncode(data); // Envoyer les données du client

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    await _handleStreamedResponse(streamedResponse);
  }

  Future<dynamic> read(String endpoint) async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/$endpoint'));
    return _handleResponse(response);
  }

  Future<void> update(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    await _handleResponse(response);
  }

  Future<void> delete(String endpoint) async {
    final response =
        await http.delete(Uri.parse('${Config.baseUrl}/$endpoint'));
    await _handleResponse(response);
  }

  Future<void> _handleStreamedResponse(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(
          'Erreur lors de la communication avec l\'API: ${response.statusCode}, réponse: $responseBody');
    }
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Erreur lors de la communication avec l\'API: ${response.statusCode}, réponse: ${response.body}');
    }
  }
}