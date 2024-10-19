import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Importer Uint8List
import '../config.dart';
import '../models/client.dart';
import '../services/crud/client_service.dart';
import 'package:http/http.dart' as http;

class ClientController {
  final ClientService _crudService;

  ClientController() : _crudService = ClientService();

  Future<void> addClient(Client client, File? image) async {
    await _crudService.create('client', client.toJson(), image: image);
  }

  Future<List<Client>> getClients() async {
    final data = await _crudService.read('client');
    return (data as List).map((item) => Client.fromJson(item)).toList();
  }

  Future<void> updateClient(
      int? id, Client client, Uint8List? imageBytes) async {
    // Convertir l'objet client en JSON
    final clientData = client.toJson();

    if (id == null) {
      throw Exception('L\'ID ne peut pas être nul');
    }

    if (imageBytes != null) {
      // Si une image est fournie, mettre à jour avec l'image
      await _crudService.updateWithImage(
          'client/${id.toString()}', clientData, imageBytes);
    } else {
      // Sinon, mettre à jour sans image
      await _crudService.update('investisseur/${id.toString()}', clientData);
    }
  }

  Future<void> deleteClient(String id) async {
    await _crudService.delete('client/$id');
  }

  Future<Map<String, dynamic>?> fetchClientInfo(String userId) async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/client/$userId'));

    if (response.statusCode == 200) {
      return json.decode(
          response.body); // Retourne un Map avec les informations du client
    } else {
      // Ajout d'un message d'erreur plus explicite
      throw Exception(
          'Échec de la récupération des informations du client: ${response.statusCode}');
    }
  }
}
