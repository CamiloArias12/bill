import 'package:dio/dio.dart';

abstract class AbstractApiService {
  Future<Response> get(
      {required String path, Map<String, dynamic> data, Options? options});
}
