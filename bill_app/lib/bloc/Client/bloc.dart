import 'package:bill_app/bloc/Client/event.dart';
import 'package:bill_app/bloc/Client/state.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/services/client_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final AbstractClientService clientService;

  ClientBloc(this.clientService) : super(ClientStartState()) {
    on<ClientFetchEvent>(_fetchAllClient);
  }

  Future<void> _fetchAllClient(ClientEvent event, Emitter emit) async {
    emit(ClientLoadingState());
    try {
      List<Client> clients = await clientService.fetchAll();
      emit(ClientLoadedState(clients: clients));
    } catch (e) {
      debugPrint('$e');
      emit(ClientErrorState());
    }
  }
}
