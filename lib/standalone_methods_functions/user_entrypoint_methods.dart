import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;
import "package:simple_chat/session_related/app_storage_class.dart";
import "package:simple_chat/standalone_methods_functions/general_methods.dart";

//Import alert dialogs and others
import "package:simple_chat/utils/alert_dialog_list.dart";
import 'package:simple_chat/configuration/config_invoke.dart';
import 'package:simple_chat/utils/logger_config.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//User entrypoint handling--------------------------------------------------
//Root method to wake the backend up
Future<void> root_endpoint() async {
  final Uri url = Uri.parse('${config_data.backend_url}/');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log_handler?.i("Backend running: ${data['message']}");
    } else {
      log_handler?.w("Backend start up failed with status: ${response.statusCode}");
    }
  } catch (e) {
    log_handler?.e("Failed to connect to backend: $e");
  }
}

//Sign up method
Future<bool> sign_up(
    BuildContext context,
    String email,
    String password
    ) async{
  log_handler?.d("[------sign_up function executing------]");
  if (email.isEmpty || password.isEmpty) {
    //No input to process
    log_handler?.e("Controllers are empty");
    return false;
  }

  //Validate email and password
  if(!is_valid_email(context, email)){
    show_invalid_email_error(context);
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }
  if(!is_valid_password(context, password)){
    show_invalid_password_error(context);
    log_handler?.w("Input not sent due to invalid password.");
    return false;
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
        return false;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return false;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return false;
      default:
        log_handler?.w("Unexpected status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return false;
    }

    //Parse Backend response text
    final data = jsonDecode(response.body);
    //Get messages individually
    final user = data['user'];

    log_handler?.d("User confirmed (${user['confirmed']}) signed in with email ${user['email']} at ${user['created_at']}");
    show_successful_sign_up(context);
    return true;
  } catch (er){
    log_handler?.e("Error: $er");
    return false;
  }
}

Future<bool> log_in(
    BuildContext context,
    String email,
    String password,
    ) async {
  log_handler?.d("[------log_in function executing------]");
  //Basic empty check (client‑side)
  if (email.trim().isEmpty || password.isEmpty) {
    show_invalid_parameters_error(context);
    return false;
  }

  //Validate email and password
  if(!is_valid_email(context, email)){
    show_invalid_email_error(context);
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }
  if(!is_valid_password(context, password)){
    show_invalid_password_error(context);
    log_handler?.w("Input not sent due to invalid password.");
    return false;
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
    return false;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return false;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return false;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        final data = jsonDecode(response.body);

        //Save token data for global use
        await AppStorage.save_token_related(
          data['session']['access_token'],
          data['session']['refresh_token'],
          data['session']['expires_in'],
          data['session']['token_type'],
        );
        //Save user data for global use
        await AppStorage.save_user_data(
          data['user']['id'],
          data['user']['email'],
        );

        //TODO: Start timer for token refresh watch dog
        //TokenWatchdog().start(context);

        return true;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return false;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        show_invalid_credentials(context);
        return false;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return false;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        show_server_error(context);
        return false;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return false;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return false;
  }
}

