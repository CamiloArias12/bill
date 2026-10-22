import 'package:bill_app/api/abstract_api_service.dart';
import 'package:bill_app/config/app_config.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:dio/dio.dart';

class ClientService extends AbstractClientService {
  final AbstractApiService apiService;
  final AppConfig appConfig;
  late final String apiRepositoryUrl;

  ClientService(this.apiService, this.appConfig) {
    apiRepositoryUrl = '${appConfig.apiUrl}/api/client';
  }

  @override
  Future<List<Client>> fetchAll() async {
    Response response = await apiService.get(path: apiRepositoryUrl);
    List<Client> clients = [];
    final List<dynamic> listData = response.data;
    for (var client in listData) {
      final Client clientNew = Client.fromMap(client);
      clients.add(clientNew);
    }
    return clients;
  }
}

abstract class AbstractClientService {
  Future<List<Client>> fetchAll();
}
