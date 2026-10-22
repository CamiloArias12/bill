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
  GetIt.I.registerSingleton<StyleApp>(StyleAppImpl());
  GetIt.I.registerSingleton<AppConfig>(AppConfigImpl());

  final Dio dio = Dio();
  GetIt.I.registerLazySingleton(() => dio);
  GetIt.I.registerLazySingleton<AbstractApiService>(() => ApiService());
  GetIt.I.registerLazySingleton<AbstractBillService>(() => BillService());
  GetIt.I.registerLazySingleton<AbstractClientService>(() => ClientService());

  GetIt.I.registerLazySingleton<BillBloc>(() => BillBloc());
  GetIt.I.registerLazySingleton<ClientBloc>(() => ClientBloc());
}
