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

//imports
/////////////////////////////////////////////////////////////////////////////
//Methods

//User entrypoint handling--------------------------------------------------
//Sign up method
Future<bool> sign_up(
    BuildContext context,
    String email,
    String password
    ) async{
  log_handler?.d("[------sign_up function executing------]");
  //Local validation
  if (email.isEmpty || password.isEmpty) {
    //No input to process
    log_handler?.e("Controllers are empty");
    return false;
  }

  //Validate email and password
  if(!is_valid_email(context, email)){
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid email",
      "The email you provided is invalid, please enter a valid email",
    );
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }
  if(!is_valid_password(context, password)){
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid password",
      "The password you entered is invalid, please enter a valid password that contains. "
        "at least 8 characters, 1 upper case character, 1 lower case character, 1 number and "
        "1 number.",
    );
    log_handler?.w("Input not sent due to invalid password.");
    return false;
  }

  try {
    //Prepare request payload
    final body_for_backend = jsonEncode({
      "email": email,
      "password": password,
    });

    //POST request to backend URL
    final response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.sign_up_suffix),
      headers: {"Content-Type": "application/json"},
      body: body_for_backend,
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

    //---------- Status‑code handling ----------
    final data = jsonDecode(response.body);
    final success = data["success"] ?? false;
    log_handler?.w(data);

    switch(response.statusCode){
      case 200:
        if (data["user_already_exists"] == true) {
          log_handler?.i("Attempted to register an existing user.");

          //Show alert and then navigate to login page
          await build_informative_alert_dialog(
            context,
            "Ok",
            "Account Exists",
            data["message"] ?? "An account with this email already exists, please"
                "try to log in or complete sign up process in your email",
          );

          // Navigate to login page automatically after alert dismissed
          Navigator.of(context).pushReplacementNamed('/login');

          return false;
        }

        if (success) {
          final user = data["user"];
          log_handler?.i("User successfully registered: ${user["email"]}");

          await build_informative_alert_dialog(
            context,
            "Ok",
            "Sign-up Successful!",
            "You have been successfully registered. Please check your email to confirm your account.",
          );
          return true;
        }

        log_handler?.w("Success false in 200 response.");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Unexpected Response",
          data["message"] ?? "An unknown issue occurred during sign-up.",
        );
        return false;
      case 400:
        log_handler?.e("Client error: ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Email already signed in",
          data["detail"] ?? "Invalid email or password.",
        );
        return false;
      case 422:
        log_handler?.e("Validation error: ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid Input",
          "There was an issue with the data provided. Please review and try again.",
        );
        return false;
      case 429:
        log_handler?.e("Rate limit hit: ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Too Many Requests",
          "You’ve sent too many requests in a short time. Please wait and try again.",
        );
        return false;
      case 500:
      default:
        log_handler?.e("Server error (${response.statusCode}): ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Server Error",
          "An unexpected error occurred on our server. Please try again later.",
        );
        return false;
    }
  } catch (e) {
    log_handler?.e("Exception in sign-up: $e");
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Unexpected Error",
      "Something went wrong while processing your request. Please try again.",
    );
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
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid entered values",
      "You have entered invalid values, please enter valid values.",
    );
    return false;
  }

  //Validate email and password
  if(!is_valid_email(context, email)){
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid email",
      "The email you provided is invalid, please enter a valid email",
    );
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }
  if(!is_valid_password(context, password)){
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid password",
      "The password you entered is invalid, please enter a valid password that contains. "
          "at least 8 characters, 1 upper case character, 1 lower case character, 1 number and "
          "1 number.",
    );
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
      Uri.parse(config_data.backend_url + config_data.log_in_suffix),
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
    // dialog already shown in onTimeout
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

        //Start timer for token refresh watch dog
        //TokenWatchdog().start(context);

        return true;
      case 400:
        log_handler?.e("Parameters error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid entered values",
          "You have entered invalid values, please enter valid values.",
        );
        return false;
      case 401:
        log_handler?.w("Unauthorized access: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid user or password",
          "Please ensure you enter a valid user with its associated password correctly",
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
        log_handler?.e("Backend error: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return false;
      case 500:
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected error, please try again later.",
        );
        return false;
    }
  } catch (er){
    log_handler?.e("Error: $er");
    return false;
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
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid entered values",
      "You have entered invalid values, please enter valid values.",
    );
    return false;
  }

  if (!is_valid_email(context, email)) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid email",
      "The email you provided is invalid, please enter a valid email",
    );
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
      Uri.parse(config_data.backend_url + config_data.complete_profile_suffix),
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
    // dialog already shown in onTimeout
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
      case 201: //Just in case your backend returns 201 Created
        log_handler?.i("Profile completion successful: ${response.statusCode}");
        return true;
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
      case 409:
        log_handler?.w("Profile already exists: ${response.statusCode} - ${response.body}");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "User already exists",
          "The user you are trying to enter already exists, please try loggin in",
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
          "Error 231", //Unexpected unknown server error due to limite rate reached
          "There has been an unexpected backend error, please try again later.",
        );
        return false;
      case 500:
      default:
        log_handler?.w("Unhandled status code: ${response.statusCode} - ${response.body}");
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

