import 'package:bill_app/domain/entities/client.dart';

class ClientState {}

class ClientStartState extends ClientState {
  ClientStartState();
}

class ClientErrorState extends ClientState {}

class ClientLoadingState extends ClientState {}

class ClientLoadedState extends ClientState {
  final List<Client> clients;
  ClientLoadedState({required this.clients});
}
