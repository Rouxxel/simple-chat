import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;
import "package:simple_chat/functionality_n_scripts/session_related/app_storage_class.dart";
import "package:simple_chat/functionality_n_scripts/standalone_methods/general_methods.dart";

//Import alert dialogs and others
import "package:simple_chat/widgets_and_ui_elements/alert_dialog_builders.dart";
import 'package:simple_chat/functionality_n_scripts/configuration_scripts/config_invoke.dart';
import 'package:simple_chat/functionality_n_scripts/utils/logger_config.dart';
import "package:simple_chat/functionality_n_scripts/message_related/message_class.dart";

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//Session handling--------------------------------------------------
//Root method to wake the backend up (SHOULD NOT BE BUT ANYWAYS)
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

Future<bool> check_user_exists(
    BuildContext context,
    ) async {
  log_handler?.d("[------check_user_exists function executing------]");

  final String? user_id = await AppStorage.get_user_id();
  final String? access_token = await AppStorage.get_access_token();

  //Basic client-side validation
  if (access_token!.trim().isEmpty || user_id!.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid values",
      "Please try again later",
    );
    return false;
  }

  final body = jsonEncode({
    "access_token": access_token.toString(),
    "user_id": user_id.toString(),
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.check_user_exists_suffix),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return false;
  } on TimeoutException {
    return false;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
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
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return false;
      case 401:
        log_handler?.w("Unauthorized: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return false;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return false;
      case 429:
        log_handler?.e("Rate limited: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return false;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return false;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return false;
    }
  } catch (er) {
    log_handler?.e("Error processing response: $er");
    return false;
  }
}

Future<void> refresh_access(
    BuildContext context,
    ) async {
  log_handler?.d("[------refresh_access function executing------]");
  //Get access_token
  final String? refresh_token = await AppStorage.get_refresh_token();

  if (refresh_token == null || refresh_token.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid entered values",
      "You have entered invalid values, please enter valid values.",
    );
    return;
  }

  final body = jsonEncode({
    "refresh_token": refresh_token,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.refresh_token_suffix),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
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

        //Start timer for token refresh watch dog
        //TokenWatchdog().start(context);

        log_handler?.i("User token refreshed successfully");
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}

Future<void> log_out(
    BuildContext context,
    ) async {
  log_handler?.d("[------log_out function executing------]");

  //Get access_token
  final String? access_token = await AppStorage.get_access_token();

  if (access_token == null || access_token.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid entered values",
      "You have entered invalid values, please enter valid values.",
    );
    return;
  }

  final body = jsonEncode({
    "access_token": access_token,
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.log_out_suffix),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        //Remove all global variables
        await AppStorage.clear_tokens();
        //Stop watch dog for token refresh
        //TokenWatchdog().stop();
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}

Future<void> save_easter_egg_status(
    BuildContext context,
    ) async {
  log_handler?.d("[------save_easter_egg_status function executing------]");

  //Get access_token
  final String? access_token = await AppStorage.get_access_token();
  final String? email = await AppStorage.get_user_email();

  if (access_token!.trim().isEmpty || email!.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid values",
      "Please try again later",
    );
    return;
  }

  final body = jsonEncode({
    "access_token": access_token.toString(),
    "email":email.toString(),
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.easter_egg_status_suffix),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}

Future<Map<String, dynamic>> retrieve_user_preferences(
    BuildContext context,
    ) async {
  log_handler?.d("[------retrieve_user_preferences function executing------]");

  //Get access_token
  final String? access_token = await AppStorage.get_access_token();
  final String? user_id = await AppStorage.get_user_id();

  if (access_token!.trim().isEmpty || user_id!.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid values",
      "Please try again later",
    );
    return {"Invalid values":"Try again with valid values"};
  }

  final body = jsonEncode({
    "access_token": access_token.toString(),
    "user_id":user_id.toString(),
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.retrieve_user_preferences_suffix),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return {"Error 234":"There has been an error with the network, please try again later"};
  } on TimeoutException {
    // dialog already shown in onTimeout
    return {"Timeout exception":"Took too long time"};
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return {"Error 231":"There has been an unexpected backend error, please try again later."};
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return {"Error 400":"You have entered invalid values, please enter valid values"};
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return {"Error 401":"User not found"};
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return {"Error 422":"Unprocessable entity"};
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return {"Error 429":"Unexpected unknown server error"};
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return {"Error 500":"Server error"};
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return {"Error ${response.statusCode}":"Unexpected unknown error"};
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return {"Unhandled error":"$er"};
  }
}

Future<void> delete_user(
    BuildContext context,
    String email,
    String password,
    ) async {
  log_handler?.d("[------delete_user function executing------]");

  //Get access_token and user id
  final String? access_token = await AppStorage.get_access_token();
  final String? user_id = await AppStorage.get_user_id();
  if (access_token!.trim().isEmpty || user_id!.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid values",
      "Please try again later",
    );
    return;
  }

  //Validate password and email structure
  if(!is_valid_email(context, email) || !is_valid_password(context, password)) {
    log_handler?.w("Invalid email or password: $email, $password");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Email or password not valid",
      "Please return a valid email and password",
    );
    return;
  }

  //Ensure inputed email matches session email
  final String? session_email = await AppStorage.get_user_email();
  if(session_email != email){
    log_handler?.w("Iputed email does not match with session email: $email vs $session_email");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Email does not match session email",
      "The email you entered does not match the email you logged in with, please"
          "ensure the email is the one you started this session.",
    );
    return;
  }

  final body = jsonEncode({
    "user_id": user_id,
    "email": email,
    "password": password,
    "access_token": access_token
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.user_delete_profile),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        //Remove all global variables
        await AppStorage.clear_tokens();
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}

Future<void> save_current_chat(
    BuildContext context,
    {
      required String chat_title,
      required List<Message> chat_list,
    }
    ) async {
  log_handler?.d("[------save_current_chat function executing------]");

  //Get access_token
  final String? access_token = await AppStorage.get_access_token();
  final String? user_id = await AppStorage.get_user_id();

  if (access_token!.trim().isEmpty || user_id!.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid values",
      "Please try again later",
    );
    return;
  }

  //Convert list of Messages to Maps
  List<Map> converted_list = Message.message_to_json_list(chat_list);

  final body = jsonEncode({
    "access_token": access_token.toString(),
    "user_id":user_id.toString(),
    "current_chat":converted_list,
    "current_chat_title":chat_title
  });

  http.Response response;
  try {
    response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.user_chat_save_suffix),
      headers: {"Content-Type": "application/json"},
      body: body,
    )
        .timeout(
      Duration(seconds: config_data.max_api_response_time_limit + 5),
      onTimeout: () async {
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 227", //AI response took too long
          "There was an error with the processing time, please try again later",
        );
        throw TimeoutException('Server took too long');
      },
    );
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return;
  } on TimeoutException {
    // dialog already shown in onTimeout
    return;
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return;
  }

  try {
    //---------- Status‑code handling ----------
    switch (response.statusCode) {
      case 200:
        log_handler?.i("Backend response successful ${response.statusCode}");
        await build_informative_alert_dialog(
            context,
            "Ok",
            "Chat successfully saved!!!",
            "The current chat has been saved, you can safely close the app and"
                "reload the conversation from 'See past chats' section"
        );
        return;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user",
          "We were not able to find your user, please ensure you have signed up and"
              "confirmed your email before trying again",
        );
        return;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return;
      case 429:
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
      case 500:
        log_handler?.e("Server error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 230", //Server error
          "There has been an error with the server, please try again later",
        );
        return;
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return;
  }
}