Future<bool> reset_password(
    BuildContext context,
    String email,
    ) async {
  log_handler?.d("[------reset_password function executing------]");

  //Check for empty
  if (email.trim().isEmpty) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid entered values",
      "You have entered invalid values, please enter valid values.",
    );
    return false;
  }
  //Check for invalid email
  if (!is_valid_email(context, email)) {
    await build_informative_alert_dialog(
      context,
      "Ok",
      "Invalid email",
      "The email you provided is invalid, please enter a valid email",
    );
    log_handler?.w("Input not sent due to invalid email.");
    return false;
  }

  //Prepare body
  final body = jsonEncode({"email": email});

  try {
    final response = await http
        .post(
      Uri.parse(config_data.backend_url + config_data.reset_password_suffix),
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

    switch (response.statusCode) {
      case 200:
        log_handler?.i("Password reset email sent successfully.");
        await build_informative_alert_dialog(
          context,
          "Ok",
          "Password reset successful!!!",
          "Please check your email to proceed with the resetting of your password",
        );
        return true;
      case 400:
        log_handler?.e("Invalid email format: ${response.statusCode} - ${response.body}");
        build_informative_alert_dialog(
          context,
          "Ok",
          "Invalid email",
          "The email you provided is invalid, please enter a valid email",
        );
        return false;
      case 404:
        log_handler?.w("Email not registered: ${response.statusCode} - ${response.body}");
        build_informative_alert_dialog(
          context,
          "Ok",
          "User not found",
          "We were not able to find your user, please ensure you have an account "
              "before trying again",
        );
        return false;
      case 422:
        log_handler?.e("Validation error: ${response.statusCode} - ${response.body}");
        build_informative_alert_dialog(
          context,
          "Ok",
          "Error 245", //Unprocessable Entity
          "There was an issue with the data provided. Please try again later",
        );
        return false;
      case 429:
        log_handler?.e("Rate limit hit: ${response.statusCode} - ${response.body}");
        build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return false;
      case 500:
      default:
        log_handler?.w("Unexpected status code: ${response.statusCode} - ${response.body}");
        build_informative_alert_dialog(
          context,
          "Ok",
          "Error 231", //Unexpected unknown server error
          "There has been an unexpected backend error, please try again later.",
        );
        return false;
    }
  } on SocketException catch (e) {
    log_handler?.e("Network error: $e");
    build_informative_alert_dialog(
      context,
      "Ok",
      "Error 234", //Network error
      "There has been an error with the network, please try again later",
    );
    return false;
  } on TimeoutException {
    return false; // already handled
  } catch (e) {
    log_handler?.e("Unexpected error: $e");
    build_informative_alert_dialog(
      context,
      "Ok",
      "Error 231", //Unexpected unknown server error
      "There has been an unexpected backend error, please try again later.",
    );
    return false;
  }
}
