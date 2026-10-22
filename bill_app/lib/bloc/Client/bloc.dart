import 'package:bill_app/bloc/Client/event.dart';
import 'package:bill_app/bloc/Client/state.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/services/bill_service.dart';
import 'package:bill_app/services/client_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  late final AbstractClientService clientService;

  ClientBloc() : super(ClientStartState()) {
    clientService = GetIt.I.get<AbstractClientService>();
    on<ClientFetchEvent>(_fetchAllClient);
  }

  Future<void> _fetchAllClient(ClientEvent event, Emitter emit) async {
    emit(ClientLoadingState());
    try {
      List<Client> clients = await clientService.fetchAll();
      emit(ClientLoadedState(clients: clients));
    } catch (e) {
      print(e);
      emit(ClientErrorState());
    }
  }
}
