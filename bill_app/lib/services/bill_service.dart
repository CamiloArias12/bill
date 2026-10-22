import 'package:bill_app/api/abstract_api_service.dart';
import 'package:bill_app/config/app_config.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/reminder_result.dart';
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
    final List<dynamic> listData = response.data;
    return listData.map((bill) => Bill.fromMap(bill)).toList();
  }

  @override
  Future<List<ReminderResult>> processReminders({String? clientId}) async {
    if (clientId != null) {
      Response response =
          await apiService.post(path: '$apiRepositoryUrl/status/$clientId');
      return [ReminderResult.fromMap(response.data)];
    }
    Response response = await apiService.post(path: '$apiRepositoryUrl/status');
    final List<dynamic> listData = response.data;
    return listData.map((result) => ReminderResult.fromMap(result)).toList();
  }
}

abstract class AbstractBillService {
  Future<List<Bill>> fetchAll();
  Future<List<ReminderResult>> processReminders({String? clientId});
}
