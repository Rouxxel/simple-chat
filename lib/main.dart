import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simple_chat/methods_functions/methods.dart';
import 'package:simple_chat/screens_pages/landing_page.dart';
import 'package:simple_chat/configurations/config_invoke.dart';

//imports
/////////////////////////////////////////////////////////////////////////////
//Run app

void main() async{
  //Load environmental variable to make it available
  await dotenv.load(fileName:"envvar.env");

  //Load configuration
  await load_app_config("assets/config_file.json");

  //Check loaded configuration (I know its horrible coding)
  log_handler.i(
      'directive: ${config_data.directive}, '
          'response_length_limit: ${config_data.response_length_limit}, '
          'response_length_tolerance: ${config_data.response_length_tolerance}, '
          'ai_api_model: ${config_data.ai_api_model}, '
          'max_api_response_time_limit: ${config_data.max_api_response_time_limit}, '
          'verbose: ${config_data.verbose}, '
          'character_render_speed_ms: ${config_data.character_render_speed_ms}, '
          'background_color: ${config_data.background_color}, '
          'app_bar_color: ${config_data.app_bar_color}, '
          'text_color: ${config_data.text_color}, '
          'suggest_input_color: ${config_data.suggest_input_color}, '
          'user_text_box_color: ${config_data.user_text_box_color}, '
          'ai_text_box_color: ${config_data.ai_text_box_color}, '
          'date_text_color: ${config_data.date_text_color}, '
          'user_language: ${config_data.user_language}, '
          'user_theme: ${config_data.user_theme}, '
          'app_version: ${config_data.app_version}, '
          'legal_notice: ${config_data.legal_notice}'
  );

  runApp(
    const MaterialApp(
      home: landing_page(),
    ),
  );
}
