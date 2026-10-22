import 'package:bill_app/api/abstract_api_service.dart';
import 'package:dio/dio.dart';

class ApiService extends AbstractApiService {
  final Dio dio;
  ApiService(this.dio);

  @override
  Future<Response> get(
      {required String path,
      Map<String, dynamic>? data,
      Options? options}) async {
    return await dio.get(path, queryParameters: data, options: options);
  }

  @override
  Future<Response> post({required String path, Options? options}) async {
    return await dio.post(path, options: options);
  }
}