Future<void> log_out(
    BuildContext context,
    ) async {
  log_handler?.d("[------log_out function executing------]");

  //Get access_token
  final String? access_token = await AppStorage.get_access_token();

  if (access_token == null || access_token.trim().isEmpty) {
    show_invalid_parameters_error(context);
    return;
  }

  final body = jsonEncode({
    "access_token": access_token,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url_log_out),
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
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        //Remove all global variables
        await AppStorage.clear_tokens();
        //TODO: Stop watch dog for token refresh
        //TokenWatchdog().stop();
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        show_invalid_credentials(context);
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        show_server_error(context);
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}

Future<bool> complete_user_profile(
    BuildContext context, {
      required String access_token,
      required String email,
      required String user_name,
      required String first_name,
      required String last_name,
      required String phone_number,
      required String date_birth,   // Format: 'YYYY-MM-DD'
      required String country,
      required String country_code, // ISO 3166-1 alpha-2
    }) async {
  log_handler?.d("[------complete_profile function executing------]");

  // Basic client-side validation
  if (access_token.trim().isEmpty ||
      email.trim().isEmpty ||
      user_name.trim().isEmpty ||
      first_name.trim().isEmpty ||
      last_name.trim().isEmpty ||
      phone_number.trim().isEmpty ||
      date_birth.trim().isEmpty ||
      country.trim().isEmpty ||
      country_code.trim().isEmpty) {
    show_invalid_parameters_error(context);
    return false;
  }

  if (!is_valid_email(context, email)) {
    show_invalid_email_error(context);
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }

  // Construct request body
  final body = jsonEncode({
    "access_token": access_token,
    "email": email,
    "user_name": user_name,
    "first_name": first_name,
    "last_name": last_name,
    "phone_number": phone_number,
    "date_birth": date_birth,
    "country": country,
    "country_code": country_code,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url_complete_profile),
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
    return false;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return false;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return false;
  }

  try {
    switch (response.statusCode) {
      case 200:
      case 201: //Just in case your backend returns 201 Created
        log_handler?.i("Profile completion successful: ${response.statusCode}");
        return true;
      case 400:
        log_handler?.e("Invalid parameters: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return false;
      case 401:
        log_handler?.w("Unauthorized: ${response.statusCode} - ${response.body}");
        show_invalid_credentials(context);
        return false;
      case 409:
        log_handler?.w("Profile already exists: ${response.statusCode} - ${response.body}");
        //TODO:create alert dialog
        //show_profile_already_exists_error(context);
        return false;
      case 429:
        log_handler?.e("Rate limited: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return false;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        show_server_error(context);
        return false;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return false;
    }
  } catch (er) {
    log_handler?.e("Error processing response: $er");
    return false;
  }
}

Future<bool> check_user_exists(
    BuildContext context, {
      required String access_token,
      required String user_id,
    }) async {
  log_handler?.d("[------check_user_exists function executing------]");

  //Basic client-side validation
  if (access_token.trim().isEmpty || user_id.trim().isEmpty) {
    show_invalid_parameters_error(context);
    return false;
  }

  final body = jsonEncode({
    "access_token": access_token,
    "user_id": user_id,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url_user_exists),
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
    return false;
  } on TimeoutException {
    return false;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return false;
  }

  try {
    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);
        log_handler?.i("User existence check success: exists=${data['exists']}");
        return data['exists'];
      case 400:
        log_handler?.e("Invalid parameters: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return false;
      case 401:
        log_handler?.w("Unauthorized: ${response.statusCode} - ${response.body}");
        show_invalid_credentials(context);
        return false;
      case 429:
        log_handler?.e("Rate limited: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return false;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        show_server_error(context);
        return false;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return false;
    }
  } catch (er) {
    log_handler?.e("Error processing response: $er");
    return false;
  }
}

Future<void> refresh_access(
    BuildContext context
    ) async {
  log_handler?.d("[------refresh_access function executing------]");
  //Get access_token
  final String? refresh_token = await AppStorage.get_refresh_token();

  if (refresh_token == null || refresh_token.trim().isEmpty) {
    show_invalid_parameters_error(context);
    return;
  }

  final body = jsonEncode({
    "refresh_token": refresh_token,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url_refresh_token),
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
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        final data = jsonDecode(response.body);

        await AppStorage.save_token_related(
          data["data"]["access_token"],
          data["data"]["refresh_token"],
          data["data"]["expires_in"],
          data["data"]["token_type"],
        );

        //TODO: Start timer for token refresh watch dog
        //TokenWatchdog().start(context);

        log_handler?.i("User token refreshed successfully");
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        show_invalid_credentials(context);
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        show_unexpected_backend_error(context);
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        show_server_error(context);
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}

Future<bool> reset_password(
    BuildContext context,
    String email,
    ) async {
  log_handler?.d("[------reset_password function executing------]");

  //Check for empty
  if (email.trim().isEmpty) {
    show_invalid_parameters_error(context);
    return false;
  }
  //Check for invalid email
  if (!is_valid_email(context, email)) {
    show_invalid_email_error(context);
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }

  //Prepare body
  final body = jsonEncode({"email": email});

  try {
    final response = await http
        .post(
      Uri.parse(config_data.backend_url_reset_password),
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

    switch (response.statusCode) {
      case 200:
        log_handler?.i("Password reset email sent successfully.");
        show_successful_password_reset(context);
        return true;

      case 400:
        log_handler?.e("Invalid email format: ${response.body}");
        show_invalid_email_error(context);
        return false;

      case 404:
        log_handler?.w("Email not registered: ${response.body}");
        show_user_not_found(context); // You should implement this dialog
        return false;

      case 429:
        log_handler?.e("Rate limit hit: ${response.body}");
        show_unexpected_backend_error(context);
        return false;

      case 500:
        log_handler?.e("Server error: ${response.body}");
        show_server_error(context);
        return false;

      default:
        log_handler?.w("Unexpected status code: ${response.statusCode}");
        show_unexpected_backend_error(context);
        return false;
    }
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    show_network_error(context);
    return false;
  } on TimeoutException {
    return false; // already handled
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    show_unexpected_backend_error(context);
    return false;
  }
}
