import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/session_related/app_storage_class.dart';
import 'package:simple_chat/functionality_n_scripts/standalone_methods/session_methods.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';

Future<http.Response> post_authenticated_json(
  BuildContext context,
  Uri uri,
  String body,
) async {
  Future<http.Response> sendRequest() async {
    return http
        .post(
          uri,
          headers: await AppStorage.get_authenticated_headers(),
          body: body,
        )
        .timeout(Duration(seconds: config_data.max_api_response_time_limit + 5));
  }

  final accessToken = await AppStorage.get_access_token();
  if (accessToken == null || accessToken.trim().isEmpty) {
    log_handler?.w('[post_authenticated_json] Missing access token before request');
  }

  var response = await sendRequest();
  if (response.statusCode == 401) {
    log_handler?.w('[post_authenticated_json] 401 received, refreshing access token');
    final refreshed = await refresh_access(context);
    if (refreshed) {
      response = await sendRequest();
    }
  }

  return response;
}
