import 'package:bill_app/domain/entities/client.dart';

String getClientNameById(String id, List<Client> clients) {
  Client client = clients.firstWhere(
    (client) => client.id == id,
  );

  return client.name;
}

String getClientNitById(String id, List<Client> clients) {
  Client client = clients.firstWhere(
    (client) => client.id == id,
  );

  return client.nit;
}
