import 'package:bill_app/bloc/Bill/bloc.dart';
import 'package:bill_app/bloc/Client/bloc.dart';
import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/config/style_app/style_app_impl.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/domain/entities/reminder_result.dart';
import 'package:bill_app/main.dart';
import 'package:bill_app/services/bill_service.dart';
import 'package:bill_app/services/client_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

final _apiBill = {
  'id': 'b1',
  'billCode': 'P-00001',
  'billTotal': 11650,
  'subtotal': 10000,
  'vat': 1900.0,
  'withholding': 250,
  'creationDate': '2026-10-19T10:00:00Z',
  'status': 'primerRecordatorio',
  'city': 'Bogota',
  'isPaid': false,
  'paymentDate': null,
  'clientId': 'c1',
};

class FakeBillService implements AbstractBillService {
  String status = 'primerrecordatorio';
  String? processedClientId = 'not-called';

  @override
  Future<List<Bill>> fetchAll() async =>
      [Bill.fromMap({..._apiBill, 'status': status})];

  @override
  Future<List<ReminderResult>> processReminders({String? clientId}) async {
    processedClientId = clientId;
    status = 'segundorecordatorio';
    return [
      ReminderResult.fromMap({
        'clientId': 'c1',
        'clientName': 'Prueba desarrollo 1',
        'updated': [
          {
            'billCode': 'P-00001',
            'previousStatus': 'primerrecordatorio',
            'newStatus': 'segundorecordatorio',
          }
        ],
        'failedBillCodes': <String>[],
      })
    ];
  }
}

class FakeClientService implements AbstractClientService {
  @override
  Future<List<Client>> fetchAll() async => [
        Client(
            id: 'c1',
            name: 'Prueba desarrollo 1',
            nit: '111.111.111-1',
            email: 'c1@test.com')
      ];
}

void main() {
  late FakeBillService billService;

  setUp(() {
    GetIt.I.reset();
    billService = FakeBillService();
    GetIt.I.registerSingleton<StyleApp>(StyleAppImpl());
    GetIt.I.registerSingleton<AbstractBillService>(billService);
    GetIt.I.registerSingleton<AbstractClientService>(FakeClientService());
    GetIt.I.registerLazySingleton<BillBloc>(() => BillBloc());
    GetIt.I.registerLazySingleton<ClientBloc>(() => ClientBloc());
  });

  test('Bill.fromMap acepta enteros, nulos y estado en camelCase', () {
    final bill = Bill.fromMap({..._apiBill, 'subtotal': null});
    expect(bill.billTotal, 11650.0);
    expect(bill.subtotal, isNull);
    expect(bill.billStatus?.label, 'Primer recordatorio');
  });

  testWidgets('muestra el resumen y las facturas', (tester) async {
    await tester.pumpWidget(AppManager());
    await tester.pumpAndSettle();

    expect(find.text('P-00001'), findsOneWidget);
    expect(find.text('\$ 11.650'), findsWidgets);
    expect(find.text('Primer recordatorio'), findsWidgets);
  });

  testWidgets('envía recordatorios y muestra el resultado', (tester) async {
    await tester.pumpWidget(AppManager());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enviar recordatorios'));
    await tester.pumpAndSettle();

    expect(billService.processedClientId, isNull);
    expect(find.text('Se notificaron 1 facturas'), findsOneWidget);
  });

  testWidgets('filtra por cliente y envía solo a ese cliente', (tester) async {
    await tester.pumpWidget(AppManager());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Prueba desarrollo 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar a este cliente'));
    await tester.pumpAndSettle();

    expect(billService.processedClientId, 'c1');
  });
}
