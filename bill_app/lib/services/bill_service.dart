import 'package:bill_app/api/abstract_api_service.dart';
import 'package:bill_app/config/app_config.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class BillService implements AbstractBillService {
  late final AbstractApiService apiService;
  late final AppConfig appConfig;
  late final String apiRepositoryUrl;

  BillService() {
    appConfig = GetIt.I.get<AppConfig>();
    apiRepositoryUrl = '${appConfig.apiUrl}/api/bill';
    apiService = GetIt.I.get<AbstractApiService>();
  }

  @override
  Future<List<Bill>> fetchAll() async {
    Response response = await apiService.get(path: apiRepositoryUrl);
    List<Bill> bills = [];
    final List<dynamic> listData = response.data;
    for (var bill in listData) {
      final Bill billNew = Bill.fromMap(bill);
      bills.add(billNew);
    }
    return bills;
  }
}

abstract class AbstractBillService {
  Future<List<Bill>> fetchAll();
}
