import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:simple_chat/functionality_n_scripts/session_related/app_storage_class.dart';
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';
import 'package:simple_chat/functionality_n_scripts/standalone_methods/user_entrypoint_methods.dart';

class TokenWatchdog {
  static final TokenWatchdog _instance = TokenWatchdog._internal();
  factory TokenWatchdog() => _instance;
  TokenWatchdog._internal();

  Timer? _timer;

  void start(BuildContext context) async {
    //Should be an int
    final expires_in_str = await AppStorage.get_expires_in();

    if (expires_in_str == null || expires_in_str.trim().isEmpty) {
      log_handler?.e("Token expiry not found, cannot start watchdog.");
      return;
    }

    final expires_in_int = int.tryParse(expires_in_str);
    if (expires_in_int == null) {
      log_handler?.e("Invalid expiry format.");
      return;
    }

    final duration = Duration(seconds: expires_in_int - config_data.refresh_token_preemptive);
    log_handler?.i("Token refresh scheduled in ${duration.inSeconds} seconds.");

    _timer?.cancel(); //Cancel existing timer
    _timer = Timer(duration, () {
      log_handler?.i("Executing scheduled token refresh...");
      refresh_access(context).then((_) {
        //Restart the watchdog after refresh
        start(context);
      });
    });
  }

  void stop() {
    log_handler?.i("Token refresh scheduled stopped");
    _timer?.cancel();
    _timer = null;
  }
}
