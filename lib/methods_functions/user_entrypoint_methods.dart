import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;

//Import alert dialogs and others
import "package:simple_chat/utils/alert_dialog_list.dart";
import 'package:simple_chat/configurations/config_invoke.dart';
import 'package:simple_chat/utils/logger_config.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//User entrypoint handling--------------------------------------------------
//Sign up method
Future<void> sign_up(BuildContext context, String email, String password) async{
  log_handler?.d("[------sign_up function executing------]");
  if (email.isEmpty || password.isEmpty) {
    //No input to process
    log_handler?.e("Controllers are empty");
    return;
  }

  try {
    //Prepare request payload
    final body_for_backend = jsonEncode({
      "email": email,
      "password": password,
    });

    //POST request to your backend URL
    final response = await http
        .post(
      Uri.parse(config_data.backend_url_sign_up),
      headers: {"Content-Type": "application/json"},
      body: body_for_backend,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () {
        show_ai_took_too_long_error(context);
        throw TimeoutException('Server took too long');
      },
    );

    //---------- Status‑code handling ----------
    switch(response.statusCode){
      case 200:
      //Log and proceed
        log_handler?.i("Backend response successful ${response.statusCode}");
        break;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        show_server_error(context);
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return;
      default:
        log_handler?.w("Unexpected status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return;
    }

    //Parse Backend response text
    final data = jsonDecode(response.body);
    //Get messages individually
    final user = data['user'];

    log_handler?.d("User confirmed (${user['confirmed']}) signed in with email ${user['email']} at ${user['created_at']}");
    show_successful_sign_up(context);
  } catch (er){
    log_handler?.e("Error: $er");
    //show_ai_response_error(context);
  }
}

Future<Map<String, dynamic>?> log_in(
    BuildContext context,
    String email,
    String password,
    ) async {
  log_handler?.d("[------log_in function executing------]");

  // Basic empty check (client‑side)
  if (email.trim().isEmpty || password.isEmpty) {
    show_invalid_parameters_error(context);
    return null;
  }

  final body = jsonEncode({
    "email": email,
    "password": password,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url_log_in),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () {
        show_ai_took_too_long_error(context);
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    show_network_error(context);
    return null;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return null;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return null;
  }

  //---------- Status‑code handling ----------
  switch (response.statusCode) {
    case 200:
      log_handler?.i("Backend response successful ${response.statusCode}");
      final data = jsonDecode(response.body); //Return backend response
      log_handler?.w(data);
      return data;
    case 400:
      log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
      show_invalid_parameters_error(context);
      break;
    case 401:
      log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
      show_invalid_credentials(context);
      break;
    case 429:
      log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
      show_unexpected_backend_error(context);
      break;
    case 500:
      log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
      show_server_error(context);
      break;
    default:
      log_handler?.w("Unhandled status code: ${response.statusCode}");
      show_unexpected_backend_error(context);
      break;
  }
  return null;
}
