import 'dart:io';
import '../models/client.dart'; // Assurez-vous que le chemin est correct
import '../services/crud/client_service.dart'; // Vérifiez que ce chemin est correct

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

  Future<void> updateClient(String id, Client client) async {
    await _crudService.update('client/$id', client.toJson());
  }

  Future<void> deleteClient(String id) async {
    await _crudService.delete('client/$id');
  }
}
