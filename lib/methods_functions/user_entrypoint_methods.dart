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
      Uri.parse("https://simple-chat-backend-testing.onrender.com/auth/sign_up_email"),
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

    //Check response status code
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
