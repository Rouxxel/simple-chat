import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;

//Import alert dialogs and others
import "package:simple_chat/widgets_and_ui_elements/alert_dialog_list.dart";
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//User profile handling--------------------------------------------------
Future<bool> save_user_preferences(
    BuildContext context, {
      required String access_token,
      required String user_id,
      String? ai_personality,
      String? verbose_level,
      String? background_color,
      String? bar_colors,
      String? user_text_box_color,
      String? ai_text_box_color,
      String? ai_language,
      bool? sound_effects_on,
    }) async {
  log_handler?.d("[------user_preferences function executing------]");

  //Validate required fields
  if (access_token.trim().isEmpty || user_id.trim().isEmpty) {
    show_invalid_parameters_error(context);
    return false;
  }

  //Construct request body with required fields
  final Map<String, dynamic> body = {
    "access_token": access_token,
    "user_id": user_id,
  };

  //Conditionally include optional fields
  if (ai_personality != null) body["ai_personality"] = ai_personality;
  if (verbose_level != null) body["verbose_level"] = verbose_level;
  if (background_color != null) body["background_color"] = background_color;
  if (bar_colors != null) body["bar_colors"] = bar_colors;
  if (user_text_box_color != null) body["user_text_box_color"] = user_text_box_color;
  if (ai_text_box_color != null) body["ai_text_box_color"] = ai_text_box_color;
  if (ai_language != null) body["ai_language"] = ai_language;
  if (sound_effects_on != null) body["sound_effects_on"] = sound_effects_on;

  final payload_body = jsonEncode(body);

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url_user_preferences),
      headers: {"Content-Type": "application/json"},
      body: payload_body,
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
      case 201:
        log_handler?.i("User preferences saved: ${response.statusCode}");
        return true;
      case 400:
        log_handler?.e("Invalid parameters: ${response.statusCode} - ${response.body}");
        show_invalid_parameters_error(context);
        return false;
      case 401:
        log_handler?.w("Unauthorized: ${response.statusCode} - ${response.body}");
        show_invalid_credentials(context);
        return false;
      case 404:
        log_handler?.w("User not found: ${response.statusCode} - ${response.body}");
        show_user_not_found(context);
        return false;
      case 409:
        log_handler?.w("Conflict: ${response.statusCode} - ${response.body}");
        return false;
      case 429:
        log_handler?.e("Rate limit: ${response.statusCode} - ${response.body}");
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
  } catch (e) {
    log_handler?.e("Error processing response: $e");
    return false;
  }
}
