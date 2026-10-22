import 'package:bill_app/config/app_config.dart';
import 'package:bill_app/config/style_app/style_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

class AppConfigImpl extends AppConfig {
  late final StyleApp styleApp;

  AppConfigImpl() {
    appName = "Bill";
    apiUrl = dotenv.get('API_URL', fallback: 'http://10.0.2.2:5080');
    styleApp = GetIt.I.get<StyleApp>();
  }
}
