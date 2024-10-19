import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Importer Uint8List
import 'package:http/http.dart' as http;
import '../../config.dart';

class ClientService {
  Future<void> create(String endpoint, Map<String, dynamic> data,
      {File? image}) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('${Config.baseUrl}/$endpoint'));

    request.fields['client'] = jsonEncode(data);

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

  Future<void> updateWithImage(
      String endpoint, Map<String, dynamic> data, Uint8List imageBytes) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('${Config.baseUrl}/$endpoint'));

    request.fields['client'] = jsonEncode(data);

    if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: 'image.jpg'));
    }

    final streamedResponse = await request.send();
    await _handleStreamedResponse(streamedResponse);
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
          'Erreur lors de la communication avec l\'API: ${response.statusCode}');
    }
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Erreur lors de la communication avec l\'API: ${response.statusCode}');
    }
  }
}
