import 'package:bill_app/api/abstract_api_service.dart';
import 'package:bill_app/api/api_service.dart';
import 'package:bill_app/bloc/Bill/bloc.dart';
import 'package:bill_app/bloc/Client/bloc.dart';
import 'package:bill_app/config/app_config.dart';
import 'package:bill_app/config/app_config_impl.dart';
import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/config/style_app/style_app_impl.dart';
import 'package:bill_app/services/bill_service.dart';
import 'package:bill_app/services/client_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

Future<void> serviceLocatorSetup() async {
  final getIt = GetIt.I;

  getIt.registerSingleton<StyleApp>(StyleAppImpl());
  getIt.registerSingleton<AppConfig>(AppConfigImpl());
  getIt.registerSingleton<Dio>(Dio());

  // Las dependencias se pasan por constructor; se registran en orden para no
  // resolver lazy singletons de forma reentrante dentro de un constructor.
  getIt.registerSingleton<AbstractApiService>(ApiService(getIt<Dio>()));
  getIt.registerSingleton<AbstractBillService>(
      BillService(getIt<AbstractApiService>(), getIt<AppConfig>()));
  getIt.registerSingleton<AbstractClientService>(
      ClientService(getIt<AbstractApiService>(), getIt<AppConfig>()));

  // Dependencias resueltas antes y capturadas en el closure: el factory del
  // lazy singleton no llama a get() durante su propia creación.
  final billService = getIt<AbstractBillService>();
  final clientService = getIt<AbstractClientService>();
  getIt.registerLazySingleton<BillBloc>(() => BillBloc(billService));
  getIt.registerLazySingleton<ClientBloc>(() => ClientBloc(clientService));
}
