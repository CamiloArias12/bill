import 'package:bill_app/api/abstract_api_service.dart';
import 'package:bill_app/config/app_config.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class ClientService extends AbstractClientService {
  late final AbstractApiService apiService;
  late final AppConfig appConfig;
  late final String apiRepositoryUrl;

  ClientService() {
    appConfig = GetIt.I.get<AppConfig>();
    apiRepositoryUrl = '${appConfig.apiUrl}/api/client';
    apiService = GetIt.I.get<AbstractApiService>();
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
