import 'package:bill_app/api/abstract_api_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class ApiService extends AbstractApiService {
  late final Dio dio;
  ApiService() {
    dio = GetIt.I.get<Dio>();
  }

  @override
  Future<Response> get(
      {required String path,
      Map<String, dynamic>? data,
      Options? options}) async {
    return await dio.get(path, queryParameters: data, options: options);
  }
}
